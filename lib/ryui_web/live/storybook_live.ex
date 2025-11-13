defmodule RyuiWeb.StorybookLive do
  use RyuiWeb, :live_view

  import Ryui
  alias RyuiWeb.Live.Countries

  @impl true
  def mount(_, _session, socket) do
    countries = Countries.search("")

    {:ok,
     socket
     |> assign(
       countries0: countries,
       countries1: countries,
       countries2: countries,
       combobox_form: to_form(Countries.changeset(), as: :countries)
     )}
  end

  @impl true
  def handle_event("search", %{"search-text" => q}, socket) do
    {:noreply, assign(socket, countries0: Countries.search(q))}
  end

  def handle_event("search1", %{"search-text" => q}, socket) do
    {:noreply, assign(socket, countries1: Countries.search(q))}
  end

  def handle_event("search2", %{"search-text" => q}, socket) do
    {:noreply, assign(socket, countries2: Countries.search(q))}
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

  defp source(assigns) do
    ~H|<a
  class="link link-primary not-italic"
  href={"https://github.com/ryoung786/ryui/blob/main/lib/ryui/components/#{@href}"}
>
  Source
</a>|
  end
end
