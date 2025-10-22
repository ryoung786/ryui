defmodule Ryui.Sidebar do
  use RyuiWeb, :html

  embed_templates "sidebar.html"

  attr :id, :string, default: Base.url_encode64(:crypto.strong_rand_bytes(8), padding: false)
  slot :sidebar_content, required: true
  slot :inner_block, required: true
  def sidebar(assigns)
end
