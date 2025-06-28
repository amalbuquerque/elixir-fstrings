defmodule FStringsTest do
  use ExUnit.Case
  doctest FStrings

  test "greets the world" do
    assert FStrings.hello() == :world
  end
end
