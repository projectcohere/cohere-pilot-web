let count = 0

export function generate() {
  return `local-${count++}`
}
