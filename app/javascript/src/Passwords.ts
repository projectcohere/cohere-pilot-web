import { IComponent } from "./Component"

// -- impls --
export class Passwords implements IComponent {
  isDocumentDependent = true

  // -- props --
  private $password: HTMLInputElement

  // -- lifecycle --
  private onMount() {
    this.$password = this.findPasswordInput()
    if (this.$password == null) {
      return
    }

    const $showPassword = document.getElementById("show_password")
    $showPassword.addEventListener("change", this.didChangeShowPassword.bind(this))
  }

  // -- elements --
  private findPasswordInput(): HTMLInputElement | null {
    let $password = document.getElementById("session_password")

    if ($password == null) {
      $password = document.getElementById("password_reset_password")
    }

    return $password as HTMLInputElement
  }

  // -- events --
  private didChangeShowPassword(event: Event) {
    const $showPassword = event.target as HTMLInputElement
    const inputType = $showPassword.checked ? "text" : "password"

    this.$password.setAttribute("type", inputType)
  }

  // -- IComponent --
  start() {
    this.onMount()
  }
}
