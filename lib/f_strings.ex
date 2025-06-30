defmodule FStrings do
  @moduledoc """
  Documentation for `FStrings`.
  """

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

  defp evaluate_and_replace_expressions({:<<>>, meta, string_elements}) do
    new_string_elements = Enum.reduce(string_elements, [], fn
      literal_string, acc when is_binary(literal_string) ->
        [literal_string | acc]

      # the interpolation always comes with ":: binary" appended to it
      {:"::", _meta, [interpolation_stuff, {:binary, _, _}]} = interpolation_element, acc ->
        prefix = "BLABLA="

        interpolation_stuff
        |> Macro.to_string()
        |> IO.inspect(label: "STRINGED INTERPOLATION STUFF")

        {_always_present_kernel_to_string, _meta, [interpolated_stuff]} = interpolation_stuff
        IO.inspect(interpolated_stuff, label: "INTERPOLATED STUFF")

        interpolated_stuff
        |> Macro.to_string()
        |> IO.inspect(label: "TO STRING INTERPOLATED STUFF")

        IO.inspect(interpolation_stuff, label: "INTERPOLATION STUFF")

        # prefix after since we'll reverse it later
        [interpolation_element, prefix | acc]

      other, acc ->
        [other | acc]
    end)

    z = {:<<>>, meta, Enum.reverse(new_string_elements)}

    IO.inspect(z, label: "AFTER manipulation")
    z
  end
end
