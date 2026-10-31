import { Controller } from "@hotwired/stimulus"

// Busca global (Ctrl/Cmd+K): consulta /search.json e navega com o teclado.
export default class extends Controller {
  static targets = ["dialog", "input", "results"]

  connect() {
    this.onKey = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === "k") { e.preventDefault(); this.open() }
    }
    document.addEventListener("keydown", this.onKey)
    this.dialogTarget.addEventListener("click", (e) => { if (e.target === this.dialogTarget) this.close() })
    this.dialogTarget.addEventListener("close", () => { this.inputTarget.value = ""; this.resultsTarget.innerHTML = "" })
  }

  disconnect() { document.removeEventListener("keydown", this.onKey) }

  open() {
    if (!this.dialogTarget.open) this.dialogTarget.showModal()
    this.inputTarget.focus()
  }

  close() { this.dialogTarget.close() }

  search() {
    clearTimeout(this.timer)
    const q = this.inputTarget.value.trim()
    if (q.length < 2) { this.resultsTarget.innerHTML = ""; return }
    this.timer = setTimeout(() => this.fetchResults(q), 160)
  }

  async fetchResults(q) {
    const resp = await fetch(`/search.json?q=${encodeURIComponent(q)}&limit=5`, { headers: { Accept: "application/json" } })
    if (!resp.ok) return
    this.render(await resp.json(), q)
  }

  render(data, q) {
    const grupos = [["issues", "Tarefas"], ["projects", "Projetos"], ["products", "Produtos"], ["pages", "Páginas"], ["users", "Pessoas"]]
    const html = grupos.filter(([k]) => data[k]?.length).map(([k, nome]) => `
      <div class="palette-group"><p>${nome}</p>${data[k].map((i) => `
        <a href="${i.url}" role="option" class="palette-item"><strong>${this.esc(i.title)}</strong><small>${this.esc(i.subtitle)}</small></a>`).join("")}</div>`).join("")
    this.resultsTarget.innerHTML = html || `<p class="palette-empty">Nada encontrado para “${this.esc(q)}”.</p>`
    this.items = [...this.resultsTarget.querySelectorAll(".palette-item")]
    this.select(0)
  }

  keydown(e) {
    if (e.key === "Escape") { e.preventDefault(); this.close(); return }
    if (!this.items?.length) return
    if (e.key === "ArrowDown") { e.preventDefault(); this.select(this.index + 1) }
    else if (e.key === "ArrowUp") { e.preventDefault(); this.select(this.index - 1) }
    else if (e.key === "Enter") { e.preventDefault(); this.items[this.index]?.click() }
  }

  select(i) {
    if (!this.items.length) return
    this.index = (i + this.items.length) % this.items.length
    this.items.forEach((el, n) => el.classList.toggle("selected", n === this.index))
    this.items[this.index].scrollIntoView({ block: "nearest" })
  }

  esc(s) { return String(s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c])) }
}
