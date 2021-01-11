# ExLoggerMock

A mock logging backend for Elixir unit tests. A clean way to get rid of log output in the test run.

## Installation

The package can be installed by adding `ex_logger_mock` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_logger_mock, "~> 1.0", only: :test, runtime: false}
  ]
end
```

Documentation can be found at
[https://hexdocs.pm/ex_logger_mock](https://hexdocs.pm/ex_logger_mock).

## Configuration

In the `test` environment configuration, replace the default `:console` logging backend with this
package in your `config/test.exs` file:

```elixir
config :logger,
  backends: [{ExLoggerMock.Backend, :ex_logger_mock}]
```

Some packages, e.g. Rollbax, don't like receiving unexpected messages. You can limit the applications
that will be sent a message with extra configuration:

```elixir
config :logger,
  backends: [{ExLoggerMock.Backend, :ex_logger_mock}]

config :ex_logger_mock, application_reject: [:rollbax]
```

or:

```elixir
config :logger,
  backends: [{ExLoggerMock.Backend, :ex_logger_mock}]

config :ex_logger_mock, application_filter: [:my_app, :my_app_web]
```

You can optionally reject messages using a callback.

```elixir
config :logger,
  backends: [{ExLoggerMock.Backend, :ex_logger_mock}]

config :ex_logger_mock, message_reject: fn message -> String.match?(message, ~r/MyXQL.Connection/) end
```

## Use

The log calls themselves do not change. Without the `:console` backend, you won't see log output
during the `mix test` run.

In unit tests, you can now assert for specific messages being logged:

```elixir
assert_receive {:ex_logger_mock, {:info, "test log message", _timestamp, _metadata}}
```

NOTE: `assert_receive` here, not `assert_received`. Logging happens asynchronously across processes,
so we need to give the message a little time to make it's way back to the test process.

## Why

I don't like seeing log output during the `mix test` run. Traditionally, we solved that problem by
setting the log level in the test configuration to `:warn`. But that solution makes testing "normal"
log output with `log_capture` fail. Logs at `:info` level won't ever be produced, so cannot be
checked.

Inspired by [José's Mocks and explicit
contracts](http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/) post, and with
many thanks to Brandon Richey for his [The Ultimate Guide To Logging In
Elixir](https://timber.io/blog/the-ultimate-guide-to-logging-in-elixir/) post, this package solves
both those problems.

## Contributing

The typical fork, branch and PR dance.

To check all is well:

```bash
mix compile --force --warnings-as-errors && \
mix coveralls && \
mix credo --strict
```

## License

MIT - do what you want with it.
