import { Controller } from "@hotwired/stimulus"

// Painel lateral da tarefa (aberto por Turbo Frame). Ao fechar, recarrega o quadro se algo mudou.
export default class extends Controller {
  connect() {
    // a marca fica no turbo-frame: o envio troca o conteúdo e este controller é recriado
    this.quadro = this.element.closest("turbo-frame")
    this.onSubmit = () => { if (this.quadro) this.quadro.dataset.dirty = "1" }
    this.element.addEventListener("turbo:submit-end", this.onSubmit)
    this.onKey = (e) => { if (e.key === "Escape") this.close() }
    document.addEventListener("keydown", this.onKey)
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.onSubmit)
    document.removeEventListener("keydown", this.onKey)
  }

  close(event) {
    event?.preventDefault()
    const quadro = this.quadro
    if (quadro?.dataset.dirty) { delete quadro.dataset.dirty; window.Turbo.visit(window.location.href, { action: "replace" }); return }
    if (quadro) { quadro.innerHTML = ""; quadro.removeAttribute("src") }
  }
}
