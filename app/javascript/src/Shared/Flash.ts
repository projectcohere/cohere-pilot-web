import { IComponent } from "../Core"
import { kClassHidden } from "./Constants"

// -- constants --
const kIdFlash = "flash"

// -- impls --
export class Flash implements IComponent {
  isOnLoad = true

  // -- IComponent --
  start() {
    const $flash = document.getElementById(kIdFlash)

    if ($flash != null) {
      setTimeout(() => {
        $flash.classList.add(kClassHidden)
      }, 5000)
    }
  }
}
