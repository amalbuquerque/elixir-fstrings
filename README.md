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

### Use it with Logger

This kind of interpolation where we want the actual expression to be present in the string is usually needed for logging. To help with that, you can use the `FStrings.Logger` module that will allow you to use the F-string interpolation without having to specify the `~f"..."` sigil 😎


```elixir
use FStrings.Logger

foo = 42

Logger.info("Important value #{foo}=")
```

The last statement will log `Important value 'foo'='42'`, note the F-string interpolation without having to specify the `~f` sigil.

## TODO

1. [ ] Allow modifiers to be passed to the sigil to control the wrapping character:
  - 'x' for no wrapping,
  - 'q' for quotes,
  - 'p' for parentheses,
  - 's' for square brackets,
  - 'c' for curly brackets

2. [ ] Allow `wrap_in` option to be passed to `use FStrings.Logger` for the default wrapping character

3. [ ] Allow `x|q|p|s|c` to be passed before `=` to set different wrapping character for single interpolation

## Installation

The package can be installed by adding `f_strings` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:f_strings, "~> 0.1.0"}
  ]
end
```
