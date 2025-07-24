defmodule FStrings.Logger do
  @moduledoc """
  Simple Logger wrapper to help using the FStrings library for logs.

  Use it like this:

    iex> use FStrings.Logger
    iex> abc = 42
    iex> IO.puts("Uncomment next line, FIX THIS")
    iex> # Logger.info(~f"This is the meaning of life \#{abc}=")
    # Will log an info message: "This is the meaning of life 'abc'='42'"
  ```
  """

  @no_modifiers []

  require Logger
  require FStrings

  defmacro __using__(_options) do
    quote do
      import FStrings
      require Logger
      alias FStrings.Logger, as: Logger
    end
  end

  defmacro info(message_or_fun, metadata \\ [])

  defmacro info({:<<>>, _metadata, _concatenated_stuff} = quoted_string, metadata) do
    quote do
      evaluated_and_replaced_string =
        FStrings.sigil_f(unquote(quoted_string), unquote(@no_modifiers))

      Logger.info(evaluated_and_replaced_string, unquote(metadata))
    end
  end

  defmacro info(iodata_or_fun, metadata) do
    quote do
      Logger.info(unquote(iodata_or_fun), unquote(metadata))
    end
  end

  defmacro warning(message_or_fun, metadata \\ [])

  defmacro warning({:<<>>, _metadata, _concatenated_stuff} = quoted_string, metadata) do
    quote do
      evaluated_and_replaced_string =
        FStrings.sigil_f(unquote(quoted_string), unquote(@no_modifiers))

      Logger.warning(evaluated_and_replaced_string, unquote(metadata))
    end
  end

  defmacro warning(iodata_or_fun, metadata) do
    quote do
      Logger.warning(unquote(iodata_or_fun), unquote(metadata))
    end
  end

  defmacro error(message_or_fun, metadata \\ [])

  defmacro error({:<<>>, _metadata, _concatenated_stuff} = quoted_string, metadata) do
    quote do
      evaluated_and_replaced_string =
        FStrings.sigil_f(unquote(quoted_string), unquote(@no_modifiers))

      Logger.error(evaluated_and_replaced_string, unquote(metadata))
    end
  end

  defmacro error(iodata_or_fun, metadata) do
    quote do
      Logger.error(unquote(iodata_or_fun), unquote(metadata))
    end
  end
end
