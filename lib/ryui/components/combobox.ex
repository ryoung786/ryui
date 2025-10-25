defmodule Ryui.Combobox do
  use RyuiWeb, :html

  @doc """
  """
  attr :id, :string, required: true
  attr :listbox_class, :string, default: nil
  attr :options, :list, default: []

  slot :option do
    attr :value, :string, required: true
    attr :chip_text, :string, required: true
  end

  def combobox(assigns) do
    ~H"""
    <div id={@id} phx-hook="ComboboxHook">
      <select id={@id <> "-select"} name="myselect[]" multiple hidden phx-update="ignore"></select>

      <form class="inline-block w-full">
        <label class="input w-full" style={"anchor-name:--#{@id}-anchor"}>
          <div class="flex w-full items-center">
            <div
              id={@id <> "-selected-chips"}
              class="selected-chips inline-block has-[span]:mr-2"
              phx-update="ignore"
            >
            </div>
            <input
              type="search"
              name="search-text"
              class="grow"
              autocomplete="off"
              placeholder="Search"
              phx-debounce={120}
              phx-change="search"
              phx-focus={JS.dispatch("ryui:combobox:toggle-listbox", detail: "show")}
              phx-blur={JS.dispatch("ryui:combobox:toggle-listbox", detail: "hide")}
              role="combobox"
              aria-controls={@id <> "-listbox"}
              aria-expanded="false"
              aria-autocomplete="list"
            />
          </div>
          <.icon name="hero-magnifying-glass" class="w-4 h-4" />
        </label>
      </form>
      <ul
        id={@id <> "-listbox"}
        role="listbox"
        class={[
          "absolute rounded-box bg-base-100 shadow-sm border border-base-content/10 hidden open:block z-99",
          @listbox_class || "menu w-52"
        ]}
        popover="manual"
        style={"position-anchor:--#{@id}-anchor; top: anchor(bottom); left: anchor(left);"}
      >
        <.option :for={{name, value} <- @options} name={name} value={value}>
          <%= if @option == [] do %>
            {name}
          <% else %>
            {render_slot(@option, {name, value})}
          <% end %>
        </.option>
      </ul>
      <template>
        <span
          class="inline-block text-xs bg-red-200 text-black rounded-sm px-1 cursor-pointer"
          phx-click={JS.dispatch("ryui:combobox:remove-selection")}
        >
        </span>
      </template>
    </div>
    """
  end

  def option(assigns) do
    ~H"""
    <li
      role="option"
      phx-click={JS.dispatch("ryui:combobox:add-selection", detail: @value)}
      data-value={@value}
      data-chip-text={@name}
      class="cursor-pointer rounded [&.highlighted]:bg-base-content/10"
    >
      <a>{render_slot(@inner_block)}</a>
    </li>
    """
  end
end
