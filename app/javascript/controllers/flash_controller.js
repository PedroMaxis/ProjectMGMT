import { Controller } from "@hotwired/stimulus"

// Aviso que some sozinho depois de alguns segundos
export default class extends Controller {
  connect() { this.timer = setTimeout(() => this.close(), 5000) }
  disconnect() { clearTimeout(this.timer) }
  close() { this.element.remove() }
}
