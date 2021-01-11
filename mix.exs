defmodule ExLoggerMock.MixProject do
  @moduledoc "setup the project"

  use Mix.Project

  def project do
    [
      app: :ex_logger_mock,
      deps: deps(),
      docs: docs(),
      description: "A mock logging backend for Elixir unit tests",
      elixir: "~> 1.10",
      homepage_url: "https://github.com/lucas-nelson/ex_logger_mock",
      name: "ExLoggerMock",
      package: package(),
      preferred_cli_env: preferred_cli_env(),
      source_url: "https://github.com/lucas-nelson/ex_logger_mock",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: "1.2.0"
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.2", only: :test, runtime: false},
      {:dialyxir, "~> 0.5.1", only: :test, runtime: false},
      {:ex_doc, "~> 0.21.3", only: :dev, runtime: false},
      {:excoveralls, "~> 0.12.2", only: :test, runtime: false},
      {:mix_test_watch, "~> 1.0", only: :test, runtime: false}
    ]
  end

  defp docs do
    [
      main: "ExLoggerMock.Backend"
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lucas-nelson/ex_logger_mock"},
      name: "ex_logger_mock"
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      credo: :test,
      dialyzer: :test,
      "test.watch": :test
    ]
  end
end
