// Mobile menu toggle
function toggleMobileMenu() {
    const mobileMenu = document.getElementById('mobileMenu');
    mobileMenu.classList.toggle('hidden');
}

// Board tab functionality
function showBoard(boardType) {
    // Remove active class from all tabs
    document.querySelectorAll('.board-tab').forEach(tab => {
        tab.classList.remove('border-primary', 'text-foreground');
        tab.classList.add('border-transparent', 'text-muted-foreground');
    });
    
    // Hide all board content
    document.querySelectorAll('.board-content').forEach(content => {
        content.classList.add('hidden');
    });
    
    // Activate selected tab
    event.target.classList.remove('border-transparent', 'text-muted-foreground');
    event.target.classList.add('border-primary', 'text-foreground');
    
    // Show selected board content
    document.getElementById(boardType + '-board').classList.remove('hidden');
}

// Modal functions
function openWriteModal() {
    document.getElementById('writeModal').classList.remove('hidden');
    document.body.style.overflow = 'hidden';
    // Focus on first input
    setTimeout(() => {
        document.getElementById('category').focus();
    }, 100);
}

function closeWriteModal() {
    document.getElementById('writeModal').classList.add('hidden');
    document.body.style.overflow = 'auto';
    
    // Reset form
    document.getElementById('writeForm').reset();
    updateCharCount();
}

// Character counter
function updateCharCount() {
    const content = document.getElementById('content');
    const charCount = document.getElementById('charCount');
    
    if (content && charCount) {
        const count = content.value.length;
        charCount.textContent = `${count.toLocaleString()} 글자`;
        
        // Color based on character count
        if (count > 5000) {
            charCount.className = 'text-red-500';
        } else if (count > 3000) {
            charCount.className = 'text-yellow-500';
        } else {
            charCount.className = 'text-muted-foreground';
        }
    }
}

// Submit post
function submitPost(event) {
    event.preventDefault();
    
    const category = document.getElementById('category').value;
    const title = document.getElementById('title').value.trim();
    const content = document.getElementById('content').value.trim();
    const attachment = document.getElementById('attachment').files[0];
    
    // Validation
    if (!category || !title || !content) {
        alert('모든 필수 항목을 입력해주세요.');
        return;
    }
    
    if (title.length > 255) {
        alert('제목은 255자 이내로 입력해주세요.');
        return;
    }

    // Create post data
    const postData = {
        category: category,
        title: title,
        content: content,
        attachment: attachment ? attachment.name : null,
        author: getCurrentUser(),
        date: new Date().toLocaleDateString('ko-KR')
    };

    // Add to board
    addPostToBoard(postData);
    
    // Success notification
    showNotification('글이 성공적으로 발행되었습니다! 🎉', 'success');
    
    // Close modal
    closeWriteModal();
}

// Get current user (simulation)
function getCurrentUser() {
    const lawyers = ['이정민', '윤두철', '류제성', '장우혁'];
    return lawyers[Math.floor(Math.random() * lawyers.length)];
}

// Add post to board
function addPostToBoard(postData) {
    const boardId = postData.category + '-board';
    const board = document.getElementById(boardId);
    
    if (board) {
        const newPostHTML = `
            <div class="flex items-center justify-between p-4 border rounded-lg hover:bg-accent/50 transition-colors cursor-pointer border-green-200 bg-green-50 animate-fade-in">
                <div class="space-y-2">
                    <div class="flex items-center space-x-2">
                        <h4 class="font-medium">${postData.title}</h4>
                        <span class="inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 border-transparent bg-green-100 text-green-800">
                            NEW
                        </span>
                    </div>
                    <div class="flex items-center space-x-4 text-sm text-muted-foreground">
                        <span>${postData.author}</span>
                        <span>${postData.date}</span>
                    </div>
                </div>
                <div class="flex items-center space-x-4 text-sm text-muted-foreground">
                    <span class="flex items-center space-x-1">
                        <span>💬</span>
                        <span>0</span>
                    </span>
                    <span class="flex items-center space-x-1">
                        <span>👁</span>
                        <span>1</span>
                    </span>
                </div>
            </div>
        `;
        
        board.insertAdjacentHTML('afterbegin', newPostHTML);
    }
}

// Show notification
function showNotification(message, type = 'info') {
    const notification = document.createElement('div');
    notification.className = `fixed top-4 right-4 z-50 rounded-lg border bg-card text-card-foreground shadow-lg p-4 animate-slide-in ${
        type === 'success' ? 'border-green-200 bg-green-50' : 'border-blue-200 bg-blue-50'
    }`;
    notification.innerHTML = `
        <div class="flex items-center space-x-2">
            <span class="text-lg">${type === 'success' ? '✅' : 'ℹ️'}</span>
            <span class="font-medium">${message}</span>
        </div>
    `;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// Event listeners
document.addEventListener('DOMContentLoaded', function() {
    // Character counter
    const contentTextarea = document.getElementById('content');
    if (contentTextarea) {
        contentTextarea.addEventListener('input', updateCharCount);
        updateCharCount();
    }

    // ESC key to close modal
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            closeWriteModal();
        }
    });

    // Close mobile menu when clicking on nav links
    document.querySelectorAll('#mobileMenu a').forEach(link => {
        link.addEventListener('click', () => {
            document.getElementById('mobileMenu').classList.add('hidden');
        });
    });

    // Smooth scrolling
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
});