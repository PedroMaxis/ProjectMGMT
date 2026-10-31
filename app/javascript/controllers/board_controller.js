import { Controller } from "@hotwired/stimulus"

// Quadro Kanban com arrastar e soltar (API nativa de drag and drop, sem biblioteca).
// Ao soltar, o cartão muda de lugar na hora e o servidor confirma por PATCH /issues/:chave/move.
export default class extends Controller {
  static targets = ["column"]

  connect() {
    this.dragging = null
    this.element.addEventListener("dragstart", this.start)
    this.element.addEventListener("dragend", this.end)
    this.columnTargets.forEach((col) => {
      col.addEventListener("dragover", this.over)
      col.addEventListener("dragleave", this.leave)
      col.addEventListener("drop", this.drop)
    })
  }

  start = (e) => {
    const card = e.target.closest?.("[data-issue-key]")
    if (!card) return
    this.dragging = card
    this.origin = { column: card.closest("[data-status]"), next: card.nextElementSibling }
    card.classList.add("dragging")
    e.dataTransfer.effectAllowed = "move"
    e.dataTransfer.setData("text/plain", card.dataset.issueKey)
  }

  end = () => {
    this.dragging?.classList.remove("dragging")
    this.columnTargets.forEach((c) => c.classList.remove("over"))
    this.dragging = null
  }

  over = (e) => {
    if (!this.dragging) return
    e.preventDefault()
    const col = e.currentTarget
    col.classList.add("over")
    const list = col.querySelector("[data-cards]")
    const after = this.cardAfter(list, e.clientY)
    if (after == null) list.appendChild(this.dragging)
    else list.insertBefore(this.dragging, after)
  }

  leave = (e) => {
    if (!e.currentTarget.contains(e.relatedTarget)) e.currentTarget.classList.remove("over")
  }

  drop = async (e) => {
    e.preventDefault()
    const card = this.dragging
    if (!card) return
    const col = e.currentTarget
    col.classList.remove("over")
    const status = col.dataset.status
    const anterior = card.previousElementSibling?.dataset.issueId || ""
    this.refreshCounts()
    try {
      const token = document.querySelector("meta[name=csrf-token]")?.content
      const resp = await fetch(`/issues/${card.dataset.issueKey}/move`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", Accept: "application/json", "X-CSRF-Token": token },
        body: JSON.stringify({ status, after_id: anterior })
      })
      if (!resp.ok) throw new Error((await resp.json()).error || "Falha ao mover")
      card.classList.toggle("is-done", status === "done")
    } catch (err) {
      this.revert(card)
      this.toast(err.message)
    }
  }

  // elemento logo abaixo do cursor (ou nenhum, se for para o fim da coluna)
  cardAfter(list, y) {
    const cards = [...list.querySelectorAll("[data-issue-key]:not(.dragging)")]
    return cards.find((c) => y < c.getBoundingClientRect().top + c.offsetHeight / 2)
  }

  revert(card) {
    const { column, next } = this.origin
    const list = column.querySelector("[data-cards]")
    if (next && next.parentElement === list) list.insertBefore(card, next); else list.appendChild(card)
    this.refreshCounts()
  }

  refreshCounts() {
    this.columnTargets.forEach((col) => {
      const cards = col.querySelectorAll("[data-issue-key]")
      const counter = col.querySelector("[data-count]")
      if (counter) counter.textContent = cards.length
      const points = col.querySelector("[data-points]")
      if (points) points.textContent = [...cards].reduce((s, c) => s + (parseInt(c.dataset.points, 10) || 1), 0)
      col.classList.toggle("is-empty", cards.length === 0)
    })
  }

  toast(msg) {
    const el = document.createElement("div")
    el.className = "flash flash-danger flash-floating"
    el.textContent = msg
    document.body.appendChild(el)
    setTimeout(() => el.remove(), 4000)
  }
}
