defmodule RyuiWeb.StorybookLive do
  use RyuiWeb, :live_view

  import Ryui
  alias RyuiWeb.Live.Countries

  @impl true
  def mount(_, _session, socket) do
    {:ok,
     assign(socket,
       countries: Countries.search(""),
       combobox_form: to_form(Countries.changeset(), as: :countries)
     )}
  end

  @impl true
  def handle_event("search", %{"search-text" => q}, socket) do
    {:noreply, assign(socket, countries: Countries.search(q))}
  end

  @impl true
  def handle_event("validate", params, socket) do
    form =
      (params["countries"] || %{})
      |> Countries.changeset()
      |> Map.put(:action, :validate)
      |> to_form(as: :countries)

    {:noreply, assign(socket, combobox_form: form)}
  end
end
