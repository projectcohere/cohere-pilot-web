import { pluralize } from "./String"

// -- constants --
const kDateConfig = {
  month: "numeric",
  day: "numeric",
  hour: "numeric",
  minute: "numeric",
  hour12: true
}

// -- impls --
// -- impls/commands
export function formatTimes($times: NodeListOf<HTMLTimeElement>, format: (d: Date) => string) {
  for (let i = 0; i < $times.length; i++) {
    const $time = $times[i]
    const timestamp = new Date($time.dateTime)
    $time.textContent = format(timestamp)
  }
}

// -- impls/queries
export function getReadableTime(date: Date): string {
  return date.toLocaleString("en-US", kDateConfig)
}

export function getReadableTimeSince(date: Date): string {
  const delta = Math.max(new Date().getTime() - date.getTime(), 0)
  const minutes = Math.floor(delta / 1000 / 60)
  const hours = Math.floor(minutes / 60)

  if (minutes < 1) {
    return "Just now"
  } else if (minutes < 60) {
    return `${minutes} ${pluralize("minute", minutes)} ago`
  } else if (hours < 24) {
    return `${hours} ${pluralize("hour", hours)} ago`
  } else {
    return getReadableTime(date)
  }
}
