import {
  start,
  Viewport,
  Flash,
  TabControl,
  ShowPasswords,
  ShowChat,
} from "../src"

// -- main --
start(
  require("@rails/ujs"),
  require("@rails/activestorage"),
  require("turbolinks"),
  new Viewport(),
  new Flash(),
  new TabControl(),
  new ShowChat(),
  new ShowPasswords(),
)
