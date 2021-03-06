defmodule Examples.Advisors.CreateAndCancelPendingOrder.Advisor do
  use Tai.Advisor

  alias Tai.Advisor
  alias Tai.Trading.{OrderStatus, OrderSubmission, TimeInForce}

  require Logger

  def handle_inside_quote(order_book_feed_id, symbol, inside_quote, changes, state) do
    Logger.debug(fn ->
      :io_lib.format(
        "handle_inside_quote - order_book_feed_id: ~s, symbol: ~s, quote: ~s, changes: ~s, state: ~s",
        [
          order_book_feed_id,
          symbol,
          inspect(inside_quote),
          inspect(changes),
          inspect(state)
        ]
      )
    end)

    if order_book_feed_id == :gdax do
      cond do
        Tai.Trading.OrderStore.count() == 0 ->
          Logger.info("create buy limit order on #{order_book_feed_id}")

          actions = %{
            orders: [
              OrderSubmission.buy_limit(:gdax, symbol, 100.1, 0.1, TimeInForce.fill_or_kill())
            ]
          }

          {:ok, actions}

        (pending_orders = Tai.Trading.OrderStore.where(status: OrderStatus.pending()))
        |> Enum.count() > 0 ->
          Logger.info(
            "[#{state.advisor_id |> Advisor.to_name()}] handle_inside_quote - cancel pending orders: #{
              inspect(pending_orders)
            }"
          )

          cancel_orders = pending_orders |> Enum.map(& &1.client_id)
          {:ok, %{cancel_orders: cancel_orders}}

        true ->
          :ok
      end
    end
  end

  def handle_order_create_ok(order, _state) do
    Logger.info("order created: #{inspect(order)}")
  end

  def handle_order_create_error(reason, order, _state) do
    Logger.warn("error creating order: #{inspect(order)}, reason: #{inspect(reason)}")
  end
end
