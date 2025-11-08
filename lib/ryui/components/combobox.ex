defmodule Ryui.Combobox do
  use RyuiWeb, :html

  @doc """
  """
  attr :id, :string, default: nil
  attr :name, :string
  attr :listbox_class, :string, default: nil
  attr :options, :list, default: []
  attr :field, :any, default: nil
  attr :errors, :list, default: []
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  slot :option do
    attr :value, :string, required: true
    attr :chip_text, :string, required: true
  end

  def combobox(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(field.errors, &translate_error(&1)))
    |> assign_new(:name, fn -> field.name <> "[]" end)
    |> combobox()
  end

  def combobox(assigns) do
    assigns = assign_new(assigns, :name, fn -> "combobox-select" end)

    ~H"""
    <div id={@id} phx-hook="ComboboxHook">
      <select id={@id <> "-select"} name={@name} multiple hidden phx-update="ignore"></select>

      <form class="inline-block w-full">
        <label
          class={["input w-full", @errors != [] && "input-error"]}
          style={"anchor-name:--#{@id}-anchor"}
        >
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
        <p :for={msg <- @errors} class="mt-1.5 flex gap-2 items-center text-sm text-error">
          <.icon name="hero-exclamation-circle" class="size-5" />{msg}
        </p>
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
          class="inline-block text-xs bg-primary/50 text-base-content rounded-sm px-1 cursor-pointer"
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
