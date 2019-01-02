defmodule ExLoggerMock.BackendTest do
  @moduledoc "Tests for the Backend module"

  use ExUnit.Case, async: true

  alias ExLoggerMock.Backend

  @state %{name: "ex_logger_mock"}
  @timestamp {{2019, 1, 1}, {0, 0, 0, 0}}

  describe "init/1" do
    test "saves the name in the state" do
      assert Backend.init({Backend, "ex_logger_mock"}) == {:ok, @state}
    end
  end

  describe "handle_event/2" do
    test "sends a message back with the log details" do
      pid = self()
      metadata = [pid: pid]

      assert Backend.handle_event(
               {:info, pid, {Logger, "log message", @timestamp, metadata}},
               @state
             ) == {:ok, @state}

      assert_receive {:ex_logger_mock, {:info, "log message", @timestamp, ^metadata}}
    end

    test "ignores messages when we are not the group leader" do
      pid = spawn(fn -> nil end)
      metadata = [pid: pid]

      assert Backend.handle_event(
               {:info, pid, {Logger, "log message", @timestamp, metadata}},
               @state
             ) == {:ok, @state}

      refute_receive {:ex_logger_mock, _}
    end

    test "ignores other kinds of events" do
      assert Backend.handle_event(:flush, @state) == {:ok, @state}

      refute_receive {:ex_logger_mock, _}
    end
  end

  describe "handle_call/2" do
    test "ignores the call notifications" do
      assert Backend.handle_call({:configure, level: :warn}, @state) == {:ok, :ok, @state}
    end
  end
end
