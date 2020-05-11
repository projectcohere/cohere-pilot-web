import { kClassVisible } from "./Constants"

// -- constants --
const kClassConfirm = "Modal-confirm"
const kClassCancel = "Modal-cancel"

// -- impls --
export class Modal {
  // -- props --
  private $el: HTMLElement
  private $confirm: HTMLElement

  // -- lifetime --
  constructor(show: string, modal: string) {
    // capture elements
    this.$el = document.getElementById(modal)!
    this.$confirm = this.$el.querySelector(`.${kClassConfirm}`) as HTMLElement

    // subscribe to events
    const $show = document.getElementById(show)!
    $show.addEventListener("click", this.didShow.bind(this))

    const $cancel = this.$el.querySelector(`.${kClassCancel}`) as HTMLElement
    $cancel.addEventListener("click", this.didCancel.bind(this))
  }

  // -- commands --
  show() {
    this.$el.classList.toggle(kClassVisible, true)
  }

  hide() {
    this.$el.classList.toggle(kClassVisible, false)
  }

  // -- events --
  onConfirm(handler: () => void) {
    this.$confirm.addEventListener("click", handler)
  }

  private didShow(event: Event) {
    event.preventDefault()
    this.show()
  }

  private didCancel(event: Event) {
    event.preventDefault()
    this.hide()
  }
}
