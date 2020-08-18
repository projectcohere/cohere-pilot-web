// -- constants --
const kDemoBackId = "demo-back"
const kDemoPageCount = {
  "applicant": 6,
  "call-center": 6,
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

  // get popup / target rects
  const src = $popup.getBoundingClientRect()
  const dst = $target.getBoundingClientRect()

  // truncate target width / height if offscreen
  if (dst.left + dst.right > window.innerWidth) {
    dst.width = window.innerWidth
  }

  if (dst.top + dst.height > window.innerHeight) {
    dst.height = window.innerHeight - dst.top
  }

  // anchor popup to target
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
