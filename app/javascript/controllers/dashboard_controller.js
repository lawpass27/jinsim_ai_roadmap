import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["developmentBoard", "studyBoard", "planningBoard", "milestoneBoard"]

  connect() {
    // Initialize smooth scrolling for anchor links
    this.initSmoothScrolling()
  }

  showBoard(event) {
    const boardType = event.currentTarget.dataset.board
    
    // Remove active class from all tabs
    const tabs = this.element.querySelectorAll('.board-tab')
    tabs.forEach(tab => {
      tab.classList.remove('border-primary', 'text-foreground', 'active')
      tab.classList.add('border-transparent', 'text-muted-foreground')
    })
    
    // Add active class to clicked tab
    event.currentTarget.classList.remove('border-transparent', 'text-muted-foreground')
    event.currentTarget.classList.add('border-primary', 'text-foreground', 'active')
    
    // Hide all boards
    const boards = [
      this.developmentBoardTarget,
      this.studyBoardTarget,
      this.planningBoardTarget,
      this.milestoneBoardTarget
    ]
    
    boards.forEach(board => board.classList.add('hidden'))
    
    // Show selected board
    switch(boardType) {
      case 'development':
        this.developmentBoardTarget.classList.remove('hidden')
        break
      case 'study':
        this.studyBoardTarget.classList.remove('hidden')
        break
      case 'planning':
        this.planningBoardTarget.classList.remove('hidden')
        break
      case 'milestone':
        this.milestoneBoardTarget.classList.remove('hidden')
        break
    }
  }

  initSmoothScrolling() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        e.preventDefault()
        const target = document.querySelector(this.getAttribute('href'))
        if (target) {
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          })
        }
      })
    })
  }
}