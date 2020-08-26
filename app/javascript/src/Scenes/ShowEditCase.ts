import { IComponent } from "../Core"
import { kEventConfirm } from "../Shared/Constants"
import { Modal } from "../Shared/Modal"
import { getNow, getReadableTime, formatTimes } from "../Shared/Time"

// -- constants --
const kIdNotes = "note-list"
const kIdAddNote = "add-note"
const kIdAddNoteForm = "add-note-form"
const kIdAddNoteBody = "add-note-body"
const kIdAddNoteField = "case_note_body"

// -- impls --
export class ShowEditCase implements IComponent {
  isOnLoad = true

  // -- props/elements
  private $notes: HTMLElement | null = null
  private $addNoteForm: Modal | null = null
  private $addNoteBody: HTMLElement | null = null
  private $addNoteField: HTMLElement | null = null

  // -- IComponent --
  start() {
    const $notes = document.getElementById(kIdNotes)
    if ($notes == null) {
      return
    }

    // capture elements
    this.$notes = $notes
    this.$addNoteForm = new Modal(kIdAddNote, kIdAddNoteForm, false)
    this.$addNoteBody = document.getElementById(kIdAddNoteBody)
    this.$addNoteField = document.getElementById(kIdAddNoteField)

    // register events
    this.$addNoteForm.on("keyup", this.didEditNote.bind(this))
    this.$addNoteForm.on(kEventConfirm, this.didConfirmAddNote.bind(this))

    // update time labels
    formatTimes(
      this.$notes.querySelectorAll("time"),
      getReadableTime,
    )
  }

  cleanup() {
    this.$notes = null
    this.$addNoteForm = null
    this.$addNoteBody = null
    this.$addNoteField = null
  }

  // -- queries --
  private getBody(): string {
    return this.$addNoteBody!.textContent || ""
  }

  // -- events --
  private didEditNote() {
    this.$addNoteForm!.setEnabled(this.getBody().length > 0)
  }

  private didConfirmAddNote() {
    const body = this.getBody()
    this.$addNoteField!.setAttribute("value", body)
    this.$notes!.insertAdjacentHTML("afterbegin", this.renderNote(body, getNow()));
  }

  // -- view --
  private renderNote(body: string, date: Date) {
    return `
      <li class="CaseNote">
        <p>${body}</p>
        <p class="CaseNote-metadata">
          <span class="CaseNote-user">Me</span>
          <time class="CaseNote-timestamp" datetime=${date.toISOString()}>
            ${getReadableTime(date)}
          </time>
        </p>
      </li>
    `
  }
}
