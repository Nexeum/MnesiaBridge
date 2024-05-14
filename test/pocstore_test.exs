defmodule PocstoreTest do
  use ExUnit.Case
  doctest Pocstore

  test "greets the world" do
    assert Pocstore.hello() == :world
  end
end
