import { Controller } from '@hotwired/stimulus'
import { Turbo } from '@hotwired/turbo-rails'

// Native HTML5 drag and drop between the kanban columns.
// The card is moved in the DOM immediately; the server persists the new
// order and broadcasts a page refresh to everyone else on the board.
export default class extends Controller {
  static targets = ['list']

  dragstart(event) {
    const card = event.target.closest?.('[data-move-url]')
    if (!card) return
    if (card.querySelector('.card-form')) return event.preventDefault() // being edited

    this.dragged = card
    this.origin = this.placementOf(card)
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('text/plain', card.id)
    requestAnimationFrame(() => card.classList.add('is-dragging'))
  }

  dragover(event) {
    if (!this.dragged) return
    const list = event.target.closest('[data-sortable-target="list"]')
    if (!list) return

    event.preventDefault()
    const before = this.cardAfterPointer(list, event.clientY)
    if (before) {
      if (before !== this.dragged.nextElementSibling) list.insertBefore(this.dragged, before)
    } else if (list.lastElementChild !== this.dragged) {
      list.append(this.dragged)
    }
  }

  drop(event) {
    if (this.dragged) event.preventDefault()
  }

  async dragend() {
    const card = this.dragged
    if (!card) return

    card.classList.remove('is-dragging')
    this.dragged = null

    const { status, position } = this.placementOf(card)
    if (status === this.origin.status && position === this.origin.position) return

    const response = await Turbo.fetch(card.dataset.moveUrl, {
      method: 'PATCH',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content ?? ''
      },
      body: JSON.stringify({ status, position })
    })

    if (response.ok) {
      Turbo.renderStreamMessage(await response.text())
    } else {
      Turbo.visit(window.location.href, { action: 'replace' })
    }
  }

  placementOf(card) {
    const list = card.closest('[data-sortable-target="list"]')
    const cards = [...list.querySelectorAll('[data-move-url]')]
    return { status: list.dataset.status, position: cards.indexOf(card) }
  }

  cardAfterPointer(list, y) {
    return [...list.querySelectorAll('[data-move-url]:not(.is-dragging)')].find((card) => {
      const box = card.getBoundingClientRect()
      return y < box.top + box.height / 2
    })
  }
}
