import { kConsumer } from "src/Core"

// -- constants --
const DEMO_PAGE_COUNT = {
  "applicant": 6,
  "call-center": 0,
  "state": 0,
  "nonprofit": 0,
}

// -- commands --
function ShowCoachmark() {
  // find coachmark
  const $coachmark = document.getElementById("demo-coachmark")
  if ($coachmark == null) {
    return
  }

  // find anchor target and popup
  const $target = $coachmark.previousElementSibling
  const $popup = $coachmark.querySelector(".DemoCoachmark-popup") as HTMLElement
  if ($target == null || $popup == null) {
    return
  }

  // show coachmark
  document.body.appendChild($coachmark)
  $coachmark.classList.toggle("is-visible", true)

  // anchor popup to edge of target
  const src = $popup.getBoundingClientRect()
  const dst = $target.getBoundingClientRect()

  $popup.style.cssText = (() => {
    switch ($coachmark.dataset["demoAnchor"]) {
      case "bottom": return `
        top: ${dst.bottom}px;
        left: ${dst.left + (dst.width - src.width) / 2}px;
      `
      case "left": return `
        left: ${dst.left - src.width}px;
        top: ${dst.top + (dst.height - src.height) / 2}px;
      `
      case "right": return `
        left: ${dst.right}px;
        top: ${dst.top + (dst.height - src.height) / 2}px;
      `
      default: return ""
    }
  })()
}

function AdvanceDemoOnClick() {
  const matches = location.pathname.match(/^\/(.+)\/(\d+)$/)
  if (matches == null) {
    console.log("Not on demo page.")
    return
  }

  const role = matches[1] as keyof typeof DEMO_PAGE_COUNT
  const page = Number.parseInt(matches[2])

  document.addEventListener("click", (event) => {
    event?.preventDefault()
    event?.stopPropagation()

    if (page != DEMO_PAGE_COUNT[role]) {
      location.href = `/${role}/${page + 1}`
    }
  })
}

(function main() {
  kConsumer.disconnect()
  ShowCoachmark()
  AdvanceDemoOnClick()
})()
