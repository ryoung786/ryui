defmodule Ryui.Tooltip do
  use RyuiWeb, :html

  @doc """
  On hover, a tooltip slides out containing either text or full html content.

  Ex:
      <.tooltip position="right" tip="World">
        <button>Hello</button>
      </.tooltip>
  """
  attr :position, :string, default: "top"
  attr :tip, :string, default: nil
  slot :tooltip_content
  slot :inner_block, required: true

  def tooltip(assigns) do
    {position, translate_from_origin} =
      case assigns[:position] do
        "left" -> {"left", "translate-x-1"}
        "right" -> {"right", "-translate-x-1"}
        "bottom" -> {"bottom", "-translate-y-1"}
        _ -> {"top", "translate-y-1"}
      end

    unique_id = Base.url_encode64(:crypto.strong_rand_bytes(8), padding: false)

    assigns =
      assign(assigns,
        anchor: "--#{unique_id}--tooltip-anchor",
        translate_from_origin: translate_from_origin,
        position: position
      )

    ~H"""
    <div class="group/tooltip inline-block w-fit">
      <div class="inline-block" style={"anchor-name: #{@anchor};"}>
        {render_slot(@inner_block)}
      </div>

      <div
        class={[
          "fixed bg-slate-600 text-white text-xs p-2 rounded z-99 pointer-events-none",
          "mx-2 my-1 max-w-100 size-max",
          "transition-[opacity_translate] duration-300 opacity-0 #{@translate_from_origin} group-hover/tooltip:opacity-100 group-hover/tooltip:translate-0"
        ]}
        style={["position-anchor: #{@anchor}; position-area: #{@position} center;"]}
        role="tooltip"
      >
        {@tip || render_slot(@tooltip_content)}

        {# Make sure the arrows point in the correct direction }
        <%= case @position do %>
          <% "bottom" -> %>
            <div class="absolute -top-1 left-1/2 -translate-x-1/2 size-2 rotate-45 bg-slate-600" />
          <% "top" -> %>
            <div class="absolute -bottom-1 left-1/2 -translate-x-1/2 size-2 rotate-45 bg-slate-600" />
          <% "right" -> %>
            <div class="absolute -left-1 top-1/2 -translate-y-1/2 size-2 rotate-45 bg-slate-600" />
          <% "left" -> %>
            <div class="absolute -right-1 top-1/2 -translate-y-1/2 size-2 rotate-45 bg-slate-600" />
        <% end %>
      </div>
    </div>
    """
  end
end
