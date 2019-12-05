import { IComponent } from "./Component"

// -- impls --
export class Flash implements IComponent {
  isDocumentDependent = true

  // -- IComponent --
  start() {
    const $flash = document.getElementById("flash")

    if ($flash != null) {
      setTimeout(() => {
        $flash.classList.add("is-hidden")
      }, 5000)
    }
  }
}
