defmodule KennelTest do
  use ExUnit.Case
  doctest Kennel

  # this test sets up LoggerTestHelpers.log_event_handler/1 so it's recommended to run in async: false
  use ExUnit.Case, async: false
  alias Kennel

  require Logger

  @moduletag capture_log: true

  setup {LoggerTestHelpers, :log_event_handler}

  setup do
    translators = Application.fetch_env!(:logger, :translators)

    :logger.add_primary_filter(
      :kennel,
      {&Kennel.include_error_metadata/2, [translators: translators]}
    )

    on_exit(fn ->
      :logger.remove_primary_filter(:kennel)
    end)
  end

  describe "default error tags" do
    setup do
      Logger.error("boom")
      assert_receive {:logged_event, log}
      %{log: log}
    end

    test "error.message", %{log: log} do
      assert log.meta.error[:message] == "boom"
    end

    test "error.stack", %{log: log} do
      assert log.meta.error[:stack] =~ inspect(__MODULE__)
    end

    test "error.kind", %{log: log} do
      assert log.meta.error[:kind] == "LoggedError"
    end

    test "preserves error metadata if already set" do
      Logger.error("boom", error: "My Error Reason")
      assert_receive {:logged_event, log}
      assert log.meta.error_reason == "My Error Reason"
      assert log.meta.error[:message] == "boom"
    end
  end

  describe "custom error tags" do
    setup do
      Logger.error("boom", error_kind: "CustomError", error_stacktrace: "CustomStacktrace")
      assert_receive {:logged_event, log}
      %{log: log}
    end

    test "error.kind", %{log: log} do
      assert log.meta.error[:kind] == "CustomError"
    end

    test "error.stacktrace", %{log: log} do
      assert log.meta.error[:stack] == "CustomStacktrace"
    end
  end

  describe "preserves error metadata if already set" do
    setup do
      Logger.error("boom",
        error: %{message: "CustomMessage", kind: "CustomError", stack: "CustomStacktrace"}
      )

      assert_receive {:logged_event, log}
      %{log: log}
    end

    test "error.kind", %{log: log} do
      assert log.meta.error[:kind] == "CustomError"
    end

    test "error.stacktrace", %{log: log} do
      assert log.meta.error[:stack] == "CustomStacktrace"
    end

    test "error.message", %{log: log} do
      assert log.meta.error[:message] == "CustomMessage"
    end
  end

  describe "when log message is IO data" do
    test "converts to string in metadata" do
      Logger.error(["hello", [32], [["world"]]])
      assert_receive {:logged_event, log}

      assert log.meta.error[:message] == "hello world"
    end
  end

  describe "Process crashes" do
    test "undefined function" do
      # to avoid warning from compiler about `apply/3` function
      args = Enum.to_list(0..1)
      {:ok, task_pid} = Task.start(fn -> apply(Foo, :bar, args) end)

      assert_receive {:logged_event, log}

      assert log.meta.error[:message] =~
               "Task #{inspect(task_pid)} started from #{inspect(self())} terminating"

      assert log.meta.error[:stack] =~ "Foo.bar/2"
      assert log.meta.error[:kind] == "UndefinedFunctionError"
    end

    test "undefined function clause" do
      # to avoid compiler catching type error
      error_atom = String.to_existing_atom("error")
      {:ok, task_pid} = Task.start(fn -> undef_fun_clause(error_atom) end)

      assert_receive {:logged_event, log}

      assert log.meta.error[:message] =~
               "Task #{inspect(task_pid)} started from #{inspect(self())} terminating"

      assert log.meta.error[:stack] =~ "undef_fun_clause/1"
      assert log.meta.error[:kind] == "FunctionClauseError"
    end

    defp undef_fun_clause(:ok), do: :ok
  end

  describe "Kennel crashes" do
    test "crashes" do
      Logger.error("boom", error: %URI{})
      assert_receive {:logged_event, log}
      assert log.meta.error[:message] == "Elixir.Kennel.Filter crashed"
      assert log.meta.error[:kind] == "Elixir.Kennel.FilterError"
      assert log.meta.error_reason =~ "UndefinedFunctionError"
    end
  end
end
