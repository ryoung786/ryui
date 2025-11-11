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
  attr :search_event, :string, default: "search"

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
    <script :type={Phoenix.LiveView.ColocatedHook} name=".Combobox">
      export default {
        updated() {
          this.index = 0;
          this.updateHighlight();
        },
        mounted() {
          this.inputEl = this.el.querySelector('input[type="search"]');
          this.selectEl = this.el.querySelector("select");
          this.listboxEl = this.el.querySelector("ul");
          this.index = 0;
          this.updateHighlight();

          document.addEventListener("focusin", (e) => {
            if (this.el.contains(e.target)) {
              this.listboxEl.showPopover();
            } else {
              this.listboxEl.hidePopover();
            }
          });

          this.el.addEventListener("ryui:combobox:hide-listbox", (e) => {
            if (!this.el.contains(e.target)) return;
            this.listboxEl.hidePopover();
          });

          this.el.addEventListener("ryui:combobox:add-selection", (e) => {
            if (!this.el.contains(e.target)) return;
            this.select(e.target);
          });

          this.el.addEventListener("ryui:combobox:remove-selection", (e) => {
            if (!this.el.contains(e.target)) return;
            this.deselect(e.target);
          });

          this.inputEl.addEventListener("keydown", (e) => {
            const items = Array.from(
              this.listboxEl.querySelectorAll('[role="option"]'),
            );
            if (!items.length) return;

            if (e.key === "ArrowDown") {
              e.preventDefault();
              this.index = (this.index + 1) % items.length;
              this.updateHighlight();
              this.listboxEl.showPopover();
            } else if (e.key === "ArrowUp") {
              e.preventDefault();
              this.index = (this.index - 1 + items.length) % items.length;
              this.updateHighlight();
            } else if (e.key === "Enter") {
              e.preventDefault();
              if (this.listboxEl.matches(":popover-open")) {
                const selected = items[this.index];
                if (selected) this.select(selected);
              }
            } else if (e.key === "Backspace") {
              if (this.inputEl.selectionStart === 0) {
                e.preventDefault();
                const chip = this.el.querySelector(".selected-chips > :last-child");
                if (chip) this.deselect(chip);
              }
            } else if (e.key === "Escape") {
              if (this.inputEl.value === "") this.listboxEl.hidePopover();
            } else {
              if (!this.listboxEl.matches(":popover-open")) {
                this.listboxEl.showPopover();
              }
            }
          });
        },

        updateHighlight() {
          const items = Array.from(
            this.listboxEl.querySelectorAll('[role="option"]'),
          );

          items.forEach((el, i) => {
            el.classList.toggle("highlighted", i === this.index);
            el.setAttribute("aria-selected", i === this.index);
          });

          const active = items[this.index];
          if (active) {
            this.inputEl.setAttribute("aria-activedescendant", active.id);
          } else {
            this.inputEl.removeAttribute("aria-activedescendant");
          }
        },

        is_selected(value) {
          return !!this.selectEl.querySelector(`option[data-value="${value}"]`);
        },

        select(item) {
          const value = item.dataset.value;
          const chip_text = item.dataset.chipText;

          // if we've already selected this item, do nothing
          if (this.is_selected(value)) return this.inputEl.focus();

          // add to hidden select
          const el = document.createElement("option");
          el.setAttribute("selected", "true");
          el.setAttribute("data-value", value);
          el.textContent = value;
          this.selectEl.appendChild(el);

          // add chip
          const parent = this.el.querySelector(".selected-chips");
          const template = this.el.querySelector("template");
          const clone = template.content.cloneNode(true);
          let chip = clone.querySelector("span");
          chip.textContent = chip_text;
          chip.setAttribute("data-value", value);
          parent.appendChild(clone);

          this.selectEl.dispatchEvent(new Event("change", { bubbles: true }));
          this.inputEl.focus();
        },

        deselect(chip) {
          const value = chip.dataset.value;
          chip.remove();
          const option = this.selectEl.querySelector(`option[data-value="${value}"]`);
          option.remove();
          this.selectEl.dispatchEvent(new Event("change", { bubbles: true }));
        }
      }
    </script>
    <div
      id={@id}
      phx-hook=".Combobox"
      phx-click-away={JS.dispatch("ryui:combobox:hide-listbox")}
    >
      <style>
        @scope {
          @position-try --ryui-above {
            inset: unset;
            bottom: anchor(top);
            left: anchor(left);
          }

          input[type="search"]::-webkit-search-decoration,
          input[type="search"]::-webkit-search-cancel-button,
          input[type="search"]::-webkit-search-results-button,
          input[type="search"]::-webkit-search-results-decoration {
            display: none;
          }

          input[type="search"] {
            -moz-appearance: textfield;
          }
        }
      </style>
      <select id={@id <> "-select"} name={@name} multiple hidden phx-update="ignore"></select>

      <form class="inline-block w-full">
        <label
          class={["input w-full h-auto p-2", @errors != [] && "input-error"]}
          style={"anchor-name:--#{@id}-anchor"}
        >
          <div class="flex flex-wrap flex-1 gap-1 w-full items-center">
            <div
              id={@id <> "-selected-chips"}
              class="selected-chips contents"
              phx-update="ignore"
            >
            </div>
            <input
              type="search"
              name="search-text"
              class="grow w-20"
              autocomplete="off"
              placeholder="Search"
              phx-debounce={120}
              phx-change={@search_event}
              role="combobox"
              aria-controls={@id <> "-listbox"}
              aria-expanded="false"
              aria-autocomplete="list"
            />
          </div>
          <.icon name="hero-magnifying-glass" class="w-4 h-4 shrink-0" />
        </label>
        <p :for={msg <- @errors} class="mt-1.5 flex gap-2 items-center text-sm text-error">
          <.icon name="hero-exclamation-circle" class="size-5" />{msg}
        </p>
        <ul
          id={@id <> "-listbox"}
          role="listbox"
          class={[
            "absolute rounded-box bg-base-100 shadow-sm border border-base-content/10 hidden open:block z-99",
            @listbox_class || "menu w-52",
            "transition transition-discrete origin-top",
            "opacity-0 scale-95 starting:open:opacity-0 starting:open:scale-95",
            "open:opacity-100 open:scale-100"
          ]}
          popover="manual"
          style={"position-anchor:--#{@id}-anchor; top: anchor(bottom); left: anchor(left); position-try-fallbacks: --ryui-above;"}
        >
          <.option :for={{name, value} <- @options} name={name} value={value}>
            <%= if @option == [] do %>
              {name}
            <% else %>
              {render_slot(@option, {name, value})}
            <% end %>
          </.option>
          <li :if={Enum.count(@options) == 0} class="italic text-base-content/60 text-center">
            No results
          </li>
        </ul>
      </form>
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
      phx-click={JS.dispatch("ryui:combobox:add-selection")}
      data-value={@value}
      data-chip-text={@name}
      class="cursor-pointer rounded [&.highlighted]:bg-base-content/10"
    >
      <a>{render_slot(@inner_block)}</a>
    </li>
    """
  end
end
