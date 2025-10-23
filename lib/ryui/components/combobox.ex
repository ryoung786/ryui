defmodule Ryui.Combobox do
  use RyuiWeb, :html

  @doc """
  """
  def combobox(assigns) do
    unique_id = Base.url_encode64(:crypto.strong_rand_bytes(8), padding: false)
    assigns = assign_new(assigns, :id, fn -> unique_id end)

    ~H"""
    <.live_component module={Ryui.ComboboxLiveComponent} id={@id} search_fn={@search_fn} />
    """
  end
end
