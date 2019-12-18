// -- types --
export interface IComponent {
  isOnLoad: boolean
  start(): void
  cleanup?(): void
}

// -- impls --
export function start(...components: IComponent[]) {
  // partition components based on requirements
  const once: IComponent[] = []
  const page: IComponent[] = []

  for (const component of components) {
    if (component.isOnLoad) {
      page.push(component)
    } else {
      once.push(component)
    }
  }

  // start components that load once
  for (const component of once) {
    component.start()
  }

  // start components that load on each page change
  let loaded: IComponent[] = []

  document.addEventListener("turbolinks:load", () => {
    const cleanup = loaded.splice(0, loaded.length)
    for (const component of cleanup) {
      if (component.cleanup) {
        component.cleanup()
      }
    }

    for (const component of page) {
      component.start()
      loaded.push(component)
    }
  })
}
