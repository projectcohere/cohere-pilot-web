// -- constants --
const kContainerId = "container"
const kCoachmarkId = "demo-coachmark"
const kDemoBackId = "demo-back"
const kDemoPageCount = {
  "applicant": 6,
  "call-center": 6,
  "state": 3,
  "nonprofit": 1,
}

// -- commands --
function ShowCoachmark() {
  // find coachmark and target
  const $coachmark = document.getElementById("demo-coachmark")
  const $target = $coachmark?.previousElementSibling
  if ($coachmark == null || $target == null) {
    return
  }

  // find container
  const $container = document.getElementById(kContainerId)
  if ($container == null) {
    return
  }

  // show coachmark
  $container.appendChild($coachmark)
  $coachmark.classList.toggle("is-visible", true)

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
}

function AdvanceDemoOnClick() {
  const matches = location.pathname.match(/^\/(.+)\/(\d+)$/)
  if (matches == null) {
    console.log("Not on demo page.")
    return
  }

  const role = matches[1] as keyof typeof kDemoPageCount
  const page = Number.parseInt(matches[2])

  document.addEventListener("click", (event) => {
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

    if (page != kDemoPageCount[role]) {
      location.href = `/${role}/${page + 1}`
    } else {
      location.href = "/"
    }
  })
}

(function main() {
  document.addEventListener("turbolinks:load", () => {
    ShowCoachmark()
    AdvanceDemoOnClick()
  })
})()
