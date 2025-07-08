import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    const menu = document.getElementById('mobileMenu')
    if (menu) {
      menu.classList.toggle('hidden')
    }
  }

  close() {
    const menu = document.getElementById('mobileMenu')
    if (menu) {
      menu.classList.add('hidden')
    }
  }
}