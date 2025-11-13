defmodule Ryui.Modal do
  @moduledoc """
  Modal with a close button in the top right.

  Use something like `<button onclick="my_modal.showModal()">open modal</button>` to show the modal.

  Note that id must not contain hyphens, it must be a valid javascript variable name.
  """
  use RyuiWeb, :html

  def modal(assigns) do
    ~H"""
    <script :type={Phoenix.LiveView.ColocatedHook} name=".Ryui.Modal">
      export default {
        mounted() {
          this.el.addEventListener("ryui:open-modal", (e) => this.el.showModal());
          this.el.addEventListener("ryui:close-modal", (e) => this.el.close());
        }
      }
    </script>
    <dialog id={@id} class="modal" phx-hook=".Ryui.Modal">
      <div class="modal-box overflow-visible">
        <button
          class="btn btn-sm btn-circle btn-ghost absolute right-2 top-2"
          phx-click={close_modal()}
        >
          ✕
        </button>
        {render_slot(@inner_block)}
      </div>
      <div class="modal-backdrop">
        <button
          class="[.modal-backdrop_&]:cursor-default"
          phx-click={close_modal()}
        >
          close
        </button>
      </div>
    </dialog>
    """
  end

  def open_modal(js \\ %JS{}, target), do: JS.dispatch(js, "ryui:open-modal", to: target)
  def close_modal(js \\ %JS{}), do: JS.dispatch(js, "ryui:close-modal")
end
