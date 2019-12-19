import ActionCable from "@rails/actioncable"
import { IComponent } from "./Component"

// -- constants --
const kConsumer = ActionCable.createConsumer()
const kIdChat = "chat"
const kIdChatForm = "chat-form"
const kIdChatField = "chat-field"
const kSenderMe = "me"

// -- types --
interface IMessage<T, B> {
  type: T,
  body: B
}

type Message = IMessage<"text", string>

interface Received {
  sender: string,
  message: Message
}

// -- impls --
export class Chat implements IComponent {
  isOnLoad = true
  // -- props --
  private channel: ActionCable.Channel
  private $chat: HTMLElement
  private $chatField: HTMLElement

  // -- IComponent --
  start() {
    const $chat = document.getElementById(kIdChat)
    if ($chat == null) {
      return
    }

    // capture elements
    this.$chat = $chat
    this.$chatField = document.getElementById(kIdChatField)

    const $chatForm = document.getElementById(kIdChatForm)

    // bind to events
    $chatForm.addEventListener("submit", this.didSubmitMessage.bind(this))

    // subscribe to channel
    const name = "Chats::Channel"
    this.channel = kConsumer.subscriptions.create(name, {
      received: this.didReceiveData.bind(this)
    })
  }

  cleanup() {
    // cleanup elements
    this.$chat = null

    // unsubscribe from channel
    if (this.channel) {
      this.channel.unsubscribe()
      this.channel = null
    }
  }

  // -- commands --
  private sendMessage() {
    const field = this.$chatField
    if (field.textContent.length == 0) {
      return
    }

    const message: Message = {
      type: "text",
      body: field.textContent
    }

    this.channel.send(message)
    this.addMessage(kSenderMe, message)

    field.textContent = ""
  }

  private receiveMesasage(received: Received) {
    console.debug("Chat - received:", received)
    this.addMessage(received.sender, received.message)
  }

  private addMessage(sender: string, message: Message) {
    this.$chat.insertAdjacentHTML("beforeend", this.render(sender, message))
  }

  // -- view --
  private render(sender: string, message: Message) {
    const classes = ["ChatMessage"]
    if (sender === kSenderMe) {
      classes.unshift("ChatMessage--sent")
    } else {
      classes.unshift("ChatMessage--received")
    }

    return `
      <li class="${classes.join(" ")}">
        <label class="ChatMessage-sender">
          ${sender === kSenderMe ? "Me" : sender}
        </label>
        <p class="ChatMessage-body">
          ${message.body}
        </p>
      </li>
    `
  }

  // -- events --
  private didReceiveData(data: any) {
    this.receiveMesasage(data)
  }

  private didSubmitMessage(event: Event) {
    event.preventDefault()
    this.sendMessage()
  }
}
