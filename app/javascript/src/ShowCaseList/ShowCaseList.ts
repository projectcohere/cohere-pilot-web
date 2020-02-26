import { IComponent, kConsumer } from "../Core"

// -- constants --
const kChannelActivity = "Cases::ActivityChannel"

const kIdCaseList = "case-list"
const kClassIsActive = "is-active"

// -- types --
interface CaseActivity {
  id: string
  hasNewActivity: boolean
}

// -- impls --
export class ShowCaseList implements IComponent {
  isOnLoad = true

  // -- props --
  private channel: ActionCable.Channel = null!

  // -- IComponent --
  start() {
    const $cases = document.getElementById(kIdCaseList)
    if ($cases == null) {
      return
    }

    // subscribe to channel
    this.subscribe()
  }

  cleanup() {
    // unsubscribe from channel
    if (this.channel != null) {
      this.channel.unsubscribe()
      this.channel = null!
    }
  }

  // -- commands --
  private subscribe() {
    const subscription = {
      channel: kChannelActivity,
    }

    this.channel = kConsumer.subscriptions.create(subscription, {
      received: this.didReceiveData.bind(this),
    })
  }

  // -- commands/activity
  private showActivity(kase: CaseActivity) {
    const $case = document.getElementById(`case-${kase.id}`)
    if ($case != null) {
      $case.classList.toggle(kClassIsActive, kase.hasNewActivity)
    }
  }

  // -- events --
  private didReceiveData(data: any) {
    console.debug("ShowCaseList - received:", data)
    this.showActivity(data)
  }
}
