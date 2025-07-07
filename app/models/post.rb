class Post < ApplicationRecord
  # Associations
  belongs_to :user
  
  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :author_name, presence: true
  
  # Milestone validations
  validates :milestone_date, presence: true, if: :milestone?
  validates :milestone_status, presence: true, inclusion: { in: STATUSES }, if: :milestone?
  
  # Constants
  CATEGORIES = %w[study planning development milestone]
  STATUSES = %w[planned in_progress completed]
  
  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_category, ->(category) { where(category: category) }
  
  # Methods
  def milestone?
    category == 'milestone'
  end
  
  def category_korean
    {
      'study' => 'AI스터디',
      'planning' => '서비스기획',
      'development' => '서비스개발',
      'milestone' => '마일스톤'
    }[category]
  end
  
  def milestone_status_korean
    return nil unless milestone?
    {
      'planned' => '계획됨',
      'in_progress' => '진행중',
      'completed' => '완료됨'
    }[milestone_status]
  end
end
