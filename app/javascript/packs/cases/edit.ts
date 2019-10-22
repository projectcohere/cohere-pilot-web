
// -- types --
interface IncomeRowField {
  label: Element
  input: HTMLInputElement
}

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
    this.$incomeRowTemplate = this.createTemplateFromIncomeRow(this.getById("income-row-template"))

    this.$incomeRows = this.getById("income-rows")
    this.$incomeRows.addEventListener("click", this.didClickDeleteIncomeLink)

    this.$addIncomeLink = this.getById("add-income-link")
    this.$addIncomeLink.addEventListener("click", this.didClickAddIncomeLink)
  }

  // -- events --
  private didClickAddIncomeLink = () => {
    this.addIncomeRow()
  }

  private didClickDeleteIncomeLink = (event: MouseEvent) => {
    // filter to clicks on a delete link
    const incomeRowDeleteLink = event.target as Element
    if (this.isIncomeRowDeleteLink(incomeRowDeleteLink)) {
      this.removeIncomeRow(incomeRowDeleteLink.parentElement)
    }
  }

  // -- commands --
  private addIncomeRow() {
    // create a new row from the template
    const row = this.$incomeRowTemplate.cloneNode(true) as Element

    // assign the right index
    const index = this.$incomeRows.children.length
    this.setIndexOfIncomeRow(row, index)

    // add the row to the list
    this.$incomeRows.appendChild(row)
  }

  private removeIncomeRow(incomeRow: Element) {
    if (this.$incomeRows.children.length <= 1) {
      throw "tried to remove an income row when there was only one left!"
    }

    // remove the matching income row
    this.$incomeRows.removeChild(incomeRow)

    // re-assign the row indices
    let index = 0
    for (const incomeRow of Array.from(this.$incomeRows.children)) {
      this.setIndexOfIncomeRow(incomeRow, index)
      index++
    }
  }

  // -- queries --
  private getById(id: string): Element {
    const el = document.getElementById(id)
    if (el == null) {
      throw `failed to find element with id ${id}!`
    }

    el.removeAttribute("id")
    return el
  }

  // -- el --
  // -- el/income-row
  private getFieldsFromIncomeRow(row: Element): IncomeRowField[] {
    return Array.from(row.getElementsByTagName("label")).map((label) => ({
      label,
      input: label.lastElementChild as HTMLInputElement
    }))
  }

  private setIndexOfIncomeRow(row: Element, index: number) {
    for (const field of this.getFieldsFromIncomeRow(row)) {
      const id = field.input.id.replace(/\d+/, index.toString())
      field.label.setAttribute("for", id)
      field.input.setAttribute("id", id)
      field.input.setAttribute("name", field.input.name.replace(/\d+/, index.toString()))
    }
  }

  private isIncomeRowDeleteLink(element: Element | null): boolean {
    return element != null && element.className.includes("CaseForm-deleteIncome")
  }

  private createTemplateFromIncomeRow(source: Element): Element {
    const template = source.cloneNode(true) as Element
    for (const field of this.getFieldsFromIncomeRow(template)) {
      field.input.value = ""
    }

    return template
  }
}

// -- main --
ShowEdit.start()
