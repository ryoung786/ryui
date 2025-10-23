defmodule Ryui.Modal do
  use RyuiWeb, :html

  @doc """
  Modal with a close button in the top right.

  Use something like `<button onclick="my_modal.showModal()">open modal</button>` to show the modal.

  Note that id must not contain hyphens, it must be a valid javascript variable name.
  """
  def modal(assigns) do
    ~H"""
    <script :type={Phoenix.LiveView.ColocatedHook} name=".Modal">
      export default {
        mounted() {
          window.addEventListener("backoffice:close-modal", (e) => {
            this.el.close()
          });
        }
      }
    </script>
    <dialog id={@id} class="modal" phx-hook=".Modal">
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

  def close_modal(js \\ %JS{}), do: JS.dispatch(js, "backoffice:close-modal")
end
