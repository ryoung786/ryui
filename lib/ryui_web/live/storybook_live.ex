defmodule RyuiWeb.StorybookLive do
  use RyuiWeb, :live_view

  import Ryui
  alias RyuiWeb.Live.Countries

  @impl true
  def mount(_, _session, socket) do
    {:ok, assign(socket, countries: Countries.search(""))}
  end

  @impl true
  def handle_event("search", %{"search-text" => q}, socket) do
    {:noreply, assign(socket, countries: Countries.search(q))}
  end

  @impl true
  def handle_event("change", params, socket) do
    IO.inspect(params, label: "params")
    {:noreply, socket}
  end
end
