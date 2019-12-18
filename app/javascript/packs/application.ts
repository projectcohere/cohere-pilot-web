import { start, Flash, Passwords, TabControl, Chat } from "../src"

// -- main --
start(
  require("@rails/ujs"),
  require("@rails/activestorage"),
  require("turbolinks"),
  new Chat(),
  new Flash(),
  new Passwords(),
  new TabControl(),
)
