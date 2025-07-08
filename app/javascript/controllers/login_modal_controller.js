import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["errorMessage"]

  connect() {
    // Close modal on ESC key
    document.addEventListener('keydown', this.handleEscape.bind(this))
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleEscape.bind(this))
  }

  open(event) {
    if (event) event.preventDefault()
    const modal = document.getElementById('loginModal')
    if (modal) {
      modal.classList.remove('hidden')
      document.body.style.overflow = 'hidden'
      
      // Focus on first input
      setTimeout(() => {
        const firstInput = modal.querySelector('input[type="email"]')
        if (firstInput) firstInput.focus()
      }, 100)
    }
  }

  close(event) {
    if (event) event.preventDefault()
    const modal = document.getElementById('loginModal')
    if (modal) {
      modal.classList.add('hidden')
      document.body.style.overflow = 'auto'
      
      // Hide error message
      const errorDiv = document.getElementById('loginError')
      if (errorDiv) errorDiv.classList.add('hidden')
      
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

  fillCredentials(event) {
    const email = event.currentTarget.dataset.email
    const password = event.currentTarget.dataset.password
    
    const emailInput = document.querySelector('#loginModal input[type="email"]')
    const passwordInput = document.querySelector('#loginModal input[type="password"]')
    
    if (emailInput) emailInput.value = email
    if (passwordInput) passwordInput.value = password
  }

  handleError(event) {
    const errorDiv = document.getElementById('loginError')
    if (errorDiv) {
      const errorMessage = errorDiv.querySelector('[data-login-modal-target="errorMessage"]')
      if (errorMessage) {
        errorMessage.textContent = '로그인에 실패했습니다. 이메일과 비밀번호를 확인해주세요.'
      }
      errorDiv.classList.remove('hidden')
    }
  }

  handleSuccess(event) {
    // Redirect to root path on successful login
    window.location.href = '/'
  }
}