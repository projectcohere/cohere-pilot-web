import { Files, IPreview } from "./Files"
import { Macros, IMacro } from "./Macros"
import { UploadFiles } from "./UploadFiles"
import { IComponent, kConsumer, Id } from "../../Core"
import { kClassLoaded } from "../../Shared/Constants"
import { getReadableTimeSince, formatTimes } from "../../Shared/Time"

// -- constants --
const kChannelChat = "Chats::MessagesChannel"

const kIdChat = "chat"
const kIdChatJson = "chat-json"
const kIdChatMessages = "chat-messages"
const kIdChatForm = "chat-form"
const kIdChatInput = "chat-input"
const kClassInfo = "ChatMessageInfo"
const kClassStatus = `${kClassInfo}-status`
const kClassSent = "is-sent"
const kClassReceived = "is-received"

const kSenderRecipient = "recipient"
const kFieldAuthenticityToken = "authenticity_token"
const kQueryAuthenticityToken = `input[name=${kFieldAuthenticityToken}]`

// -- types --
type Sender = string | "recipient"

type MessagesEventIn =
  | { name: "DID_SAVE_MESSAGE", data: IDidSaveMessage }
  | { name: "DID_ADD_MESSAGE", data: IDidAddMessage }
  | { name: "HAS_NEW_STATUS", data: IHasNewStatus }

type MessagesEventOut
  = { name: "ADD_MESSAGE", data: IMessageOut }

interface IDidSaveMessage {
  id: string,
  client_id: string
}

interface IDidAddMessage extends IMessageIn {
}

interface IHasNewStatus {
  id: string,
  status: Status
}

interface IMessageIn {
  id: string,
  sender: Sender,
  body: string | null,
  status: Status,
  timestamp: number,
  attachments: IPreview[]
}

interface IMessageOut {
  chat: string | null,
  message: {
    client_id: string,
    body: string
    attachment_ids?: number[]
  }
}

enum Status {
  Queued = 0,
  Failed,
  Delivered,
  Undelivered,
  Received,
}

interface Metadata {
  name: string,
  time: Date,
  class: string,
  status: Status,
}

// -- impls --
export class ShowChat implements IComponent {
  isOnLoad = true

  // -- deps --
  private files = new Files()
  private macros = new Macros(this.didPickMacro.bind(this))

  // -- props --
  private channel: ActionCable.Channel = null!
  private refreshInterval: number | null = null

  private id: string | null = null
  private sender: Sender = null!
  private receiver: string = null!
  private token: string = null!

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

    const token = $chatForm.querySelector(kQueryAuthenticityToken)
    this.token = token != null ? token.getAttribute("value")! : ""
    if (token == null) {
      console.debug("chat: missing authenticity token")
    }

    // capture elements
    this.$chat = $chat
    this.$chatMessages = document.getElementById(kIdChatMessages)
    this.$chatInput = document.getElementById(kIdChatInput)

    // render initial messages
    const $chatJson = document.getElementById(kIdChatJson)
    if ($chatJson != null) {
      const initial: IMessageIn[] = JSON.parse($chatJson.textContent || "")
      this.appendMessages(initial)
      $chatJson.remove()
    }

    // show chat after initial images load
    const $chatImages = document.querySelectorAll<HTMLImageElement>(`#${kIdChatMessages} img`)
    this.onImagesLoaded($chatImages, this.didLoadImages.bind(this))

    // bind to events
    $chatForm.addEventListener("submit", this.didSubmitMessage.bind(this))
    this.refreshInterval = window.setInterval(this.didFireRefreshTimer.bind(this), 60 * 1000)

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

    // cleanup interval
    if (this.refreshInterval != null) {
      window.clearInterval(this.refreshInterval)
      this.refreshInterval = null
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
      channel: kChannelChat,
      chat: this.id
    }

