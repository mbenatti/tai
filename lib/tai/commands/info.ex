defmodule Tai.Commands.Info do
  @moduledoc """
  Show the available commands
  """

  def help do
    IO.puts("""
    * dashboard
    * balance
    * markets
    * orders
    * buy_limit account_id(:gdax), symbol(:btcusd), price(101.12), size(1.2)
    * sell_limit account_id(:gdax), symbol(:btcusd), price(101.12), size(1.2)
    * order_status account_id(:gdax), order_id("f1bb2fa3-6218-45be-8691-21b98157f25a")
    * cancel_order account_id(:gdax), order_id("f1bb2fa3-6218-45be-8691-21b98157f25a")
    """)
  end
end
