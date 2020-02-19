import { createConsumer } from "@rails/actioncable"
import { Files, IPreview } from "./Files"
import { Macros, IMacro } from "./Macros"
import { UploadFiles } from "./UploadFiles"
import { IComponent } from "../Component"

// -- constants --
const kConsumer = createConsumer()

const kIdChat = "chat"
const kIdChatJson = "chat-json"
const kIdChatMessages = "chat-messages"
const kIdChatForm = "chat-form"
const kIdChatInput = "chat-input"
const kClassIsLoaded = "is-loaded"

const kSenderRecipient = "recipient"
const kFieldAuthenticityToken = "authenticity_token"
const kQueryAuthenticityToken = `input[name=${kFieldAuthenticityToken}]`

// -- types --
type Sender = string | "recipient"

interface Incoming {
  sender: Sender,
  message: {
    body: string | null,
    timestamp: number,
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

interface Metadata {
  name: string,
  time: Date,
  classes: string,
}

// -- impls --
export class Chat implements IComponent {
  isOnLoad = true

  // -- deps --
  private files = new Files()
  private macros = new Macros(this.didPickMacro.bind(this))

  // -- props --
  private channel: ActionCable.Channel = null!
  private dispose: (() => void) | null = null

  private id: string | null = null
  private sender: Sender = null!
  private receiver: string = null!
  private authenticityToken: string = null!

  // -- props/el
  private $chat: HTMLElement | null = null
  private $chatMessages: HTMLElement | null = null
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
    this.$chatMessages = document.getElementById(kIdChatMessages)
    this.$chatInput = document.getElementById(kIdChatInput)

    // render initial messages
    const $chatJson = document.getElementById(kIdChatJson)
    if ($chatJson != null) {
      const initial: Incoming[] = JSON.parse($chatJson.textContent || "")
      this.appendMessages(initial)
      $chatJson.remove()
    }

    // show chat after initial images load
    const query = document.querySelectorAll<HTMLImageElement>(`#${kIdChatMessages} img`)
    this.onImagesLoaded(query, () => {
      $chat.scrollTop = $chat.scrollHeight
      $chat.classList.toggle(kClassIsLoaded, true)
    })

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
    this.$chatMessages = null
    this.$chatInput = null

    // run any bound disposal
    if (this.dispose != null) {
      this.dispose()
      this.dispose = null
    }

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
        timestamp: new Date().getTime(),
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
    this.insertMessages(this.renderList(incoming, this.render.bind(this)))
    this.scrollToLastMessage()
  }

  private appendMessage(incoming: Incoming) {
    this.insertMessages(this.render(incoming))
    this.scrollToLastMessage()
  }

  private insertMessages(messages: string) {
    this.$chatMessages!.insertAdjacentHTML("beforeend", messages)
  }

  private scrollToLastMessage() {
    const $chat = this.$chat!
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
  private render({ sender, message: { body, timestamp, attachments } }: Incoming): string {
    const isSent = this.isSent(sender)

    let classes = "ChatMessage"
    if (isSent) {
      classes += " ChatMessage--sent"
    } else {
      classes += " ChatMessage--received"
    }

    const metadata: Metadata = {
      name: isSent ? "Me" : this.receiver,
      time: new Date(timestamp * 1000),
      classes
    }

    if (sender == kSenderRecipient) {
      return `
        ${this.renderAttachments(attachments, metadata)}
        ${this.renderBody(body, metadata)}
      `
    } else {
      return `
        ${this.renderBody(body, metadata)}
        ${this.renderAttachments(attachments, metadata)}
      `
    }
  }

  private renderBody(body: string | null, metadata: Metadata): string {
    if (body == null || body.length === 0) {
      return ""
    }

    return this.renderBubble(metadata, `
      <p class="ChatMessage-body">
        ${body}
      </p>
    `)
  }

  private renderAttachments(attachments: IPreview[], m: Metadata): string {
    const metadata = {
      ...m,
      classes: `${m.classes} ChatMessage--image`
    }

    return (
      this.renderList(attachments, (a) => this.renderBubble(metadata, `
        <a href=${a.url} target="_blank" rel="noopener">
          <img
            class="ChatMessage-attachment"
            alt="${a.name}"
            src=${a.previewUrl}
          />
        </a>
      `))
    )
  }

  private renderBubble(metadata: Metadata, children: string): string {
    return `
      <li class="${metadata.classes}">
        <label class="ChatMessage-sender">
          ${metadata.name}
        </label>
        ${children}
        <time class="ChatMessage-timestamp" datetime=${metadata.time.toISOString()}>
          ${this.renderTimeSince(metadata.time)}
        </time>
      </li>
    `
  }

  private renderList<T>(list: T[], renderer: (item: T) => string): string {
    return list.map(renderer).join("\n")
  }

  private renderTimeSince(date: Date): string {
    const delta = Math.max(new Date().getTime() - date.getTime(), 0)
    const minutes = Math.floor(delta / 1000 / 60)
    const hours = Math.floor(minutes / 60)

    if (minutes < 1) {
      return "Just now"
    } else if (minutes < 60) {
      return `${minutes} ${this.pluralize("minute", minutes)} ago`
    } else if (hours < 24) {
      return `${hours} ${this.pluralize("hour", hours)} ago`
    } else {
      return date.toLocaleString("en-US", { month: "numeric", day: "numeric", hour: "numeric", minute: "numeric", hour12: true })
    }
  }

  // -- utilities --
  private onImagesLoaded(query: NodeListOf<HTMLImageElement>, callback: () => void) {
    const length = query.length
    if (length === 0) {
      callback()
      return
    }

    // fire the callback when all images are loaded
    let loaded = 0
    function didLoadImage() {
      if (++loaded === length) {
        callback()
      }
    }

    // count each image as it loads
    for (let i = 0; i < length; i++) {
      const image = query[i]
      if (image.complete) {
        didLoadImage()
      } else {
        image.addEventListener("load", didLoadImage, { once: true })
      }
    }
  }

  private pluralize(label: string, quantity: number): string {
    if (quantity === 1) {
      return label
    } else {
      return label + "s"
    }
  }
}
