import { IComponent, start } from "../src/Component"

// TODO: separate packs include duplicate dependencies, which we don't
// really want to do.

// -- impls --
class Flash implements IComponent {
  // -- lifecycle --
  private onMount() {
    const flash = document.getElementById("flash")
    if (flash != null) {
      setTimeout(() => {
        flash.classList.add("is-hidden")
      }, 5000)
    }
  }

  // -- IComponent --
  start() {
    this.onMount()
  }
}

// -- main --
start(
  new Flash()
)
