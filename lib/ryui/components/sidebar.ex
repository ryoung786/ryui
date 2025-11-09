defmodule Ryui.Sidebar do
  use RyuiWeb, :html

  embed_templates "sidebar.html"

  def toggle(js \\ %JS{}) do
    JS.toggle_attribute(js, {"open", true}, to: "#sidebar")
  end

  defp item(assigns) do
    ~H"""
    <li><a href={@href} phx-click={toggle()}>{render_slot(@inner_block)}</a></li>
    """
  end
end
