import { createConsumer } from "@rails/actioncable"
import { Files, IPreview } from "./Files"
import { Macros, IMacro } from "./Macros"
import { UploadFiles } from "./UploadFiles"
import { IComponent } from "../Component"

// -- constants --
const kConsumer = createConsumer()
const kIdChat = "chat"
const kIdChatJson = "chat-json"
const kIdChatForm = "chat-form"
const kIdChatInput = "chat-input"
const kSenderRecipient = "recipient"

const kFieldAuthenticityToken = "authenticity_token"
const kQueryAuthenticityToken = `input[name=${kFieldAuthenticityToken}]`

// -- types --
type Sender = string | "recipient"

interface Incoming {
  sender: Sender,
  message: {
    body: string | null
    attachments: IPreview[]
  }
}

interface Outgoing {
  chat: string | null,
  message: {
    body: string
    attachmentIds?: number[]
  }
}

// -- impls --
export class Chat implements IComponent {
  isOnLoad = true

  // -- deps --
  private files = new Files()
  private macros = new Macros(this.didPickMacro.bind(this))

  // -- props --
  private channel: ActionCable.Channel = null!
  private id: string | null = null
  private sender: Sender = null!
  private receiver: string = null!
  private authenticityToken: string = null!

  // -- props/el
  private $chat: HTMLElement | null = null
  private $chatInput: HTMLElement | null = null

  // -- IComponent --
  start() {
    const $chat = document.getElementById(kIdChat)
    if ($chat == null) {
      return
    }

    // find temporary elements
    const $chatForm = document.getElementById(kIdChatForm)!

    // extract element data
    this.id = $chat.dataset.id || null
    this.sender = $chat.dataset.sender as Sender
    this.receiver = $chat.dataset.receiver!
    this.authenticityToken = $chatForm.querySelector(kQueryAuthenticityToken)!.getAttribute("value")!

    // capture elements
    this.$chat = $chat
    this.$chatInput = document.getElementById(kIdChatInput)

    // render initial messages
    const $chatJson = document.getElementById(kIdChatJson)
    if ($chatJson != null) {
      const initial: Incoming[] = JSON.parse($chatJson.textContent || "")
      this.appendMessages(initial)
      $chatJson.remove()
    }

    // set initial view state
    $chat.scrollTop = $chat.scrollHeight

    // bind to events
    $chatForm.addEventListener("submit", this.didSubmitMessage.bind(this))

    // subscribe to channel
    this.subscribe()

    // start deps
    this.files.start()
    this.macros.start()
  }

  cleanup() {
    // cleanup deps
    this.files.cleanup()
    this.macros.cleanup()

    // cleanup props
    this.id = null
    this.sender = null!
    this.receiver = null!

    // cleanup elements
    this.$chat = null
    this.$chatInput = null

    // unsubscribe from channel
    if (this.channel != null) {
      this.channel.unsubscribe()
      this.channel = null!
    }
  }

  // -- commands --
  private subscribe() {
    const subscription = {
      channel: "Chats::Channel",
      chat: this.id
    }

    this.channel = kConsumer.subscriptions.create(subscription, {
      received: this.didReceiveData.bind(this)
    })
  }

  private async sendMessage() {
    const field = this.$chatInput!

    // short-circuit on empty request
    const body = field.textContent || ""
    const files = this.files.all
    if (body.length === 0 && files.length === 0) {
      return
    }

    // display message optimistically
    this.appendMessage({
      sender: this.sender,
      message: {
        body,
        attachments: files.map((f) => f.preview)
      }
    })

    this.clearInput()
    this.files.clear()

    // send attachments
    const fileIds = await UploadFiles({
      authenticityToken: this.authenticityToken,
      chatId: this.id,
      files: files
    })

    // send the message over the channel
    const outgoing: Outgoing = {
      chat: this.id,
      message: {
        body,
        attachmentIds: fileIds
      }
    }

    this.channel.send(outgoing)
  }

  private receiveMesasage(incoming: Incoming) {
    console.debug("Chat - received:", incoming)

    if (incoming.sender !== this.sender) {
      this.appendMessage(incoming)
    }
  }

  private appendMessages(incoming: Incoming[]) {
    const $chat = this.$chat!
    $chat.insertAdjacentHTML(
      "beforeend",
      this.renderList(incoming, this.render.bind(this))
    )

    $chat.scrollTo(0, $chat.scrollHeight)
  }

  private appendMessage(incoming: Incoming) {
    const $chat = this.$chat!
    $chat.insertAdjacentHTML(
      "beforeend",
      this.render(incoming)
    )

    $chat.scrollTo(0, $chat.scrollHeight)
  }

  private clearInput() {
    this.$chatInput!.textContent = ""
  }

  // -- queries --
  isSent(sender: Sender): boolean {
    switch (this.sender) {
      case kSenderRecipient:
        return sender === kSenderRecipient
      default:
        return sender !== kSenderRecipient
    }
  }

  // -- events --
  private didReceiveData(data: any) {
    this.receiveMesasage(data)
  }

  private didSubmitMessage(event: Event) {
    event.preventDefault()
    this.sendMessage()
  }

  private didPickMacro(macro: IMacro | null) {
    this.$chatInput!.textContent = macro == null ? "" : macro.body

    if (macro == null || macro.attachment == null) {
      this.files.clear()
    } else {
      this.files.set([macro.attachment])
    }
  }

  // -- view --
  private render({ sender, message: { body, attachments } }: Incoming): string {
    const isSent = this.isSent(sender)
    const isRecipient = sender == kSenderRecipient
    const name = isSent ? "Me" : this.receiver

    let classes = "ChatMessage"
    if (isSent) {
      classes += " ChatMessage--sent"
    } else {
      classes += " ChatMessage--received"
    }

    if (isRecipient) {
      return `
        ${this.renderAttachments(name, classes, attachments)}
        ${this.renderBody(name, classes, body)}
      `
    } else {
      return `
        ${this.renderBody(name, classes, body)}
        ${this.renderAttachments(name, classes, attachments)}
      `
    }
  }

  private renderAttachments(name: string, cls: string, attachments: IPreview[]): string {
    const classes = `${cls} ChatMessage--image`

    return (
      this.renderList(attachments, (a) => this.renderBubble(name, classes, `
        <img
          class="ChatMessage-attachment"
          alt="${a.name}"
          src=${a.url}
          height=200
          width=200
        />
      `))
    )
  }

  private renderBody(name: string, cls: string, body: string | null): string {
    if (body == null || body.length === 0) {
      return ""
    }

    return this.renderBubble(name, cls, `
      <p class="ChatMessage-body">
        ${body}
      </p>
    `)
  }

  private renderBubble(name: string, classes: string, children: string): string {
    return `
      <li class= "${classes}">
        <label class="ChatMessage-sender">
          ${name}
        </label>
        ${children}
      </li>
    `
  }

  private renderList<T>(list: T[], renderer: (item: T) => string): string {
    return list.map(renderer).join("\n")
  }
}
