defmodule FStrings do
  @moduledoc """
  Documentation for `FStrings`.
  """

  @dummy_acc []

  @doc """
  ~f sigil for f-strings.

  ## Examples

      iex> abc=3; FStrings.sigil_f("hello world \#{abc}")
      "hello world 'abc'='3'"

  """
  defmacro sigil_f(quoted_string, _modifiers) do
    IO.inspect(quoted_string, label: "SIGILED")

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
  defp evaluate_and_replace_expressions(literal_string) when is_binary(literal_string), do: literal_string

  defp evaluate_and_replace_expressions({:<<>>, _meta, _string_elements} = ast) do
    {new_ast, _acc} = Macro.prewalk(ast, @dummy_acc, fn
      literal_string, acc when is_binary(literal_string) ->
        {literal_string, acc}

      {:"::", _meta, interpolation_args} = x, acc ->
        IO.inspect(interpolation_args, label: "INTERPOLATION ARGS")
        {x, acc}

      other, acc ->
        {other, acc}
    end)

    new_ast
  end
end
