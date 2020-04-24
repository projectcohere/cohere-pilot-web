import "../../assets/stylesheets/application.scss"

import {
  start,
  Viewport,
  Flash,
  TabControl,
  ShowCaseList,
  ShowChat,
  ShowPasswords,
  ShowStats,
} from "../src"

// -- main --
start(
  require("@rails/ujs"),
  require("@rails/activestorage"),
  require("turbolinks"),
  new Viewport(),
  new Flash(),
  new TabControl(),
  new ShowCaseList(),
  new ShowChat(),
  new ShowPasswords(),
  new ShowStats(),
)
