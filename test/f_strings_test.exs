defmodule FStringsTest do
  use ExUnit.Case, async: true

  import FStrings
  import ExUnit.CaptureIO

  doctest FStrings

  test "works without any interpolation" do
    assert ~f"no interpolation" == "no interpolation"
  end

  test "interpolates integer value" do
    abc = 42

    assert ~f"->#{abc}=<-" == "->'abc'='42'<-"
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

  test "keeps a single '=' and doesn't transform if '==' is used" do
    abc = 42

    assert ~f"->#{abc}==forty-two<-" == "->42=forty-two<-"
  end

  test "doesn't hiccups with = in the beginning or end" do
    assert ~f"= == == =" == "= == == ="
    assert ~f"== = = ==" == "== = = =="
  end

  test "it interpolates in the beginning as expected" do
    foo = "bruah"

    assert ~f"#{foo}= xxx" == "'foo'='bruah' xxx"
  end

  test "it interpolates in the end as expected" do
    foo = "bruah"

    assert ~f"aaa #{foo}=" == "aaa 'foo'='bruah'"
  end

  test "it interpolates only with the trailing = sign" do
    foo = "bruah"

    assert ~f"#{foo}AAA #{foo}= #{foo}1234 #{foo}=XXX#{foo}" ==
             "bruahAAA 'foo'='bruah' bruah1234 'foo'='bruah'XXXbruah"

    assert ~f"#{foo}=AAA #{foo}==9 #{foo}=1234 #{foo}==XXX#{foo}=" ==
             "'foo'='bruah'AAA bruah=9 'foo'='bruah'1234 bruah=XXX'foo'='bruah'"
  end

  test "interpolates complex expressions and uses them in the equality as expected" do
    abc = 42

    assert ~f"->#{abc * 2 + 3}=<-" == "->'abc * 2 + 3'='87'<-"
  end

  test "interpolates multiple expressions" do
    abc = 42.0
    bar = 2

    assert ~f"#{abc * 2 + 3}= < #{Float.pow(abc, bar)}=" ==
             "'abc * 2 + 3'='87.0' < 'Float.pow(abc, bar)'='1764.0'"
  end
end
