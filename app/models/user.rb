class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # Note: :registerable is removed to disable user registration
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  
  # Associations
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  
  # Validations
  validates :name, presence: true
  
  # Methods
  def display_name
    admin? ? "#{name} (관리자)" : name
  end
end
