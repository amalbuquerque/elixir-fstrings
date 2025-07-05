defmodule FStrings do
  @moduledoc """
  Documentation for `FStrings`.
  """

  @doc """
  ~f sigil for f-strings.

  ## Examples

      iex> abc=3
      iex> require FStrings
      iex> FStrings.sigil_f("hello world \#{abc}", [])
      "hello world 'abc'='3'"

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
    eval_and_replace =
      Enum.reduce(string_elements, %{processed: [], result: []}, fn
        literal_string, %{processed: processed, result: result} = acc
        when is_binary(literal_string) ->
          acc
          |> Map.put(:result, [literal_string | result])
          |> Map.put(:processed, [literal_string | processed])

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
