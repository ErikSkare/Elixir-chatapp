defmodule Chatapi.MixProject do
  use Mix.Project

  def project do
    [
      app: :chatapi,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Chatapi.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:corsica, "~> 1.0"}
    ]
  end
end
