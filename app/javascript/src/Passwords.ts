import { IComponent } from "./Component"

// -- impls --
export class Passwords implements IComponent {
  isOnLoad = true

  // -- props --
  private $password: HTMLInputElement | null = null

  // -- IComponent --
  start() {
    this.$password = this.findPasswordInput()
    if (this.$password == null) {
      return
    }

    const $showPassword = document.getElementById("show_password")
    $showPassword!.addEventListener("change", this.didChangeShowPassword.bind(this))
  }

  cleanup() {
    this.$password = null
  }

  // -- queries --
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

    this.$password!.setAttribute("type", inputType)
  }
}
