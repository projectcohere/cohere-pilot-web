// -- types --
export interface IComponent {
  isDocumentDependent: boolean
  start(): void
}

// -- impls --
export function start(...components: IComponent[]) {
  for (const component of components) {
    if (!component.isDocumentDependent) {
      component.start()
    } else if (document.readyState === "complete" || document.readyState === "interactive") {
      setTimeout(() => component.start(), 1)
    } else {
      document.addEventListener("DOMContentLoaded", () => component.start());
    }
  }
}
