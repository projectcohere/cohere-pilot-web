// -- types --
interface IRailsPlugin {
  start(): void
}

// -- main --
(() => {
  const plugins: IRailsPlugin[] = [
    require("@rails/ujs"),
    require("@rails/activestorage"),
    require("turbolinks")
  ]

  for (const plugin of plugins) {
    plugin.start()
  }
})()
