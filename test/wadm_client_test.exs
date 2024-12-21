defmodule WadmClientTest do
  use ExUnit.Case
  doctest WadmClient

  test "greets the world" do
    assert WadmClient.hello() == :world
  end
end
