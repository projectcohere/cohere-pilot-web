import { createConsumer } from "@rails/actioncable"
import { IComponent } from "./Component"

// -- constants --
const kConsumer = createConsumer()
const kIdChat = "chat"
const kIdChatForm = "chat-form"
const kIdChatField = "chat-field"

// -- types --
type Sender = string | "recipient"
type Message = { type: "text", body: string }

interface Incoming {
  sender: Sender,
  message: Message
}

interface Outgoing {
  chat: string
  message: Message
}

// -- impls --
export class Chat implements IComponent {
  isOnLoad = true

  // -- props --
  private channel: ActionCable.Channel
  private id: string | null
  private sender: Sender
  private receiver: string

  private $chat: HTMLElement
  private $chatField: HTMLElement

  // -- IComponent --
  start() {
    const $chat = document.getElementById(kIdChat)
    if ($chat == null) {
      return
    }

    // extract element data
    this.id = $chat.dataset.id
    this.sender = $chat.dataset.sender as Sender
    this.receiver = $chat.dataset.receiver

    // capture elements
    this.$chat = $chat
    this.$chatField = document.getElementById(kIdChatField)

    // set initial view state
    this.$chat.scrollTop = this.$chat.scrollHeight - 50;

    // bind to events
    const $chatForm = document.getElementById(kIdChatForm)
    $chatForm.addEventListener("submit", this.didSubmitMessage.bind(this))

    // subscribe to channel
    this.subscribe()
  }

  cleanup() {
    // cleanup props
    this.id = null
    this.sender = null
    this.receiver = null

    // cleanup elements
    this.$chat = null
    this.$chatField = null

    // unsubscribe from channel
    if (this.channel != null) {
      this.channel.unsubscribe()
      this.channel = null
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

  private sendMessage() {
    const field = this.$chatField
    if (field.textContent.length == 0) {
      return
    }

    const outgoing: Outgoing = {
      chat: this.id,
      message: {
        type: "text",
        body: field.textContent
      }
    }

    this.channel.send(outgoing)
    this.addMessage(outgoing.message, this.sender)

    field.textContent = ""
  }

  private receiveMesasage(incoming: Incoming) {
    console.debug("Chat - received:", incoming)

    if (incoming.sender !== this.sender) {
      this.addMessage(incoming.message, incoming.sender)
    }
  }

  private addMessage(message: Message, sender: Sender) {
    this.$chat.insertAdjacentHTML(
      "beforeend",
      this.render(message, sender)
    )

    this.$chat.scrollTo(0, this.$chat.scrollHeight)
  }

  // -- queries --
  isSentBy(message: Message, sender: Sender) {
    switch (this.sender) {
      case "recipient":
        return sender === "recipient"
      default:
        return sender !== "recipient"
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

  // -- view --
  private render(message: Message, sender: Sender) {
    const classes = ["ChatMessage"]

    const isSent = this.isSentBy(message, sender)
    if (isSent) {
      classes.push("ChatMessage--sent")
    } else {
      classes.push("ChatMessage--received")
    }

    return `
      <li class="${classes.join(" ")}">
        <label class="ChatMessage-sender">
          ${isSent ? "Me" : this.receiver}
        </label>
        <p class="ChatMessage-body">
          ${message.body}
        </p>
      </li>
    `
  }
}
