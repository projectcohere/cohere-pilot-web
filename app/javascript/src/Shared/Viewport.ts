import { IComponent } from "../Core"

export class Viewport implements IComponent {
  // -- props --
  private listener: (() => void) | null = null

  // -- IComponent --
  start() {
    this.didResizeWindow()
    this.listener = this.didResizeWindow.bind(this)
    window.addEventListener("resize", this.listener)
  }

  cleanup() {
    if (this.listener != null) {
      window.removeEventListener("resize", this.listener)
      this.listener = null
    }
  }

  // -- events --
  private didResizeWindow() {
    const vh = window.innerHeight / 100
    document.documentElement.style.setProperty("--vh", `${vh}px`)
  }
}
