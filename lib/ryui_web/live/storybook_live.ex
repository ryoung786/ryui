defmodule RyuiWeb.StorybookLive do
  use RyuiWeb, :live_view

  import Ryui

  @impl true
  def mount(_, _session, socket) do
    search_results = search("")
    {:ok, assign(socket, search_results: search_results)}
  end

  @impl true
  def handle_event("search", %{"search-text" => q}, socket) do
    {:noreply, assign(socket, search_results: search(q))}
  end

  def search(q) do
    params = URI.encode_query(%{search: q})
    people = Req.get!("https://swapi.dev/api/people/?#{params}").body["results"]
    Enum.map(people, fn p -> %{name: p["name"], id: p["name"]} end)
  end
end
