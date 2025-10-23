defmodule Ryui.ComboboxLiveComponent do
  use RyuiWeb, :live_component

  import RyuiWeb.CoreComponents

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:selections, fn -> [] end)
      |> assign_new(:search_fn, fn -> &search/1 end)

    socket = socket |> assign_new(:options, fn -> socket.assigns.search_fn.("") end)
    {:ok, socket}
  end

  def handle_event("selected", %{"value" => value}, socket) do
    {:noreply, assign(socket, selections: socket.assigns.selections ++ [value])}
  end

  def handle_event("deselected", %{"value" => value}, socket) do
    selections = List.delete(socket.assigns.selections, value)
    {:noreply, assign(socket, selections: selections)}
  end

  def handle_event("search", %{"search-text" => q}, socket) do
    {:noreply, assign(socket, options: socket.assigns.search_fn.(q))}
  end

  defp search(_q) do
    [{"Foo", "foo"}, {"Bar", "bar"}, {"Baz", "baz"}]
  end

  def chip(assigns) do
    ~H"""
    <span
      class="selected-chip bg-red-200 text-black rounded-sm px-1 cursor-pointer"
      phx-click={
        JS.dispatch("ryui:combobox:remove-selection", detail: @value)
        |> JS.push("deselected", value: %{value: @value}, target: @myself)
      }
      data-chip-value={@value}
    >
      {render_slot(@inner_block)}
    </span>
    """
  end
end
