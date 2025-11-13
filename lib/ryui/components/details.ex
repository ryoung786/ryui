defmodule Ryui.Details do
  @moduledoc """
  Expand and collapse with a smooth animation
  """
  use RyuiWeb, :html

  attr :open, :boolean, default: false

  def details(assigns) do
    unique_id = Base.url_encode64(:crypto.strong_rand_bytes(8), padding: false)
    assigns = assign(assigns, id: unique_id)

    ~H"""
    <div id={@id} class="flex flex-col">
      <button
        class={[
          "group/details peer",
          "w-full flex items-center gap-2 text-left cursor-pointer"
        ]}
        phx-click={
          JS.toggle_attribute({"data-open", "true"})
          |> JS.toggle_attribute({"inert", true}, to: "##{@id} .details-content")
        }
        data-open={@open && "true"}
      >
        <span class="grow">{render_slot(@summary)}</span>
        <.icon
          name="hero-chevron-right"
          class="size-4 group-data-[open=true]/details:rotate-90 transition-transform"
        />
      </button>

      <div
        class="details-content grid grid-rows-[0fr] peer-data-[open=true]:grid-rows-[1fr] transition-all duration-300"
        inert={!@open}
      >
        <div class="overflow-y-hidden">
          {render_slot(@inner_block)}
        </div>
      </div>
    </div>
    """
  end
end
