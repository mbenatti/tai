defmodule Tai.Mixfile do
  use Mix.Project

  def project do
    [
      app: :tai,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Tai, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:decimal, "~> 1.0"},
      {:ecto, "~> 2.1.0"},
      {:ex_gdax, "~> 0.1.2"},
      {:httpoison, "~> 0.12"},
      {:json, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      {:timex, "~> 3.1"},
      {:websockex, "~> 0.4"},
      {:exvcr, "~> 0.8", only: [:test]},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:ex_unit_notifier, "~> 0.1", only: :test},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