    this.channel = kConsumer.subscriptions.create(subscription, {
      received: this.didReceiveData.bind(this)
    })
  }

  // -- comands/ui
  private clearInput() {
    this.$chatInput!.textContent = ""
  }

  // -- commands/messages
  private async sendMessage() {
    const field = this.$chatInput!

    // short-circuit on empty request
    const body = field.textContent || ""
    const files = this.files.all
    if (body.length === 0 && files.length === 0) {
      return
    }

    // build outoing message
    const sender = this.sender
    const timestamp = new Date().getTime()
    const clientId = Id.generate()

    // display message optimistically
    this.appendMessage({
      id: clientId,
      body,
      sender,
      timestamp,
      status: Status.Queued,
      attachments: files.map((f) => f.preview)
    })

    this.clearInput()
    this.files.clear()

    // send attachments
    const fileIds = await UploadFiles({
      token: this.token,
      chatId: this.id,
      files: files
    })

    // send the message over the channel
    const event: MessagesEventOut = {
      name: "ADD_MESSAGE",
      data: {
        chat: this.id,
        message: {
          client_id: clientId,
          body,
          attachment_ids: fileIds
        }
      }
    }

    this.channel.send(event)
  }

  private setMessageId({ id, client_id }: IDidSaveMessage) {
    const $info = document.querySelector<HTMLElement>(`.${kClassInfo}[data-id="${client_id}"]`)

    if ($info != null) {
      $info.dataset["id"] = id
    }
  }

  private showMessage(incoming: IMessageIn) {
    if (incoming.sender !== this.sender) {
      this.appendMessage(incoming)
    }
  }

  private appendMessages(incoming: IMessageIn[]) {
    this.insertMessages(this.renderList(incoming, this.render.bind(this)))
    this.scrollToLastMessage()
  }

  private appendMessage(incoming: IMessageIn) {
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

  private showMessageStatus({ status, id }: IHasNewStatus) {
    const $status = document.querySelector(`.${kClassInfo}[data-id="${id}"] .${kClassStatus}`)

    if ($status != null) {
      const html = this.renderStatus(status)
      $status.replaceWith(document.createRange().createContextualFragment(html))
    }
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
  private didReceiveData(event: MessagesEventIn) {
    console.debug("ShowChat - received:", event)

    switch (event.name) {
      case "DID_SAVE_MESSAGE":
        this.setMessageId(event.data); break;
      case "DID_ADD_MESSAGE":
        this.showMessage(event.data); break;
      case "HAS_NEW_STATUS":
        this.showMessageStatus(event.data); break;
    }
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

  private didLoadImages() {
    const $chat = this.$chat!
    $chat.scrollTop = $chat.scrollHeight
    $chat.classList.toggle(kClassLoaded, true)
  }

  private didFireRefreshTimer() {
    formatTimes(
      document.querySelectorAll<HTMLTimeElement>(`#${kIdChatMessages} time`),
      getReadableTimeSince,
    )
  }

  // -- view --
  private render({ id, sender, body, attachments, timestamp, status }: IMessageIn): string {
    const isSent = this.isSent(sender)

    const metadata: Metadata = {
      name: isSent ? "Me" : this.receiver,
      time: new Date(timestamp * 1000),
      status,
      class: isSent ? kClassSent : kClassReceived,
    }

    return `
      ${this.renderAttachments(attachments, metadata)}
      ${this.renderBody(body, metadata)}
      ${this.renderInfo(id, metadata)}
    `
  }

  private renderBody(body: string | null, metadata: Metadata): string {
    if (body == null || body.length === 0) {
      return ""
    }

    return this.renderMessage(metadata, `
      <p class="ChatMessage-body">
        ${body}
      </p>
    `)
  }

  private renderAttachments(attachments: IPreview[], m: Metadata): string {
    const metadata = {
      ...m,
      class: `ChatMessage--image ${m.class}`
    }

    return (
      this.renderList(attachments, (a) => this.renderMessage(metadata, `
        <a href=${a.url} target="_blank" rel="noopener">
          <img
            class="ChatMessage-attachment"
            alt="${a.name}"
            src=${a.preview_url}
          />
        </a>
      `))
    )
  }

  private renderMessage({ class: c, name }: Metadata, children: string): string {
    return `
      <li class="ChatMessage ${c}">
        <label class="ChatMessage-sender">
          ${name}
        </label>
        ${children}
      </li>
    `
  }

  private renderInfo(id: string, { class: c, status, time }: Metadata): string {
    return `
      <li class="ChatMessageInfo ${c}" data-id=${id}>
        ${this.renderStatus(status)}
        <time class="ChatMessageInfo-timestamp" datetime=${time.toISOString()}>
          ${getReadableTimeSince(time)}
        </time>
      </li>
    `
  }

  private renderStatus(status: Status): string {
    switch (status) {
      case Status.Queued:
        return this.renderGlyph(`${kClassInfo}-queued`, `
          <circle r="3.5" cx="5" cy="5" />
        `)
      case Status.Delivered:
      case Status.Received:
        return this.renderGlyph(`${kClassInfo}-success`, `
          <path d="
            M 1.5 5.5
            L 4 8
            L 9 2"
          />
        `)
      case Status.Failed:
      case Status.Undelivered:
        return this.renderGlyph(`${kClassInfo}-failed`, `
          <path d="
            M 2 2
            L 8 8
            M 8 2
            L 2 8"
          />
        `)
    }
  }

  private renderGlyph(c: string, children: string): string {
    return `
      <svg class="${kClassStatus} ${c}" viewBox="0 0 10 10">
        ${children}
      </svg>
    `
  }

  private renderList<T>(list: T[], renderer: (item: T) => string): string {
    return list.map(renderer).join("\n")
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
    function didLoadImage(event: Event | null) {
      if (event != null && event.target != null) {
        event.target.removeEventListener("load", didLoadImage)
        event.target.removeEventListener("error", didLoadImage)
      }

      if (++loaded === length) {
        callback()
      }
    }

    // count each image as it loads
    for (let i = 0; i < length; i++) {
      const image = query[i]
      if (image.complete) {
        didLoadImage(null)
      } else {
        image.addEventListener("load", didLoadImage, { once: true })
        image.addEventListener("error", didLoadImage, { once: true })
      }
    }
  }
}
