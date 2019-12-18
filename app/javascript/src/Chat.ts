import { IComponent } from "./Component"

// -- impls --
export class Chat implements IComponent {
  isOnLoad = true

  // -- IComponent --
  start() {
    console.log("chat time")
  }
}
