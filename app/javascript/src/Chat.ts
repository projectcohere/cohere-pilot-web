import { createConsumer } from "@rails/actioncable"
import { IComponent } from "./Component"

// -- constants --
const kConsumer = createConsumer()

// -- types --
interface IMessage<T, B> {
  user: string,
  type: T,
  body: B
}

type Message = IMessage<"text", string>

// -- impls --
export class Chat implements IComponent {
  isOnLoad = true
  // -- props --
  // -- props/singleton

  // -- props/ephemeral
  private channel: ActionCable.Channel
  private $chat: HTMLElement

  // -- IComponent --
  start() {
    const $chat = document.getElementById("chat")
    if ($chat == null) {
      return
    }

    // capture elements
    this.$chat = $chat

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
  private addMessage(message: Message) {
    this.$chat.insertAdjacentHTML("beforeend", this.renderMessage(message))
  }

  // -- view --
  private renderMessage(message: Message) {
    return `
      <li class="ChatMessage--received ChatMessage">
        <label class="ChatMessage-sender">
          ${message.user}
        </label>
        <p class="ChatMessage-body">
          ${message.body}
        </p>
      </li>
    `
  }

  // -- events --
  private didReceiveData(data: any) {
    this.addMessage(data)
  }
}
