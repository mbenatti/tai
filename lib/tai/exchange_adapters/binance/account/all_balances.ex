defmodule Tai.ExchangeAdapters.Binance.Account.AllBalances do
  @moduledoc """
  Fetch and normalize all balances on the Binance account
  """

  alias Tai.{CredentialError, TimeoutError}

  def fetch do
    Binance.get_account()
    |> normalize_assets
  end

  defp normalize_assets({:ok, %Binance.Account{balances: raw_balances}}) do
    balances =
      raw_balances
      |> Enum.reduce(%{}, &normalize_asset/2)

    {:ok, balances}
  end

  defp normalize_assets({:error, %{"code" => -2014, "msg" => "API-key format invalid." = reason}}) do
    {:error, %CredentialError{reason: reason}}
  end

  defp normalize_assets({:error, {:http_error, %HTTPoison.Error{reason: "timeout"}}}) do
    {:error, %TimeoutError{reason: "network request timed out"}}
  end

  defp normalize_asset(%{"asset" => raw_asset, "free" => raw_free, "locked" => raw_locked}, acc) do
    with asset <- raw_asset |> String.downcase() |> String.to_atom(),
         free <- Decimal.new(raw_free),
         locked <- Decimal.new(raw_locked),
         balance <- Decimal.add(free, locked) do
      Map.put(acc, asset, balance)
    end
  end
end
