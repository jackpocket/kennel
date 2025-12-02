defmodule Kennel                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     do
  @moduledoc """
  Filter for logger to include error metadata in log events.
  """

  @doc """

  ## Examples

      iex> Kennel.include_error_metadata(:error, [])
      :error

  """
  def include_error_metadata(error_level, config) do
    Kennel.Filter.include_error_metadata(error_level, config)
  end
end
