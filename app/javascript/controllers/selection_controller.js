import { Controller } from "@hotwired/stimulus"

// Tracks ticked item checkboxes, drives the sticky pay bar and the "Who's paying?" dialog.
export default class extends Controller {
  static targets = ["item", "all", "bar", "count", "total", "dialog", "summary", "newName"]

  connect() { this.refresh() }

  get selectable() { return this.itemTargets.filter(cb => !cb.disabled) }
  get checked() { return this.selectable.filter(cb => cb.checked) }

  toggleAll(event) {
    this.selectable.forEach(cb => { cb.checked = event.target.checked })
    this.refresh()
  }

  clear() {
    this.itemTargets.concat(this.allTargets).forEach(cb => { cb.checked = false })
    this.refresh()
  }

  openDialog() {
    this.summaryTarget.textContent = `${this.countTarget.textContent} · ${this.totalTarget.textContent}`
    this.dialogTarget.showModal()
    this.newNameTarget.focus()
  }

  closeDialog() { this.dialogTarget.close() }

  // After paying, the page re-renders; close the dialog and start fresh.
  submitted(event) {
    if (!event.detail.success) return
    if (this.dialogTarget.open) this.dialogTarget.close()
    this.newNameTarget.value = ""
    this.clear()
  }

  refresh() {
    const checked = this.checked
    const cents = checked.reduce((sum, cb) => sum + Number(cb.dataset.price), 0)

    this.barTarget.hidden = checked.length === 0
    this.countTarget.textContent = `${checked.length} item${checked.length === 1 ? "" : "s"}`
    this.totalTarget.textContent = "$" + (cents / 100).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })

    this.allTargets.forEach(all => {
      const n = checked.length, total = this.selectable.length
      all.disabled = total === 0
      all.checked = n > 0 && n === total
      all.indeterminate = n > 0 && n < total
    })
    this.itemTargets.forEach(cb => cb.closest("tr")?.classList.toggle("is-selected", cb.checked))
  }
}
