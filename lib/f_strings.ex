defmodule FStrings do
  @moduledoc """
  Documentation for `FStrings`.
  """

  @doc """
  ~f sigil for f-strings.

  ## Examples

      iex> abc=3
      iex> require FStrings
      iex> FStrings.sigil_f("hello world \#{abc}= \#{abc}", [])
      "hello world 'abc'='3' 3"

  """
  defmacro sigil_f(quoted_string, _modifiers) do
    evaluate_and_replace_expressions(quoted_string)
  end

  # Only evaluates and tweaks the '#{...}' expressions, leaving all the other in place
  # iex(18)> quote do: "asfsaf #{222} xxxxxxxxx #{333+45} ffff"
  # {:<<>>, [],
  #  [
  #    "asfsaf ",
  #    {:"::", [],
  #     [
  #       {{:., [], [Kernel, :to_string]}, [from_interpolation: true], [222]},
  #       {:binary, [], Elixir}
  #     ]},
  #    " xxxxxxxxx ",
  #    {:"::", [],
  #     [
  #       {{:., [], [Kernel, :to_string]}, [from_interpolation: true],
  #        [{:+, [context: Elixir, imports: [{1, Kernel}, {2, Kernel}]], [333, 45]}]},
  #       {:binary, [], Elixir}
  #     ]},
  #    " ffff"
  #  ]}
  defp evaluate_and_replace_expressions(literal_string) when is_binary(literal_string),
    do: literal_string

  defp evaluate_and_replace_expressions({:<<>>, meta, string_elements}) do
    total_string_elements = length(string_elements)

    eval_and_replace =
      Enum.reduce(string_elements, %{processed: [], result: []}, fn
        # a string element starting with '==' means a single '=' should be kept ("escaped" equals), no fancy interpolation before
        "==" <> remaining_string, %{processed: [_ | _] = processed, result: result} = acc ->
          last_processed = hd(processed)
          # we take the transformed interpolation out from the result so far
          [quote, _interpolation_ast, quote, _expression_equals | rest_result] = result

          # we don't want to keep the transformed interpolation,
          # so we place the last processed in the result instead
          acc
          |> Map.put(:result, ["=" <> remaining_string, last_processed | rest_result])
          |> Map.put(:processed, ["=" <> remaining_string | processed])

        # a string element starting with '=' means no '=' should be kept, keep the transformed interpolation
        "=" <> remaining_string, %{processed: [_ | _] = processed, result: result} = acc ->
          # we don't want to keep the transformed interpolation, so we place the last processed
          acc
          |> Map.put(:result, [remaining_string | result])
          |> Map.put(:processed, ["=" <> remaining_string | processed])

        # when no '=' starts the string element, it means the interpolation of
        # the previous element is the vanilla one, so we drop the transformed interpolation
        literal_string, %{processed: [_ | _] = processed, result: result} = acc
        when is_binary(literal_string) ->
          last_processed = hd(processed)
          [quote, _interpolation_ast, quote, _expression_equals | rest_result] = result

          acc
          |> Map.put(:result, [literal_string, last_processed | rest_result])
          |> Map.put(:processed, [literal_string | processed])

        literal_string, %{processed: processed, result: result} = acc
        when is_binary(literal_string) ->
          acc
          |> Map.put(:result, [literal_string | result])
          |> Map.put(:processed, [literal_string | processed])

        # when processing an interpolation as the last string element, it means it's a vanilla interpolation
        # (since there can't be a trailing '=' sign)
        {:"::", _meta, _interpolation_expression} = interpolation_ast,
        %{processed: processed, result: result} = acc
        when length(processed) + 1 == total_string_elements ->
          acc
          |> Map.put(:result, [interpolation_ast | result])
          |> Map.put(:processed, [interpolation_ast | processed])

        # the interpolation always comes with ":: binary" appended to it
        {:"::", _meta, [interpolated_expression, {:binary, _, _}]} = interpolation_ast,
        %{processed: processed, result: result} = acc ->
          {_always_present_kernel_to_string, _meta, [interpolated_stuff]} =
            interpolated_expression

          expression_equals =
            interpolated_stuff
            |> Macro.to_string()
            |> wrap_in_quotes()
            |> Kernel.<>("=")

          acc
          # expression_equals as last element since we'll reverse it later
          # we wrap the interpolated expression with quotes to clearly show its value
          |> Map.put(:result, ["'", interpolation_ast, "'", expression_equals | result])
          |> Map.put(:processed, [interpolation_ast | processed])

        other, %{processed: processed, result: result} = acc ->
          acc
          |> Map.put(:result, [other | result])
          |> Map.put(:processed, [other | processed])
      end)

    {:<<>>, meta, Enum.reverse(eval_and_replace.result)}
  end

  defp wrap_in_quotes(string), do: "'#{string}'"
end
