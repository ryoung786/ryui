// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { hooks as colocatedHooks } from "phoenix-colocated/ryui";
import topbar from "../vendor/topbar";

ComboboxHook = {
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

    window.addEventListener("ryui:combobox:toggle-listbox", (e) => {
      if (!this.el.contains(e.target)) return;
      if (e.detail === "show") {
        this.listboxEl.showPopover();
      } else if (e.detail === "hide") {
        this.timeout = setTimeout(() => this.listboxEl.hidePopover(), 150);
      }
    });

    window.addEventListener("ryui:combobox:add-selection", (e) => {
      if (!this.el.contains(e.target)) return;
      this.select(e.target);
    });

    window.addEventListener("ryui:combobox:remove-selection", (e) => {
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
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        this.index = (this.index - 1 + items.length) % items.length;
        this.updateHighlight();
      } else if (e.key === "Enter") {
        e.preventDefault();
        const selected = items[this.index];
        if (selected) this.select(selected);
      } else if (e.key === "Backspace") {
        if (this.inputEl.value === "") {
          e.preventDefault();
          const chip = this.el.querySelector(".selected-chips > :last-child");
          if (chip) this.deselect(chip);
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
      active.scrollIntoView({ block: "nearest" });
    } else {
      this.inputEl.removeAttribute("aria-activedescendant");
    }
  },

  is_selected(value) {
    return !!this.selectEl.querySelector(`option[data-value="${value}"]`);
  },

  select(item) {
    clearTimeout(this.timeout); // keeps the dropdown open and visible

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
    clearTimeout(this.timeout); // keeps the dropdown open and visible
    const value = chip.dataset.value;
    chip.remove();
    const option = this.selectEl.querySelector(`option[data-value="${value}"]`);
    option.remove();
  },
};

const csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: window.location.host.startsWith("localhost")
    ? undefined
    : 3000,
  params: { _csrf_token: csrfToken },
  hooks: { ComboboxHook, ...colocatedHooks },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener(
    "phx:live_reload:attached",
    ({ detail: reloader }) => {
      // Enable server log streaming to client.
      // Disable with reloader.disableServerLogs()
      reloader.enableServerLogs();

      // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
      //
      //   * click with "c" key pressed to open at caller location
      //   * click with "d" key pressed to open at function component definition location
      let keyDown;
      window.addEventListener("keydown", (e) => (keyDown = e.key));
      window.addEventListener("keyup", (e) => (keyDown = null));
      window.addEventListener(
        "click",
        (e) => {
          if (keyDown === "c") {
            e.preventDefault();
            e.stopImmediatePropagation();
            reloader.openEditorAtCaller(e.target);
          } else if (keyDown === "d") {
            e.preventDefault();
            e.stopImmediatePropagation();
            reloader.openEditorAtDef(e.target);
          }
        },
        true,
      );

      window.liveReloader = reloader;
    },
  );
}
