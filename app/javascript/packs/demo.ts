// -- constants --
const kFrameId = "frame"
const kContainerId = "container"
const kDemoCoachmarkId = "demo-coachmark"
const kClassVisible = "is-visible"

// -- state --
let listeners: Map<any[], any> | null

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

  // find the frame
  const $frame = document.getElementById(kFrameId)
  $frame?.classList.toggle(kClassVisible, true)
}

function RegisterListeners() {
  // clean up the old listener, if any
  if (listeners != null) {
    for (const [events, listener] of listeners.entries()) {
      for (const event of events) {
        document.removeEventListener(event, listener)
      }
    }

    listeners = null
  }

  // check that were on a slideshow page
  const matches = location.pathname.match(/^\/(.+)\/(\d+)$/)
  if (matches == null) {
    console.log("Not on slideshow page.")
    return
  }

  // register listeners
  listeners = new Map<any[], any>()

  // add a link click interceptor that ignores any non-demo link
  listeners.set(["click"], (event: MouseEvent) => {
    const tags = new Set(["A", "INPUT"])

    // check if this click is on a matching tag
    let target = event.target as HTMLElement | null
    while (target != null && !tags.has(target.tagName)) {
      target = target.parentElement as HTMLElement
    }

    if (target == null) {
      return
    }

    // if it's a file input, prevent it
    if (target.tagName == "INPUT") {
      DidClickInput(event, target as HTMLInputElement)
    } else {
      DidClickLink(event, target as HTMLLinkElement)
    }
  })

  listeners.set(["confirm"], (event: Event) => {
    CancelEvent(event)
  })

  listeners.set(["submit"], (event: Event) => {
    DidSubmitForm(event)
  })

  // add all listeners
  for (const [events, listener] of listeners.entries()) {
    for (const event of events) {
      document.addEventListener(event, listener)
    }
  }
}

// -- events --
function CancelEvent(event: Event) {
  event.preventDefault()
  event.stopPropagation()
}

function DidClickInput(event: Event, input: HTMLInputElement) {
  const type = input.getAttribute("type")
  if (type == "file" || type == "submit") {
    CancelEvent(event)
  }
}

function DidClickLink(event: Event, link: HTMLLinkElement) {
  // allow document links to work
  if (link.target === "_blank") {
    return
  }

  // ignore non-demo links
  if (link.dataset["demo"] == null) {
    CancelEvent(event)
    return
  }

  // otherwise, examine the demo link
  const url = new URL(link.href)

  // allow root links to work normally
  if (url.pathname === "/") {
    return
  }

  // if this is a non-root link, stop navigation and crossfade
  CancelEvent(event)
  const $frame = document.getElementById(kFrameId)
  $frame?.classList.toggle(kClassVisible, false)
  setTimeout(() => { location.href = url.href }, 100)
}

function DidSubmitForm(event: Event) {
  // disable form submission
  CancelEvent(event)

  // if necessary re-enable button
  const form = event.target as HTMLElement
  const button = form.querySelector("input[type='submit']")
  button?.removeAttribute("disabled")
}

// -- main --
(function main() {
  document.addEventListener("turbolinks:load", () => {
    ShowCoachmark()
    RegisterListeners()
  })
})()
