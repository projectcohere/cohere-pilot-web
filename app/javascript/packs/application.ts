import { start, Flash, Passwords, TabControl } from "../src"

// -- main --
start(
  require("@rails/ujs"),
  require("@rails/activestorage"),
  require("turbolinks"),
  new Flash(),
  new Passwords(),
  new TabControl(),
)
