// -- constants --
const kContainerId = "container"
const kDemoCoachmarkId = "demo-coachmark"
const kDemoBackId = "demo-back"
const kClassVisible = "is-visible"

const kInterceptedEvents = [
  "click",
  "confirm"
]

const kDemoPageCount = {
  "applicant": 6,
  "call-center": 6,
  "state": 3,
  "nonprofit": 9,
}

// -- state --
let listener: ((e: MouseEvent) => void) | null = null

// -- commands --
function ShowCoachmark() {
  // find coachmark and target
  const $coachmark = document.getElementById(kDemoCoachmarkId)
  const $target = $coachmark?.previousElementSibling
  if ($coachmark == null || $target == null) {
    return
  }

  // find container
  const $container = document.getElementById(kContainerId)
  if ($container == null) {
    return
  }

  // add coachmark to parent
  $container.appendChild($coachmark)

  // get popup / target rects
  const src = $coachmark.getBoundingClientRect()
  const dst = $target.getBoundingClientRect()

  // make rects relative to container
  const vr = $container.getBoundingClientRect()
  src.x -= vr.x
  dst.x -= vr.x

  // adjust window / popup positioning
  const padding = 150.0
  const vh = vr.height

  // center against viewable portion of large elements
  if (dst.top < vh && dst.height > vh) {
    dst.height = vh - dst.top
  }
  // scroll the target into view if necessary
  else if (dst.bottom + padding > vh) {
    $container.scrollTo({ top: dst.bottom + padding - vh })
  }

  // anchor popup to target
  $coachmark.style.cssText = (() => {
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

  // show coachmark
  $container.classList.toggle(kClassVisible, true)
}

function AdvanceDemoOnClick() {
  // clean up the old listener, if any
  if (listener != null) {
    for (const event of kInterceptedEvents) {
      document.removeEventListener(event as any, listener)
    }

    listener = null
  }

  // check that were on a slideshow page
  const matches = location.pathname.match(/^\/(.+)\/(\d+)$/)
  if (matches == null) {
    console.log("Not on slideshow page.")
    return
  }

  // add a global click interceptor that advances to the next page in this
  // section
  const role = matches[1] as keyof typeof kDemoPageCount
  const page = Number.parseInt(matches[2])

  listener = (event) => {
    if (event == null) {
      return
    }

    // check if this click was inside the back button
    let target = event.target as HTMLElement | null
    while (target != null && target.id !== kDemoBackId) {
      target = target.parentElement
    }

    if (target != null) {
      return
    }

    // otherwise intercept and advance page
    event.preventDefault()
    event.stopPropagation()

    // immediately navigate home if last page in section
    if (page == kDemoPageCount[role]) {
      location.href = "/"
      return
    }

    // otherwise, fade out the frame and advance
    const $container = document.getElementById(kContainerId)
    if ($container == null) {
      return
    }

    $container.classList.toggle(kClassVisible, false)
    setTimeout(() => {
      location.href = `/${role}/${page + 1}`
    }, 100)
  }

  for (const event of kInterceptedEvents) {
    document.addEventListener(event as any, listener)
  }
}

(function main() {
  document.addEventListener("turbolinks:load", () => {
    ShowCoachmark()
    AdvanceDemoOnClick()
  })
})()
