defmodule ChatapiTest do
  use ExUnit.Case
  doctest Chatapi

  test "greets the world" do
    assert Chatapi.hello() == :world
  end
end
