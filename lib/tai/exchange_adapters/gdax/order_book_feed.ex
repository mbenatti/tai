defmodule Tai.ExchangeAdapters.Gdax.OrderBookFeed do
  @moduledoc """
  WebSocket order book feed adapter for GDAX
  """

  use Tai.Exchanges.OrderBookFeed

  require Logger

  alias Tai.{Exchanges.OrderBookFeed, Markets.OrderBook, PubSub}
  alias Tai.ExchangeAdapters.Gdax.{Product, Serializers.Snapshot, Serializers.L2Update}

  @doc """
  Secure production GDAX WebSocket url
  """
  def default_url, do: "wss://ws-feed.gdax.com/"

  @doc """
  Subscribe to the level2 channel for the configured symbols
  """
  def subscribe_to_order_books(name, symbols) do
    [name: name, symbols: symbols, channels: ["level2", "heartbeat"]]
    |> subscribe
  end

  @doc """
  Replace the bids/asks in the order books with the initial GDAX snapshot
  """
  def handle_msg(
    %{
      "type" => "snapshot",
      "product_id" => product_id,
      "bids" => bids,
      "asks" => asks
    },
    feed_id
  ) do
    processed_at = Timex.now
    normalized_bids = bids |> Snapshot.normalize(processed_at)
    normalized_asks = asks |> Snapshot.normalize(processed_at)
    symbol = Product.to_symbol(product_id)

    [feed_id: feed_id, symbol: symbol]
    |> OrderBook.to_name
    |> OrderBook.replace(
      %{
        bids: normalized_bids,
        asks: normalized_asks
      }
    )
    |> broadcast_order_book_snapshot(feed_id, symbol, normalized_bids, normalized_asks)
  end
  @doc """
  Update the bids/asks in the order books that have changed
  """
  def handle_msg(
    %{
      "type" => "l2update",
      "time" => time,
      "product_id" => product_id,
      "changes" => changes
    },
    feed_id
  ) do
    processed_at = Timex.now
    server_changed_at = Timex.parse!(time, "{ISO:Extended}")
    normalized_changes = changes |> L2Update.normalize(processed_at, server_changed_at)
    symbol = product_id |> Product.to_symbol

    [feed_id: feed_id, symbol: symbol]
    |> OrderBook.to_name
    |> OrderBook.update(normalized_changes)
    |> broadcast_order_book_changes(feed_id, symbol, normalized_changes)
  end
  @doc """
  TODO:
  Heartbeat should keep it alive. If it doesn''t receive a message in N time
  tai should check the connection, reconnect if need be. Shutdown other wise?
  """
  def handle_msg(
    %{
      "type" => "heartbeat",
      "product_id" => _product_id,
      "last_trade_id" => _last_trade_id,
      "sequence" => _sequence,
      "time" => _time
    },
    _feed_id
  ) do
  end
  @doc """
  Log a warning message when the WebSocket receives a message that is not explicitly handled
  """
  def handle_msg(unhandled_msg, feed_id) do
    Logger.warn "[#{feed_id |> OrderBookFeed.to_name}] unhandled message: #{inspect unhandled_msg}"
  end

  defp broadcast_order_book_changes(:ok, feed_id, symbol, changes) do
    PubSub.broadcast(
      {:order_book_changes, feed_id},
      {:order_book_changes, feed_id, symbol, changes}
    )
  end

  defp broadcast_order_book_snapshot(:ok, feed_id, symbol, normalized_bids, normalized_asks) do
    PubSub.broadcast(
      {:order_book_snapshot, feed_id},
      {:order_book_snapshot, feed_id, symbol, normalized_bids, normalized_asks}
    )
  end

  defp subscribe(name: name, symbols: symbols, channels: channels) do
    [
      name: name,
      msg: %{
        "type" => "subscribe",
        "product_ids" => Product.to_product_ids(symbols),
        "channels" => channels
      }
    ]
    |> send_msg
  end

  defp send_msg(name: name, msg: msg) do
    name
    |> WebSockex.send_frame({:text, JSON.encode!(msg)})
  end
end
