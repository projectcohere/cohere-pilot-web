import { IComponent } from "../Core"
import { kClassEmpty } from "../Shared/Constants"

// -- constants --
const kIdFileList = "chat-files"
const kIdFileInput = "chat-file-input"
const kNameRemove = "remove-file"

// -- types --
export type IFileInput = File | IAttachment
export type IFile = IUpload | IAttachment

export interface IUpload extends IAttachment {
  upload: File
}

export interface IAttachment {
  id: number
  preview: IPreview
}

export interface IPreview {
  name: string
  url: string,
  preview_url: string | null
}

// -- impls --
export class Files implements IComponent {
  // -- props --
  private files: IFile[] = []

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

  set(files: IFileInput[]) {
    this.files = files.map<IFile>((file, i) => {
      if (!(file instanceof File)) {
        return file
      }

      const url = URL.createObjectURL(file)

      return {
        id: i,
        upload: file,
        preview: {
          name: file.name,
          url,
          preview_url: file.type.startsWith("image") ? url : null
        }
      }
    })

    this.render()
  }

  private resetFiles() {
    this.files.splice(0, this.files.length)
  }

  // -- queries --
  get any(): boolean {
    return this.files.length !== 0
  }

  get all(): IFile[] {
    return this.files.slice()
  }

  // -- events --
  private didChangeFiles() {
    this.resetFiles()

    // add files from the input
    const files: File[] = []

    const input = this.$fileInput!.files
    if (input != null) {
      for (let i = 0; i < input.length; i++) {
        files.push(input[i])
      }
    }

    this.set(files)
  }

  private didRemoveFile(event: Event) {
    // make sure this click was on the delete button
    const $button = event.target as HTMLButtonElement
    if ($button.name !== kNameRemove) {
      return
    }

    const $file = $button.parentElement as HTMLElement

    // remove the file by id
    const idString = $file.dataset.id
    const id = idString == null ? null : Number.parseInt(idString)
    const index = this.files.findIndex((file) => {
      return file.id === id
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

  private renderFile({ id, preview }: IFile): string {
    return `
      <li class="ChatFile" data-id=${id}>
        <figure class="ChatFile-preview" alt="File Preview">
          ${preview.url != null ? `<img src=${preview.url} />` : ""}
        </figure>
        <span class="ChatFile-name">
          ${preview.name}
        </span>
        <button name="remove-file" class="ChatFile-removeButton" alt="Remove File"></button>
      </li>
    `
  }
}
