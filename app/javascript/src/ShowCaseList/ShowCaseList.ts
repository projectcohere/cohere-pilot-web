import { IComponent, kConsumer } from "../Core"

// -- constants --
const kChannelActivity = "Cases::ActivityChannel"
const kPathQueue = "/cases/inbox"
const kIdCaseList = "case-list"
const kClassIsActive = "is-active"

// -- types --
type ActivityEvent
  = { name: "HAS_NEW_ACTIVITY", data: IHasNewActivity }
  | { name: "DID_ADD_QUEUED_CASE", data: IHasQueueChange }
  | { name: "DID_ASSIGN_USER", data: IHasQueueChange }
  | { name: "DID_UNASSIGN_USER", data: IHasQueueChange }

interface IHasNewActivity {
  case_id: string
  case_new_activity: boolean
}

interface IHasQueueChange {
  case_id: string
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
  private showActivity(data: IHasNewActivity) {
    const $case = document.getElementById(`case-${data.case_id}`)

    if ($case != null) {
      $case.classList.toggle(kClassIsActive, data.case_new_activity)
    }
  }

  private showQueuedCase(data: IHasQueueChange) {
    if (this.isLocationQueue()) {
      this.addCaseToQueue(data);
    }
  }

  private hideQueuedCase(data: IHasQueueChange) {
    if (this.isLocationQueue()) {
      this.removeCaseFromQueue(data);
    }
  }

  private addCaseToQueue(data: IHasQueueChange) {
    const $case = document.getElementById(`case-${data.case_id}`)
    if ($case == null) {
      document.location.reload(true)
    }
  }

  private removeCaseFromQueue(data: IHasQueueChange) {
    const $case = document.getElementById(`case-${data.case_id}`)
    if ($case != null) {
      document.location.reload(true)
    }
  }

  // -- events --
  private didReceiveData(event: ActivityEvent) {
    console.debug("ShowCaseList - received:", event)

    switch (event.name) {
      case "HAS_NEW_ACTIVITY":
        this.showActivity(event.data); break
      case "DID_ADD_QUEUED_CASE":
        this.showQueuedCase(event.data); break
      case "DID_ASSIGN_USER":
        this.hideQueuedCase(event.data); break
      case "DID_UNASSIGN_USER":
        this.showQueuedCase(event.data); break
    }
  }

  // -- queries --
  private isLocationQueue(): boolean {
    return document.location.pathname === kPathQueue
  }
}
