import { Controller } from "@hotwired/stimulus"

// Editor com pré-visualização ao vivo: o servidor renderiza o Markdown (e sanitiza), o navegador só mostra.
export default class extends Controller {
  static targets = ["input", "preview"]

  connect() { this.update() }

  update() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.render(), 250)
  }

  async render() {
    const token = document.querySelector("meta[name=csrf-token]")?.content
    const body = new URLSearchParams({ text: this.inputTarget.value })
    const resp = await fetch("/markdown", { method: "POST", headers: { "X-CSRF-Token": token, Accept: "text/html" }, body })
    if (resp.ok) this.previewTarget.innerHTML = (await resp.text()) || "<p class='muted'>A pré-visualização aparece aqui.</p>"
  }
}
