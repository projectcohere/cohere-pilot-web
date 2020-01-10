import { IComponent } from "../Component"

// -- constants --
const kIdFileList = "chat-files"
const kIdFileInput = "chat-file-input"
const kClassEmpty = "is-empty"
const kNameRemove = "remove-file"

// -- types --
interface ChatFile {
  id: string
  file: File
}

// -- impls --
export class Files implements IComponent {
  // -- props --
  private files: ChatFile[] = []

  // -- props/el
  private $fileList: HTMLElement | null = null
  private $fileInput: HTMLInputElement | null = null

  // -- IComponent --
  start() {
    // capture elements
    this.$fileList = document.getElementById(kIdFileList)
    this.$fileInput = document.getElementById(kIdFileInput) as HTMLInputElement | null

    // bind to events
    this.$fileList!.addEventListener("click", this.didRemoveFile.bind(this))
    this.$fileInput!.addEventListener("change", this.didChangeFiles.bind(this))
  }

  cleanup() {
    this.resetFiles()
    this.$fileList = null
    this.$fileInput = null
  }

  // -- commands --
  clear() {
    this.resetFiles()
    this.render()
  }

  private resetFiles() {
    this.files.splice(0, this.files.length)
  }

  // -- queries --
  all(): File[] {
    return this.files.map((f) => f.file)
  }

  // -- events --
  private didChangeFiles() {
    this.resetFiles()

    // add files from the input
    const files = this.$fileInput!.files || []
    for (let i = 0; i < files.length; i++) {
      this.files.push({
        id: i.toString(),
        file: files[i]
      })
    }

    // re-render the view
    this.render()
  }

  private didRemoveFile(event: Event) {
    // make sure this click was on the delete button
    const $button = event.target as HTMLButtonElement
    if ($button.name !== kNameRemove) {
      return
    }

    const $file = $button.parentElement as HTMLElement

    // remove the file by id
    const id = $file.dataset.id
    const index = this.files.findIndex((file) => {
      return file.id == id
    })

    this.files.splice(index, 1)

    // remove the dom node
    $file.remove()

    // set visibility class
    this.$fileList!.classList.toggle(kClassEmpty, this.$fileList!.childElementCount === 0)
  }

  // -- view --
  private render() {
    const $fileList = this.$fileList!

    // set visibility class
    $fileList.classList.toggle(kClassEmpty, this.files.length === 0)

    // clear previews
    while ($fileList.lastChild) {
      $fileList.removeChild($fileList.lastChild)
    }

    // add previews
    for (const file of this.files) {
      $fileList.insertAdjacentHTML("beforeend", this.renderFile(file))
    }
  }

  private renderFile({ id, file }: ChatFile): string {
    const isPreviewable = file.type.startsWith("image")

    return `
      <li class="ChatFile" data-id=${id}>
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
