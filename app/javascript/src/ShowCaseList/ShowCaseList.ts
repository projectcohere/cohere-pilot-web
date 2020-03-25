import { IComponent, kConsumer } from "../Core"

// -- constants --
const kChannelActivity = "Cases::ActivityChannel"

const kScopeQueued = "queued"

const kIdCaseList = "case-list"
const kIdQueuedFilter = `filter-${kScopeQueued}`
const kClassIsActive = "is-active"

// -- types --
type ActivityEvent
  = { name: "HAS_NEW_ACTIVITY", data: IHasNewActivity }
  | { name: "DID_ADD_QUEUED_CASE", data: IDidAddQueuedCase }
  | { name: "DID_ASSIGN_USER", data: IDidAssignUser }

interface IHasNewActivity {
  case_id: string
  case_has_new_activity: boolean
}

interface IDidAddQueuedCase {
  case_id: string
}

interface IDidAssignUser {
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
      $case.classList.toggle(kClassIsActive, data.case_has_new_activity)
    }
  }

  private showQueuedCase(data: IDidAddQueuedCase) {
    const scope = document.location.pathname.split("/").pop()

    if (scope == kScopeQueued) {
      this.addCaseToQueue(data)
    } else {
      this.showQueueActivity()
    }
  }

  private hideQueuedCase(data: IDidAssignUser) {
    const scope = document.location.pathname.split("/").pop()

    if (scope == kScopeQueued) {
      this.removeCaseFromQueue(data)
    } else {
      this.showQueueActivity()
    }
  }

  private addCaseToQueue(data: IDidAddQueuedCase) {
    const $case = document.getElementById(`case-${data.case_id}`)

    if ($case == null) {
      document.location.reload(true)
    }
  }

  private removeCaseFromQueue(data: IDidAssignUser) {
    const $case = document.getElementById(`case-${data.case_id}`)

    if ($case != null) {
      document.location.reload(true)
    }
  }

  private showQueueActivity() {
    const $filter = document.getElementById(kIdQueuedFilter)!
    $filter.classList.toggle(kClassIsActive, true)
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
    }
  }
}
