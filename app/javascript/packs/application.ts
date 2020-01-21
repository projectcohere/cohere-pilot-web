import { start, Flash, Passwords, TabControl, Chat, Viewport } from "../src"

// -- main --
start(
  require("@rails/ujs"),
  require("@rails/activestorage"),
  require("turbolinks"),
  new Viewport(),
  new Chat(),
  new Flash(),
  new Passwords(),
  new TabControl(),
)
