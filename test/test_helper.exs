ExUnit.start()

defmodule LoggerTestHelpers do
  @moduledoc """
  Test helpers to test logged events.

  Reasoning:

  Built-in to `ExUnit.CaptureLog` functions `capture_log/2` and `with_log/2`
  do not provide with a way to efficiently assert on metadata, unless we format
  those metadata specifically into the log message, which makes the whole
  testing logs experience clumsy.
  """
  import ExUnit.Callbacks, only: [on_exit: 1]

  @doc """
  Simple handler that just sends the log event to the configured `:test_pid`.
  """
  def log(log_event, config) do
    send(config.test_pid, {:logged_event, log_event})
  end

  @doc """
  Test setup helper that attaches the handler

  ## Example

      defmodule MyTest do
        use ExUnit.Case, async: false

        setup {LoggerTestHelpers, :log_event_handler}

        test "logs metadata" do
          Logger.error("boom", foo: "bar")

          assert_receive {:logged_event, log}

          assert log.meta.foo == "bar"
        end
      end
  """
  def log_event_handler(ctx) do
    if ctx.async == true do
      IO.warn("""
      #{ctx.test}
      runs in async mode and tries to modify global Logger level.
      That could lead to intermittent garbage in the test suite output.

      Make sure the test runs with `async: false` tag.

      #{ctx.file}##{ctx.line}
      """)
    end

    Logger.configure(level: ctx[:log_level] || :error)
    :logger.add_handler(:test_handler, __MODULE__, %{test_pid: self()})

    on_exit(fn ->
      Logger.configure(level: :critical)
      :logger.remove_handler(:test_handler)
    end)
  end
end