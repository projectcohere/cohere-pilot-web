import { IComponent } from "../Core"
import { kClassVisible } from "src/Shared/Constants"

// -- constants --
const kIdStatsQuotes = "stats--quotes"

// -- impls --
export class ShowStats implements IComponent {
  isOnLoad = true

  // -- props --
  private quoteInterval: number | null = null

  // -- props/el
  private $quotes: HTMLElement | null = null

  // -- IComponent --
  start() {
    const $quotes = document.getElementById(kIdStatsQuotes)
    if ($quotes == null) {
      return
    }

    this.$quotes = $quotes
    this.quoteInterval = window.setInterval(this.didFireQuoteTimer.bind(this), 15 * 1000)
  }

  cleanup() {
    // cleanup elements
    this.$quotes = null

    // cleanup interval
    if (this.quoteInterval != null) {
      window.clearInterval(this.quoteInterval)
      this.quoteInterval = null
    }
  }

  // -- commands --
  private setVisibilityOfQuote(isVisible: boolean, index: number) {
    const $quotes = this.$quotes!
    const length = $quotes.children.length
    const $quote = $quotes.children[(index + length) % length]
    $quote.classList.toggle(kClassVisible, isVisible)
  }

  // -- queries --
  private findIndexOfVisibleQuote(): number {
    const $quotes = this.$quotes!

    for (let i = 0; i < $quotes.children.length; i++) {
      const $quote = $quotes.children[i]

      if ($quote.classList.contains(kClassVisible)) {
        return i
      }
    }

    return -1
  }

  // -- events --
  private didFireQuoteTimer() {
    const index = this.findIndexOfVisibleQuote()
    this.setVisibilityOfQuote(false, index)
    this.setVisibilityOfQuote(true, index + 1);
  }
}
