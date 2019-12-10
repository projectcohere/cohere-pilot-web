import { IComponent } from "./Component"

// -- constants --
const kQueryFilters = ".EditCase .Filter"
const kQueryTabs = ".EditCase .Form-tab"
const kClassSelected = "is-selected"
const kClassVisible = "is-visible"

// -- impls --
export class EditCase implements IComponent {
  isOnLoad = true

  // -- props --
  private $filters: HTMLLinkElement[]
  private $tabs: HTMLElement[]

  // -- IComponent --
  start() {
    const $filters = document.querySelectorAll<HTMLLinkElement>(kQueryFilters)
    if ($filters.length == 0) {
      return
    }

    // query elements
    this.$filters = Array.from($filters)
    this.$tabs = Array.from(document.querySelectorAll(kQueryTabs))

    // bind events
    for (const $filter of this.$filters) {
      $filter.addEventListener("click", this.didClickFilter.bind(this))
    }
  }

  cleanup() {
    this.$filters = null
    this.$tabs = null
  }

  // -- events --
  private didClickFilter(event: Event) {
    event.preventDefault()

    const clicked = event.target as HTMLLinkElement

    // select the filter
    for (const $filter of this.$filters) {
      $filter.classList.toggle(kClassSelected, $filter == clicked)
    }

    // get the query params
    const location = clicked as unknown as Location
    const id = location.hash.slice(1)

    // show the matching tab
    for (const $tab of this.$tabs) {
      $tab.classList.toggle(kClassVisible, $tab.id === id)
    }
  }
}
