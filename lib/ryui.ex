defmodule Ryui do
  @moduledoc """
  A convenience wrapper around individual component modules.
  """

  defdelegate details(assigns), to: Ryui.Details
  defdelegate tooltip(assigns), to: Ryui.Tooltip
  defdelegate modal(assigns), to: Ryui.Modal
  defdelegate combobox(assigns), to: Ryui.Combobox
end
