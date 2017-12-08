require IEx;

defmodule Tai.CommandsHelperTest do
  use ExUnit.Case
  doctest Tai.CommandsHelper

  import ExUnit.CaptureIO

  test "help returns the usage for the supported commands" do
    assert capture_io(fn ->
      Tai.CommandsHelper.help
    end) == """
    * status
    * quotes exchange(:gdax), symbol(:btcusd)
    * buy_limit exchange(:gdax), symbol(:btcusd), price(101.12), size(1.2)
    * sell_limit exchange(:gdax), symbol(:btcusd), price(101.12), size(1.2)
    * order_status exchange(:gdax), order_id("f1bb2fa3-6218-45be-8691-21b98157f25a")
    * cancel_order exchange(:gdax), order_id("f1bb2fa3-6218-45be-8691-21b98157f25a")
    * history exchange(:gdax), symbol(:btcusd), date_from("2016-01-01"), date_to("2017-01-01"), period("1d")
    * history_download exchange(:gdax), symbol(:btcusd), date_from("2016-01-01"), date_to("2017-01-01")\n
    """
  end

  test "status is the sum of USD balances across accounts as a formatted string" do
    assert capture_io(fn ->
      Tai.CommandsHelper.status
    end) == "0.22 USD\n"
  end

  test "quotes returns the orderbook for the exchange and symbol" do
    assert capture_io(fn ->
      Tai.CommandsHelper.quotes(:test_exchange_a, :btcusd)
    end) == """
    8003.22/0.66 [0.000143s]
    ---
    8003.21/1.55 [0.001044s]\n
    """
  end

  test "quotes displays errors" do
    assert capture_io(fn ->
      Tai.CommandsHelper.quotes(:test_exchange_a, :notfound)
    end) == "error: NotFound\n"
  end

  test "buy_limit creates an order on the exchange then displays it's 'id' and 'status'" do
    assert capture_io(fn ->
      Tai.CommandsHelper.buy_limit(:test_exchange_a, :btcusd, 10.1, 2.2)
    end) == "create order success - id: f9df7435-34d5-4861-8ddc-80f0fd2c83d7, status: pending\n"
  end

  test "buy_limit displays an error message when the order can't be created" do
    assert capture_io(fn ->
      Tai.CommandsHelper.buy_limit(:test_exchange_a, :btcusd, 10.1, 3.3)
    end) == "create order failure - Insufficient funds\n"
  end

  test "sell_limit creates an order on the exchange then displays it's 'id' and 'status'" do
    assert capture_io(fn ->
      Tai.CommandsHelper.sell_limit(:test_exchange_a, :btcusd, 10.1, 2.2)
    end) == "create order success - id: 41541912-ebc1-4173-afa5-4334ccf7a1a8, status: pending\n"
  end

  test "sell_limit displays an error message when the order can't be created" do
    assert capture_io(fn ->
      Tai.CommandsHelper.sell_limit(:test_exchange_a, :btcusd, 10.1, 3.3)
    end) == "create order failure - Insufficient funds\n"
  end

  test "order_status displays the order info" do
    assert capture_io(fn ->
      Tai.CommandsHelper.order_status(:test_exchange_a, "f9df7435-34d5-4861-8ddc-80f0fd2c83d7")
    end) == "status: open\n"
  end

  test "order_status displays error messages" do
    assert capture_io(fn ->
      Tai.CommandsHelper.order_status(:test_exchange_a, "invalid-order-id")
    end) == "error: Invalid order id\n"
  end

  test "cancel_order cancels a previous order" do
    assert capture_io(fn ->
      Tai.CommandsHelper.cancel_order(:test_exchange_a, "f9df7435-34d5-4861-8ddc-80f0fd2c83d7")
    end) == "cancel order success\n"
  end

  test "cancel_order displays error messages" do
    assert capture_io(fn ->
      Tai.CommandsHelper.cancel_order(:test_exchange_a, "invalid-order-id")
    end) == "error: Invalid order id\n"
  end

  test "strategy shows runtime info" do
    assert capture_io(fn ->
      Tai.CommandsHelper.strategy(:test_strategy_a)
    end) == "started: 2010-01-13 14:21:06Z\n"
  end

  test "history for a symbol can be downloaded within a time range" do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Tai.Repo)

    assert capture_io(fn ->
      Tai.CommandsHelper.history_download(:test_exchange_a, :btcusd, "2016-01-01", "2016-01-02")
    end) == """
    downloading...
    finished!
    """

    assert capture_io(fn ->
      Tai.CommandsHelper.history :test_exchange_a, :btcusd, "2016-01-01", "2016-01-02", "1d"
    end) == """
    2016-01-01 00:00:00.000000 o:101.11 h:102.22 l:99.99 c:100.01
    2016-01-02 00:00:00.000000 o:100.01 h:100.01 l:90.09 c:91.11
    """
  end
end
