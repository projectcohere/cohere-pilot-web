// -- impls --
class ShowEdit {
  // -- props --
  // -- props/el
  private $incomeRows: Element
  private $incomeRowTemplate: Element
  private $addIncomeLink: Element

  // -- lifecycle --
  static start() {
    const page = new ShowEdit()
    page.onMount()
  }

  private onMount() {
    const $c = this

    $c.$incomeRowTemplate = $c.createTemplateFromIncomeRow($c.getById("income-row-template"))

    $c.$incomeRows = $c.getById("income-rows")
    $c.$incomeRows.addEventListener("click", $c.didClickDeleteIncomeLink)

    $c.$addIncomeLink = $c.getById("add-income-link")
    $c.$addIncomeLink.addEventListener("click", $c.didClickAddIncomeLink)
  }

  // -- events --
  private didClickAddIncomeLink = () => {
    const $c = this
    $c.addIncomeRow()
  }

  private didClickDeleteIncomeLink = (event: MouseEvent) => {
    const $c = this

    // filter to clicks on a delete link
    const incomeRowDeleteLink = event.target as Element
    if ($c.isIncomeRowDeleteLink(incomeRowDeleteLink)) {
      $c.removeIncomeRow(incomeRowDeleteLink.parentElement)
    }
  }

  // -- commands --
  private addIncomeRow() {
    const $c = this

    // create a new row from the template
    const row = $c.$incomeRowTemplate.cloneNode(true) as Element

    // assign the right index
    const index = $c.$incomeRows.children.length
    $c.setIndexOfIncomeRow(row, index)

    // add the row to the list
    $c.$incomeRows.appendChild(row)
  }

  private removeIncomeRow(incomeRow: Element) {
    const $c = this

    // remove the matching income row
    $c.$incomeRows.removeChild(incomeRow)

    // re-assign the row indices
    let index = 0
    for (const incomeRow of Array.from($c.$incomeRows.children)) {
      $c.setIndexOfIncomeRow(incomeRow, index)
      index++
    }
  }

  // -- queries --
  private getById(id: string): Element {
    const el = document.getElementById(id)
    if (el == null) {
      throw `Failed to find element with id ${id}!`
    }

    el.removeAttribute("id")
    return el
  }

  // -- el --
  // -- el/income-row
  private getInputsFromIncomeRow(row: Element): HTMLInputElement[] {
    return Array.from(row.getElementsByTagName("input"))
  }

  private setIndexOfIncomeRow(row: Element, index: number) {
    const $c = this
    for (const input of $c.getInputsFromIncomeRow(row)) {
      input.setAttribute("id", input.id.replace(/\d+/, index.toString()))
      input.setAttribute("name", input.name.replace(/\d+/, index.toString()))
    }
  }

  private createTemplateFromIncomeRow(source: Element): Element {
    const $c = this

    const template = source.cloneNode(true) as Element
    for (const input of $c.getInputsFromIncomeRow(template)) {
      input.value = ""
    }

    return template
  }

  private isIncomeRowDeleteLink(element: Element | null): boolean {
    return element != null && element.className.includes("CaseForm-incomeDelete")
  }
}

// -- main --
(() => {
  ShowEdit.start()
})()
