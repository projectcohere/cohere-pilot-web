import { IComponent } from "../Component"

// -- constants --
const kIdFiles = "chat-files"
const kIdFileInput = "chat-file-input"
const kClassEmpty = "is-empty"

// -- impls --
export class Files implements IComponent {
  // -- props --
  private $files: HTMLElement
  private $fileInput: HTMLInputElement

  // -- IComponent --
  start() {
    // capture elements
    this.$files = document.getElementById(kIdFiles)
    this.$fileInput = document.getElementById(kIdFileInput) as HTMLInputElement

    // bind to events
    this.$files.addEventListener("click", this.didRemoveFile.bind(this))
    this.$fileInput.addEventListener("change", this.didChangeFiles.bind(this))
  }

  cleanup() {
    this.$files = null
    this.$fileInput = null
  }

  // -- events --
  private didChangeFiles() {
    const files = Array.from(this.$fileInput.files)
    this.render(files)
  }

  private didRemoveFile(event: Event) {
    const $button = event.target as HTMLButtonElement
    if ($button.name !== "remove-file") {
      return
    }

    const $file = $button.parentElement
    $file.remove()

    // set visibility class
    this.$files.classList.toggle(kClassEmpty, this.$files.childElementCount === 0)
  }

  // -- view --
  private render(files: File[]) {
    // set visibility class
    this.$files.classList.toggle(kClassEmpty, files.length === 0)

    // clear previews
    while (this.$files.lastChild) {
      this.$files.removeChild(this.$files.lastChild)
    }

    // add file previews
    for (const file of files) {
      this.$files.insertAdjacentHTML("beforeend", this.renderFile(file))
    }
  }

  private renderFile(file: File): string {
    const isPreviewable = file.type.startsWith("image")

    return `
      <li class="ChatFile">
        <figure class="ChatFile-preview" alt="File Preview">
          ${isPreviewable ? `<img src=${URL.createObjectURL(file)} />` : ""}
        </figure>
        <span class="ChatFile-name">
          ${file.name}
        </span>
        <button name="remove-file" class="ChatFile-removeButton" alt="Remove File"></button>
      </li>
    `
  }
}
