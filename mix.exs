defmodule ExLoggerMock.MixProject do
  @moduledoc "setup the project"

  use Mix.Project

  def project do
    [
      app: :ex_logger_mock,
      deps: deps(),
      elixir: "~> 1.7",
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls],
      start_permanent: Mix.env() == :prod,
      version: "1.0.0"
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.0", only: :test, runtime: false},
      {:dialyxir, "~> 0.5.1", only: :test, runtime: false},
      {:excoveralls, "~> 0.10.1", only: :test, runtime: false},
      {:mix_test_watch, "~> 0.6", only: :test, runtime: false}
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
