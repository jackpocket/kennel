defmodule Kennel.Filter do
  def include_error_metadata(%{level: :error} = log_event, config) do
    translators = Keyword.fetch!(config, :translators)
    translated_log = Logger.Utils.translator(log_event, %{translators: translators})

    message =
      case log_event.msg do
        {:string, message} -> to_string(message)
        _ -> msg_from_translated_log(translated_log)
      end

    meta = log_event.meta
    {kind, meta} = Map.pop(meta, :error_kind)
    {stacktrace, meta} = Map.pop(meta, :error_stacktrace)

    meta =
      cond do
        is_binary(meta[:error]) -> Map.merge(meta, %{error_reason: meta[:error], error: []})
        is_list(meta[:error]) or is_map(meta[:error]) -> meta
        true -> Map.put(meta, :error, [])
      end

    error_metadata = Map.get(meta, :error)

    message = error_metadata[:message] || message

    kind =
      kind || error_metadata[:kind] || kind_from_translated_log(translated_log) || "LoggedError"

    stack =
      stacktrace || error_metadata[:stack] || stack_from_translated_log(translated_log) ||
        stacktrace()

    error_metadata = [
      message: message,
      kind: kind,
      stack: stack
    ]

    %{log_event | meta: Map.put(meta, :error, error_metadata)}
  rescue
    error ->
      error_metadata = [
        message: "#{__MODULE__} crashed",
        kind: "#{__MODULE__}Error"
      ]

      meta =
        log_event.meta
        |> Map.put(:error, error_metadata)
        |> Map.put(:error_reason, inspect(error))

      %{log_event | meta: meta}
  end

  def include_error_metadata(log_event, _), do: log_event

  defp msg_from_translated_log(%{msg: {:report, report}}) do
    case report[:elixir_translation] do
      nil -> "Error! check the log"
      translation -> to_string(translation)
    end
  end

  defp msg_from_translated_log(%{msg: {:string, message}}) do
    to_string(message)
  end

  defp msg_from_translated_log(_), do: "Error! check the log"

  defp kind_from_translated_log(%{meta: %{crash_reason: {%kind{}, _stack}}}) do
    inspect(kind)
  end

  defp kind_from_translated_log(_), do: nil

  defp stack_from_translated_log(%{meta: %{crash_reason: {error, stack}}}),
    do: Exception.format(:error, error, stack)

  defp stack_from_translated_log(_), do: nil

  defp stacktrace do
    {:current_stacktrace, stacktrace} = Process.info(self(), :current_stacktrace)

    stacktrace
    |> Enum.drop(6)
    |> Exception.format_stacktrace()
  end
end
