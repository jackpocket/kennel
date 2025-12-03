defmodule Kennel                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     do
  @moduledoc """
  Filter for logger to include error metadata in log events.
  """

  @doc """
  Entry point for including error metadata in log events.
  """
  def include_error_metadata(log_event, config) do
    Kennel.Filter.include_error_metadata(log_event, config)
  end
end
