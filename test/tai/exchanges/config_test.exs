defmodule Tai.Exchanges.ConfigTest do
  use ExUnit.Case, async: true
  doctest Tai.Exchanges.Config

  test "all returns the application config" do
    assert Tai.Exchanges.Config.all == %{
      test_exchange_a: Tai.Exchanges.Adapters.Test,
      test_exchange_b: Tai.Exchanges.Adapters.Test
    }
  end

  test "adapter returns the configured module for the exchange name" do
    assert Tai.Exchanges.Config.adapter(:test_exchange_a) == Tai.Exchanges.Adapters.Test
  end
end
