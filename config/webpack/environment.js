const { environment } = require("@rails/webpacker")

environment.loaders.prepend(
  "typescript",
  require("./loaders/typescript")
)

module.exports = environment
