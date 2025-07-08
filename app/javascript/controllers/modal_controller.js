import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    // Close modal on ESC key
    document.addEventListener('keydown', this.handleEscape.bind(this))
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleEscape.bind(this))
  }

  open(event) {
    event.preventDefault()
    const modal = document.getElementById('writeModal')
    if (modal) {
      modal.classList.remove('hidden')
      document.body.style.overflow = 'hidden'
      
      // Focus on first input
      setTimeout(() => {
        const firstInput = modal.querySelector('select, input, textarea')
        if (firstInput) firstInput.focus()
      }, 100)
    }
  }

  close(event) {
    if (event) event.preventDefault()
    const modal = document.getElementById('writeModal')
    if (modal) {
      modal.classList.add('hidden')
      document.body.style.overflow = 'auto'
      
      // Reset form if exists
      const form = modal.querySelector('form')
      if (form) form.reset()
    }
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) {
      this.close(event)
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      this.close()
    }
  }
}