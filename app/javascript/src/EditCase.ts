import { IComponent } from "./Component"

// -- constants --
const kClassFilter = "Filter"
const kClassTab = "Form-tab"
const kClassSelected = "is-selected"
const kClassVisible = "is-visible"

// -- impls --
export class EditCase implements IComponent {
  isDocumentDependent = true

  // -- props --
  private $filters: HTMLLinkElement[]
  private $tabs: HTMLElement[]

  // -- IComponent --
  start() {
    const $filters = document.querySelectorAll<HTMLLinkElement>(`.${kClassFilter}`)
    if ($filters.length == 0) {
      return
    }

    // query elements
    this.$filters = Array.from($filters)
    this.$tabs = Array.from(document.querySelectorAll(`.${kClassTab}`))

    // bind events
    for (const $filter of this.$filters) {
      $filter.addEventListener("click", this.didClickFilter.bind(this))
    }
  }

  // -- events --
  private didClickFilter(event: Event) {
    const clicked = event.target as HTMLLinkElement

    // select the clicked filter
    for (const $filter of this.$filters) {
      $filter.classList.toggle(kClassSelected, $filter == clicked)
    }

    // show the tab with the matching id
    const location = clicked as unknown as Location
    const id = location.hash.substr(1)

    for (const $tab of this.$tabs) {
      $tab.classList.toggle(kClassVisible, $tab.id === id)
    }

    event.preventDefault()
  }
}
