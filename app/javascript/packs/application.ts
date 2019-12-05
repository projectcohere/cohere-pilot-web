import { start, Flash, Passwords, EditCase } from "../src"

// -- main --
start(
  require("@rails/ujs"),
  require("@rails/activestorage"),
  require("turbolinks"),
  new Flash(),
  new Passwords(),
  new EditCase()
)
