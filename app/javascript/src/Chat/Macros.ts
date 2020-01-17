import { IComponent } from "../Component"
import { IAttachment } from "./Files"

// -- constants --
const kIdMacros = "chat-macros"
const kIdMacroInput = "chat-macro-input"

// -- types --
export interface IMacro {
  body: string
  attachment: IAttachment | null
}

// -- impls --
export class Macros implements IComponent {
  // -- props --
  private macros: IMacro[] = []
  private onSelect: ((macro: IMacro | null) => void)

  // -- props/el
  private $macroInput: HTMLSelectElement | null = null

  // -- lifetime --
  constructor(onSelect: (macro: IMacro | null) => void) {
    this.onSelect = onSelect
  }

  // -- IComponent --
  start() {
    // capture data once
    const $macros = document.getElementById(kIdMacros)
    if ($macros != null) {
      this.macros = JSON.parse($macros.textContent || "")
      $macros!.remove()
    }

    // check that we have data
    if (this.macros.length === 0) {
      return
    }

    // capture elements
    this.$macroInput = document.getElementById(kIdMacroInput) as HTMLSelectElement

    // bind to events
    this.$macroInput!.addEventListener("change", this.didPickMacro.bind(this))
  }

  cleanup() {
    this.$macroInput = null
  }

  // -- events --
  private didPickMacro() {
    const index = this.$macroInput!.selectedIndex
    if (index == 0) {
      this.onSelect(null)
    } else {
      this.onSelect(this.macros[index - 1])
    }
  }
}
