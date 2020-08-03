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
  $coachmark.classList.toggle("is-visible", true)

  // anchor popup to right edge of target
  const src = $popup.getBoundingClientRect()
  const dst = $target.getBoundingClientRect()
  $popup.style.cssText = `
    left: ${dst.right}px;
    top: ${dst.top + (dst.height - src.height) / 2}px;
  `
}

function AdvanceDemoOnClick() {
  const pages = [
    "/s01_sign_in.html",
    "/s02_source_list.html",
  ]

  const index = pages.indexOf(location.pathname)
  if (index == -1) {
    console.log("Not on demo page.")
    return
  }

  document.addEventListener("click", (event) => {
    event?.preventDefault()
    event?.stopPropagation()

    if (index != pages.length - 1) {
      location.href = pages[index + 1]
    }
  })
}

(function main() {
  ShowCoachmark()
  AdvanceDemoOnClick()
})()
