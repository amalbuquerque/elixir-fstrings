defmodule FStrings.LoggerTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  defmodule Dummy do
    use FStrings.Logger

    def foo, do: 42

    def vanilla_info(message), do: Logger.info("something #{foo()} #{message}")

    def vanilla_warning(message), do: Logger.warning("something #{foo()} #{message}")

    def vanilla_error(message), do: Logger.error("something #{foo()} #{message}")

    # using the F-string interpolation 👇

    def no_sigil_info(message), do: Logger.info("something #{foo()}= #{message}")

    def no_sigil_warning(message), do: Logger.warning("something #{foo()}= #{message}")

    def no_sigil_error(message), do: Logger.error("something #{foo()}= #{message}")

    def sigil_info(message), do: Logger.info(~f"something #{foo()}= #{message}")

    def sigil_warning(message), do: Logger.warning(~f"something #{foo()}= #{message}")

    def sigil_error(message), do: Logger.error(~f"something #{foo()}= #{message}")
  end

  test "Vanilla interpolation works as expected" do
    for level <- [:info, :warning, :error] do
      assert capture_log([level: level], fn ->
               function = String.to_atom("vanilla_#{level}")

               apply(Dummy, function, ["This is OK"])
             end) =~ "something 42 This is OK"
    end
  end

  test "F-string interpolation works without sigil" do
    for level <- [:info, :warning, :error] do
      assert capture_log([level: level], fn ->
               function = String.to_atom("no_sigil_#{level}")

               apply(Dummy, function, ["This is OK"])
             end) =~ "something 'foo()'='42' This is OK"
    end
  end

  test "F-string interpolation works with F sigil" do
    for level <- [:info, :warning, :error] do
      assert capture_log([level: level], fn ->
               function = String.to_atom("sigil_#{level}")

               apply(Dummy, function, ["This is OK"])
             end) =~ "something 'foo()'='42' This is OK"
    end
  end
end
