defmodule FStringsTest do
  use ExUnit.Case
  import FStrings
  import ExUnit.CaptureIO

  doctest FStrings

  test "works without any interpolation" do
    assert ~f"no interpolation" == "no interpolation"
  end

  test "interpolates integer value" do
    abc = 42

    assert ~f"->#{abc}<-" == "->'abc'='42'<-"
  end

  test "blows up with the expected CompileError if variable not present in context" do
    dummy_module = """
    defmodule Dummy do
      import FStrings

      def foo, do: ~f"->\#{missing}<-"
    end
    """

    error_message =
      capture_io(:stderr, fn ->
        assert_raise CompileError, fn ->
          Code.eval_string(dummy_module)
        end
      end)

    assert error_message |> String.contains?(~s(undefined variable "missing"))
  end

  test "interpolates complex expressions and uses them in the equality as expected" do
    abc = 42

    assert ~f"->#{abc * 2 + 3}<-" == "->'abc * 2 + 3'='87'<-"
  end
end
