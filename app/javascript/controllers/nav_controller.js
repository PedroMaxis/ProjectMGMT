import { Controller } from "@hotwired/stimulus"

// Menu lateral recolhível no celular
export default class extends Controller {
  static targets = ["side"]
  toggle() { this.sideTarget.classList.toggle("open") }
  connect() { document.addEventListener("turbo:before-visit", this.close) }
  disconnect() { document.removeEventListener("turbo:before-visit", this.close) }
  close = () => this.sideTarget.classList.remove("open")
}
