defmodule ExLoggerMock.Backend do
  @moduledoc ~S"""
  A logging backend for unit testing.

  Configure in your `config/test.exs` to replace the default `:console` backend:

  ```elixir
  config :logger,
    backends: [{ExLoggerMock.Backend, :ex_logger_mock}]
  ```

  This will suppress all log output on the console during `mix test`.

  It's simple to assert a certain log message happened in your unit test assertions:

  ```elixir
  assert_receive {:ex_logger_mock, {:info, "test log message", _timestamp, _metadata}}
  ```
  """
  @spec init({ExLoggerMock.Backend, binary()}) :: {:ok, %{name: binary()}}
  @doc "intialise from configuration, but we have no config"
  def init({__MODULE__, name}) do
    {:ok,
     %{
       application_filter: Application.get_env(:ex_logger_mock, :application_filter, []),
       application_reject: Application.get_env(:ex_logger_mock, :application_reject, []),
       message_reject: Application.get_env(:ex_logger_mock, :message_reject, nil),
       name: name
     }}
  end

  @spec handle_event({atom(), pid(), {atom(), binary(), tuple(), list()}}, map()) :: {:ok, map()}
  @doc ~S"""
  Handle the log 'event'.

  Send a message to the original process that created the log event. This is particularly useful in
  testing scenarios when testing code like:

  ```elixir
  Logger.warn("test warning message")
  ```

  You can verify that call happened with test code like:

  ```elixir
  assert_receive {:ex_logger_mock, {:warn, "test warning message", _timestamp, _metadata}}
  ```

  NOTE: use `assert_receive`, not `assert_received` because logging happens asynchronously across
  processes; need to give the test response message a short time to arrive.

  The third element in the tuple (timestamp) is probably useless in a testing scenario.

  The fourth element (metadata) is pulled, untouched, from the incoming log data.

  Do nothing if this process is not the 'group leader'.

  Do nothing if the event is not a log event.
  """
  def handle_event({_level, group_leader, {Logger, _, _, _}}, state)
      when node(group_leader) != node() do
    # From the Logger module docs:
    #
    # > It is recommended that handlers ignore messages where the group leader is in a different
    # > node than the one where the handler is installed.

    {:ok, state}
  end

  def handle_event({level, _group_leader, {Logger, message, timestamp, metadata}}, state) do
    with application when not is_nil(application) <- metadata[:application],
         pid when not is_nil(pid) <- metadata[:pid],
         true <- application_in_filter?(application, state),
         false <- application_in_reject?(application, state),
         false <- message_in_reject?(message, state) do
      send(pid, {:ex_logger_mock, {level, message, timestamp, metadata}})
    end

    {:ok, state}
  end

  # ignore other kinds of events, including :flush
  def handle_event(_, state), do: {:ok, state}

  @spec handle_call(any(), any()) :: {:ok, :ok, any()}
  @doc "ignore any 'call' notification, including :configure"
  def handle_call(_request, state), do: {:ok, :ok, state}

  defp application_in_filter?(application, %{application_filter: application_filter})
       when length(application_filter) > 0 do
    Enum.member?(application_filter, application)
  end

  defp application_in_filter?(_, _), do: true

  defp application_in_reject?(application, %{application_reject: application_filter})
       when length(application_filter) > 0 do
    Enum.member?(application_filter, application)
  end

  defp application_in_reject?(_, _), do: false

  defp message_in_reject?(_message, %{message_reject: nil}), do: false
  defp message_in_reject?(message, %{message_reject: callback}), do: callback.(message)
end
