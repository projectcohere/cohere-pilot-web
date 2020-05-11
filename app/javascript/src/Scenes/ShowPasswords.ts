import { IComponent } from "../Core"

// -- constants --
const kIdShowPassword = "show_password"
const kIdPassword = "session_password"
const kIdResetPassword = "password_reset_password"

// -- impls --
export class ShowPasswords implements IComponent {
  isOnLoad = true

  // -- props --
  private $password: HTMLInputElement | null = null

  // -- IComponent --
  start() {
    this.$password = this.findPasswordInput()
    if (this.$password == null) {
      return
    }

    const $showPassword = document.getElementById(kIdShowPassword)
    $showPassword!.addEventListener("change", this.didChangeShowPassword.bind(this))
  }

  cleanup() {
    this.$password = null
  }

  // -- queries --
  private findPasswordInput(): HTMLInputElement | null {
    const $password = document.getElementById(kIdPassword) || document.getElementById(kIdResetPassword)
    return $password as HTMLInputElement
  }

  // -- events --
  private didChangeShowPassword(event: Event) {
    const $showPassword = event.target as HTMLInputElement
    const inputType = $showPassword.checked ? "text" : "password"
    this.$password!.setAttribute("type", inputType)
  }
}
