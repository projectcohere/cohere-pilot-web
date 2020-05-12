import { kClassVisible, kClassDisabled, kEventConfirm } from "./Constants"

// -- constants --
const kClassConfirm = "Modal-confirm"
const kClassCancel = "Modal-cancel"

/// -- impls --
export class Modal {
  // -- props/elements
  private $el: HTMLElement
  private $confirm: HTMLButtonElement

  // -- lifetime --
  constructor(show: string, modal: string, enabled: boolean = true) {
    // capture elements
    this.$el = document.getElementById(modal)!

    // subscribe to events
    const $show = document.getElementById(show)!
    $show.addEventListener("click", this.didShow.bind(this))

    this.$confirm = this.$el.querySelector(`.${kClassConfirm}`) as HTMLButtonElement
    this.$confirm.addEventListener("click", this.didConfirm.bind(this))

    const $cancel = this.$el.querySelector(`.${kClassCancel}`) as HTMLButtonElement
    $cancel.addEventListener("click", this.didCancel.bind(this))

    // set default state
    this.setEnabled(enabled)
  }

  // -- commands --
  show() {
    this.$el.classList.toggle(kClassVisible, true)
  }

  hide() {
    this.$el.classList.toggle(kClassVisible, false)
  }

  // -- computed props --
  setEnabled(enabled: boolean) {
    this.$confirm.disabled = !enabled
  }

  // -- events --
  on(event: string, listener: (e: Event) => void) {
    this.$el.addEventListener(event, listener)
  }

  private didShow(event: Event) {
    event.preventDefault()
    this.show()
  }

  private didCancel(event: Event) {
    event.preventDefault()
    this.hide()
  }

  private didConfirm(event: Event) {
    // dispatch confirm event
    const confirm = new Event(kEventConfirm)
    this.$el.dispatchEvent(confirm)

    // prevent click if confirm prevented
    if (confirm.defaultPrevented) {
      event.preventDefault()
    }

    this.hide()
  }
}
