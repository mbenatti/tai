defmodule Tai.Mixfile do
  use Mix.Project

  def project do
    [
      app: :tai,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
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
      {:ex_bitstamp, github: "fremantle-capital/ex_bitstamp"},
      {:ex_gdax, "~> 0.1.2"},
      {:httpoison, "~> 0.12"},
      {:json, "~> 1.0"},
      {:table_rex, "~> 0.10"},
      {:timex, "~> 3.1"},
      {:websockex, "~> 0.4"},
      {:logger_file_backend, "~> 0.0.10"},
      {:uuid, "~> 1.1"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:cowboy, "~> 1.0.0", only: [:dev, :test]},
      {:echo_boy, "~> 0.1.0", github: "rupurt/echo_boy", only: [:dev, :test]},
      {:plug, "~> 1.0", only: [:dev, :test]},
      {:mix_test_watch, "~> 0.5", only: :dev, runtime: false},
      {:exvcr, "~> 0.8", only: [:test]},
      {:ex_unit_notifier, "~> 0.1", only: :test}
    ]
  end

  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
