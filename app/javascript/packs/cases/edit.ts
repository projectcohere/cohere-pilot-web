// -- impls --
class ShowEdit {
  // -- props --
  // -- props/el
  private $addIncomeRows: HTMLElement
  private $addIncomeRow: HTMLElement
  private $addIncomeLink: HTMLElement

  // -- lifecycle --
  static start() {
    const page = new ShowEdit()
    page.onMount()
  }

  private onMount() {
    const $c = this

    $c.$addIncomeRows = $c.getById("add-income-rows")
    $c.$addIncomeRow = $c.getById("add-income-row").cloneNode(true) as HTMLElement

    $c.$addIncomeLink = $c.getById("add-income-link")
    $c.$addIncomeLink.onclick = $c.didClickAddIncomeLink
  }

  // -- events --
  private didClickAddIncomeLink = () => {
    const $c = this
    $c.addIncomeRow()
  }

  // -- commands --
  private addIncomeRow() {
    const $c = this

    // create a new row from the template
    const row = $c.$addIncomeRow.cloneNode(true) as HTMLElement

    // clean inputs and assign the right index
    const index = $c.$addIncomeRows.children.length
    const inputs = Array.from(row.getElementsByTagName("input"))

    for (const input of inputs) {
      input.value = ""
      $c.setIndexOfInput(input, index)
    }

    // add the row to the list
    $c.$addIncomeRows.appendChild(row)
  }

  // -- queries --
  private getById(id: string): HTMLElement {
    const el = document.getElementById(id)
    if (el == null) {
      throw `Failed to find element with id ${id}!`
    }

    el.removeAttribute("id")
    return el
  }

  // -- el --
  private setIndexOfInput(input: HTMLInputElement, index: number) {
    input.setAttribute("id", input.id.replace(/\d+/, index.toString()))
    input.setAttribute("name", input.name.replace(/\d+/, index.toString()))
  }
}

// -- main --
(() => {
  ShowEdit.start()
})()
