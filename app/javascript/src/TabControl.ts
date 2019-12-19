import { IComponent } from "./Component"

// -- constants --
const kQueryFilters = ".Filter"
const kQueryTabs = ".Panel-tab"
const kClassSelected = "is-selected"
const kClassVisible = "is-visible"

// -- impls --
export class TabControl implements IComponent {
  isOnLoad = true

  // -- props --
  private $tabs: HTMLElement[]
  private $filters: HTMLLinkElement[]

  // -- IComponent --
  start() {
    const $tabs = document.querySelectorAll<HTMLElement>(kQueryTabs)
    if ($tabs.length === 0) {
      return
    }

    // capture elements
    this.$tabs = Array.from($tabs)
    this.$filters = Array.from(document.querySelectorAll(kQueryFilters))

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
