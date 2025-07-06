# F-Strings

A library that aims to provide some of the features that [Python F-strings have](https://docs.python.org/3/tutorial/inputoutput.html#formatted-string-literals).

It currently allows the usage of the `=` specifier after the interpolation, meaning that it will
expand the interpolated expression to the text of the expression, an equal sign, then
the representation of the evaluated expression. Both the text and the evaluated expression
are wrapped in single quotes.

```elixir
iex(1)> import FStrings
FStrings

iex(2)> world = "Jupiter"
"Jupiter"

iex(3)> ~f"Hello, #{world}="
"Hello, 'world'='Jupiter'"
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `f_strings` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:f_strings, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/f_strings>.

