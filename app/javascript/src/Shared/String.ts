export function pluralize(label: string, quantity: number): string {
  if (quantity === 1) {
    return label
  } else {
    return label + "s"
  }
}
