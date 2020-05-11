import { IComponent } from "../Core"
import { Modal } from "../Shared/Modal"

// -- constants --
const kIdAddNote = "add-note"
const kIdAddNoteForm = "add-note-form"
const kIdAddNoteBody = "add-note-body"
const kIdAddNoteField = "case_note_body"

// -- impls --
export class ShowEditCase implements IComponent {
  isOnLoad = true

  // -- props --
  private addNoteChanges: MutationObserver | null = null

  // -- props/elements
  private $addNoteForm: Modal | null = null
  private $addNoteBody: HTMLElement | null = null
  private $addNoteField: HTMLElement | null = null

  // -- IComponent --
  start() {
    // capture elements
    this.$addNoteForm = new Modal(kIdAddNote, kIdAddNoteForm)
    this.$addNoteBody = document.getElementById(kIdAddNoteBody)
    this.$addNoteField = document.getElementById(kIdAddNoteField)

    // register events
    this.$addNoteForm.onConfirm(this.didConfirmAddNote.bind(this))
  }

  cleanup() {
    this.$addNoteForm = null
    this.$addNoteField = null

    if (this.addNoteChanges != null) {
      this.addNoteChanges.disconnect()
      this.addNoteChanges = null
    }
  }

  // -- events --
  private didConfirmAddNote() {
    this.$addNoteField!.setAttribute(
      "value",
      this.$addNoteBody!.textContent || ""
    )
  }
}
