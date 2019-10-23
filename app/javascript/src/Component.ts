// -- types --
export interface IComponent {
  start(): void
}

// -- impls --
export function start(...components: IComponent[]) {
  for (const component of components) {
    component.start()
  }
}
