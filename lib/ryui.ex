defmodule Ryui do
  @moduledoc """
  Ryui keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  defdelegate details(assigns), to: Ryui.Details
  defdelegate tooltip(assigns), to: Ryui.Tooltip
  defdelegate sidebar(assigns), to: Ryui.Sidebar
end
