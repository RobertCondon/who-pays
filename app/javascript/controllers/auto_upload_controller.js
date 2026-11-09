import { Controller } from "@hotwired/stimulus"

// Uploads as soon as files are chosen, no separate submit button needed.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
