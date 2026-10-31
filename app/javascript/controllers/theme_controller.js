import { Controller } from "@hotwired/stimulus"

// Alterna entre tema claro e escuro e lembra a escolha (o <script> do <head> aplica antes de pintar, sem piscar).
export default class extends Controller {
  toggle() {
    const atual = document.documentElement.dataset.theme === "dark" ? "dark" : "light"
    const novo = atual === "dark" ? "light" : "dark"
    document.documentElement.dataset.theme = novo
    try { localStorage.setItem("prumo.theme", novo) } catch (e) { /* sem storage */ }
  }
}
