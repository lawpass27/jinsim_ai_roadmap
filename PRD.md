# jinsim_ai_roadmap MVP 기획서

## 전제조건
이 기획서는 다음 명령어로 Rails 8 프로젝트가 이미 생성된 상태를 가정합니다:
```bash
rails new jinsim_ai_roadmap -d sqlite3 -c tailwind
cd jinsim_ai_roadmap
```

## 1. 프로젝트 개요

**목적**: 법무법인 진심의 AI 기반 법률문서 작성 서비스 개발 과정을 체계적으로 기록하고 공유하여, 4명의 변호사가 효율적으로 협업할 수 있도록 지원

**대상**: 법무법인 진심의 4명의 변호사
- 이정민 대표변호사
- 윤두철 변호사
- 류제성 변호사
- 장우혁 변호사

**핵심 가치**: 변호사들이 스터디 내용과 기획 진행사항을 입력하면 전체 진행 상황을 한눈에 볼 수 있다

**기술 스택** (이미 설정됨):
- Ruby on Rails 8 (프로젝트 생성 완료)
- SQLite3 (개발 환경으로 설정됨)
- Tailwind CSS (설치 완료)

**추가 필요한 gem**:
- Devise (인증)
- Stimulus (마일스톤 인터랙션)

**디자인** (Tailwind CSS 이미 설정됨):
- 메인 컬러: #3B82F6 (신뢰감 있는 파란색)
- 모바일 우선 반응형
- 깔끔하고 전문적인 UI
- 마일스톤 타임라인 시각화

## 2. 기능 범위

### 포함 (MVP)
- 로그인 기능 (계정은 미리 생성, 회원가입 기능 없음)
- AI스터디, 서비스기획, 서비스개발 게시판
- 마일스톤 관리 시스템 (팀 공동 관리)
- 게시물 작성/조회/수정/삭제 (권한별 차등)
- 마일스톤 타임라인 시각화 (2025.6.18 시작)
- 원페이지 대시보드에서 전체 현황 파악
- 마일스톤 전용 입력 양식 (날짜, 상태 관리)
- 관리자 기능 (윤두철 변호사)

### 제외 (다음 버전)
- 소셜 로그인
- 파일 업로드/다운로드
- 댓글 기능
- 이메일 알림
- 외부 공유 기능
- 고급 통계/분석 대시보드
- API 제공
- 실시간 채팅
- 다국어 지원

## 3. 데이터 모델

### User (사용자)
```ruby
class User < ApplicationRecord
  # Devise modules (registerable 제거 - 회원가입 비활성화)
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
  
  # Associations
  has_many :posts, dependent: :destroy
  
  # Validations
  validates :name, presence: true
  
  # Methods
  def display_name
    admin? ? "#{name} (관리자)" : name
  end
end
```

**필드**:
- email: 이메일 (필수, 고유)
- password: 비밀번호 (암호화)
- name: 이름 (필수)
- admin: 관리자 여부 (boolean, 기본값 false)
- created_at: 가입일시 (자동)
- updated_at: 수정일시 (자동)

### Post (게시물)
```ruby
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
```

**필드**:
- title: 제목 (string, 필수, 최대 255자)
- content: 내용 (text, 필수)
- category: 카테고리 (string, 필수)
  - "study" (AI스터디)
  - "planning" (서비스기획)
  - "development" (서비스개발)
  - "milestone" (마일스톤)
- author_name: 작성자 이름 (string, 필수)
- user_id: 작성자 ID (integer, 필수, 외래키)
- **마일스톤 전용 필드**:
  - milestone_date: 마일스톤 날짜 (date)
  - milestone_status: 진행 상태 (string)
    - "planned" (계획됨)
    - "in_progress" (진행중) 
    - "completed" (완료됨)
  - last_editor_name: 마지막 수정자 이름 (string)
  - last_edited_at: 마지막 수정 시간 (datetime)
- created_at: 작성일시 (자동)
- updated_at: 수정일시 (자동)

**관계**: 
- User has_many :posts
- Post belongs_to :user

## 4. 화면 구성

### 4.1 인증 화면 (/users/sign_in)
- 로그인: 이메일/비밀번호 입력
- 계정은 미리 생성되어 있음 (회원가입 페이지 없음)
- 진심 로고와 #3B82F6 색상 활용
- 비밀번호 재설정 링크

### 4.2 메인 대시보드 (/, root_path)

**상단 영역**
- 네비게이션 바:
  - 좌측: 로고 "진심 AI 로드맵"
  - 우측: 현재 사용자명 | 로그아웃

**마일스톤 타임라인 영역** (전체 너비)
- 가로형 타임라인 (2025년 6월 18일 시작점 표시)
- 상태별 색상 구분:
  - 완료됨: #3B82F6 (메인 파란색)
  - 진행중: #FCD34D (노란색)
  - 계획됨: #E5E7EB (회색)
- 각 마일스톤:
  - 날짜 표시
  - 제목 표시
  - 호버 시 상세 내용 미리보기
  - 클릭 시 상세 페이지 이동
- 우측 상단: "마일스톤 추가" 버튼

**게시판 그리드 영역** (3열 구성)
1. **AI스터디 섹션**
   - 헤더: "AI스터디" + "새 글 작성" 버튼
   - 최근 5개 게시물 카드
   - 카드 내용: 제목, 작성자, 날짜, 내용 미리보기(50자)
   - 빈 상태: "첫 번째 AI 스터디 내용을 공유해주세요!"

2. **서비스기획 섹션**
   - 헤더: "서비스기획" + "새 글 작성" 버튼
   - 최근 5개 게시물 카드
   - 빈 상태: "서비스 기획 아이디어를 기록해주세요!"

3. **서비스개발 섹션**
   - 헤더: "서비스개발" + "새 글 작성" 버튼
   - 최근 5개 게시물 카드
   - 빈 상태: "개발 계획을 공유해주세요!"

### 4.3 게시물 작성 페이지 (/posts/new)

**일반 게시물 (AI스터디, 서비스기획, 서비스개발)**
- 카테고리: 자동 설정 (URL 파라미터)
- 제목: 텍스트 입력 (필수)
- 내용: 텍스트에어리어 (최소 10줄, 필수)
- 하단 버튼:
  - 저장 (파란색 #3B82F6)
  - 취소 (회색, 대시보드로)

**마일스톤 작성 양식** (/posts/new?category=milestone)
```
[마일스톤 추가]

날짜*: [____달력위젯____] (기본값: 오늘)

제목*: [_______________________]
      예: "AI 엔진 프로토타입 완성"

진행 상태*: [드롭다운 메뉴 ▼]
           - 계획됨
           - 진행중
           - 완료됨

상세 내용:
[_______________________]
[_______________________]
[_______________________]
[_______________________]
[_______________________]

[저장] [취소]

* 표시는 필수 입력 항목입니다.
```

### 4.4 게시물 수정 페이지 (/posts/:id/edit)
- 작성 페이지와 동일한 구성
- 기존 내용 자동 로드
- 권한 체크:
  - 일반 게시물: 작성자만 접근
  - 마일스톤: 모든 변호사 접근 가능
- 마일스톤 수정 시 자동으로 수정자/시간 기록

### 4.5 게시물 상세 페이지 (/posts/:id)

**일반 게시물 표시**
- 카테고리 배지 (색상 구분)
- 제목 (큰 글씨)
- 작성자 | 작성일시
- 내용 전체
- 하단 버튼:
  - 목록으로 (모든 사용자)
  - 수정 | 삭제 (작성자만)

**마일스톤 표시**
- "마일스톤" 배지
- 제목 (큰 글씨)
- 날짜: 2025년 7월 10일
- 상태: [완료됨] (색상 배지)
- 작성자 | 작성일시
- 마지막 수정: 윤두철 (2025.07.08 14:30)
- 내용 전체
- 하단 버튼:
  - 목록으로 (모든 사용자)
  - 수정 | 삭제 (모든 변호사)

## 5. 권한 관리

### 인증 및 접근 권한
- 로그인하지 않은 사용자: 로그인 페이지로 리다이렉트
- 계정은 미리 생성되어 있음 (4명의 변호사)
- 관리자: 윤두철 변호사 (lawpass2727@gmail.com)

### 게시물 권한
| 액션 | AI스터디/서비스기획/서비스개발 | 마일스톤 |
|------|--------------------------------|----------|
| 조회 | 모든 로그인 사용자 | 모든 로그인 사용자 |
| 작성 | 모든 로그인 사용자 | 모든 로그인 사용자 |
| 수정 | 작성자만 | **모든 로그인 사용자** |
| 삭제 | 작성자만 | **모든 로그인 사용자** |

### 관리자 권한 (윤두철 변호사)
- 다른 변호사들의 비밀번호 초기화
- 시스템 전반 관리
- 필요시 모든 게시물 수정/삭제 가능

### 구현 코드
```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :check_permission!, only: [:edit, :update, :destroy]
  
  private
  
  def check_permission!
    if @post.milestone?
      # 마일스톤은 모든 로그인 사용자가 수정 가능
      # authenticate_user!로 이미 체크됨
    else
      # 다른 카테고리는 작성자만 수정 가능
      redirect_to root_path, alert: '권한이 없습니다.' unless @post.user == current_user
    end
  end
  
  def update
    if @post.update(post_params)
      # 마일스톤 수정 시 수정자 정보 업데이트
      if @post.milestone?
        @post.update(
          last_editor_name: current_user.name,
          last_edited_at: Time.current
        )
      end
      redirect_to @post, notice: '수정되었습니다.'
    else
      render :edit
    end
  end
end

# app/controllers/admin/users_controller.rb
class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  
  def index
    @users = User.all
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to admin_users_path, notice: '사용자 정보가 수정되었습니다.'
    else
      render :edit
    end
  end
  
  def reset_password
    @user = User.find(params[:id])
    new_password = SecureRandom.hex(4)
    @user.update!(password: new_password)
    redirect_to admin_users_path, notice: "#{@user.name}님의 새 비밀번호: #{new_password}"
  end
  
  private
  
  def require_admin!
    redirect_to root_path, alert: '관리자만 접근 가능합니다.' unless current_user.admin?
  end
  
  def user_params
    params.require(:user).permit(:email, :name)
  end
end
```

## 6. 사용자 시나리오

### 6.1 변호사 첫 로그인
1. 윤두철 변호사로부터 이메일로 계정 정보 수령
2. 로그인 페이지에서 받은 이메일/비밀번호 입력
3. 로그인 후 대시보드 진입
4. 마일스톤 타임라인에서 2025년 6월 18일부터 현재까지의 여정 확인
5. 각 게시판의 최근 활동 파악
6. (선택) 비밀번호 변경

### 6.2 일일 AI 스터디 기록
1. 로그인 → 대시보드
2. AI스터디 섹션의 "새 글 작성" 클릭
3. 제목: "Cursor AI를 활용한 계약서 검토 자동화"
4. 내용: 오늘 학습한 내용과 실습 결과 작성
5. 저장 → 대시보드로 자동 이동
6. AI스터디 섹션 최상단에 방금 작성한 글 확인

### 6.3 마일스톤 추가 및 수정
1. 대시보드 상단 타임라인에서 "마일스톤 추가" 클릭
2. 날짜: 2025년 8월 1일 선택
3. 제목: "MVP 1차 버전 완성"
4. 상태: "계획됨" 선택
5. 상세 내용: "기본 문서 생성 기능 구현 완료 목표"
6. 저장 → 타임라인에 회색 점으로 표시
7. 2주 후 진행 상황 업데이트:
   - 해당 마일스톤 클릭
   - 수정 버튼 클릭 (모든 변호사 가능)
   - 상태를 "진행중"으로 변경
   - 저장 → 타임라인에 노란색으로 변경

### 6.4 팀 협업 플로우
1. 이정민 변호사: 서비스기획에 "AI 엔진 선택 기준" 작성
2. 윤두철 변호사: 해당 글 읽고 AI스터디에 "GPT-4 vs Claude 비교" 작성
3. 류제성 변호사: 서비스개발에 "API 연동 아키텍처" 작성
4. 장우혁 변호사: 마일스톤에 "프로토타입 데모" 추가 (진행중)
5. 모든 변호사: 대시보드에서 전체 진행 상황 한눈에 파악

## 7. 기술 요구사항

### 보안
- Devise를 통한 안전한 인증
- 세션 타임아웃 설정 (2시간)
- Strong Parameters 적용
- CSRF 보호
- 미리 생성된 4개 계정만 로그인 가능
- 관리자(윤두철 변호사)의 특별 권한 관리

### 데이터베이스
- 개발: SQLite3 (이미 설정됨)
- 프로덕션: PostgreSQL 또는 MySQL (배포 시 변경)

### 성능
- 대시보드 로딩 2초 이내
- 각 섹션별 최근 5개만 로드
- includes를 활용한 N+1 쿼리 방지
- 카테고리별 인덱스 설정
- 타임라인 데이터 캐싱 고려

### 사용성
- 직관적인 카테고리 구분 (색상, 아이콘)
- 명확한 작성자 표시
- 한국 시간대 설정 (KST)
- 날짜 포맷: "2025년 7월 8일" 또는 "2025.07.08"
- 빈 상태 친근한 안내 메시지
- 반응형 디자인 (모바일/태블릿/데스크톱)
- 마일스톤 달력 위젯 (Flatpickr 등)

## 8. 구현 가이드라인

### 8.1 Gemfile 수정
Rails 프로젝트 생성 시 기본으로 포함된 gem 외에 다음을 추가합니다:

```ruby
# Gemfile에 추가할 내용

# Authentication
gem "devise", "~> 4.9"

# 날짜 선택 위젯 (선택사항)
gem "flatpickr", "~> 4.6"

group :development do
  # 이미 포함되어 있을 수 있음
  gem "web-console"
end
```

추가 후 실행:
```bash
bundle install
```

### 8.2 Routes 구성
```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Devise routes (회원가입 비활성화)
  devise_for :users, skip: [:registrations]
  
  root "dashboard#index"
  
  resources :posts do
    collection do
      get :study
      get :planning
      get :development
      get :milestones
    end
  end
  
  # 관리자 전용 (윤두철 변호사)
  namespace :admin do
    resources :users, only: [:index, :edit, :update] do
      member do
        post :reset_password
      end
    end
  end
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
```

### 8.3 Seeds 파일 (초기 데이터)
```ruby
# db/seeds.rb

# 4명의 변호사 계정 생성
lawyers = [
  { 
    email: 'jungmin.lee@example.com',  # 실제 이메일로 변경 필요
    name: '이정민', 
    password: 'TempPass123!',
    admin: false 
  },
  { 
    email: 'lawpass2727@gmail.com',    # 윤두철 변호사 (관리자)
    name: '윤두철', 
    password: '1027',
    admin: true 
  },
  { 
    email: 'jesung.ryu@example.com',   # 실제 이메일로 변경 필요
    name: '류제성', 
    password: 'TempPass123!',
    admin: false 
  },
  { 
    email: 'woohyuk.jang@example.com', # 실제 이메일로 변경 필요
    name: '장우혁', 
    password: 'TempPass123!',
    admin: false 
  }
]

lawyers.each do |lawyer_data|
  user = User.find_or_create_by!(email: lawyer_data[:email]) do |u|
    u.name = lawyer_data[:name]
    u.password = lawyer_data[:password]
    u.admin = lawyer_data[:admin] || false
  end
  
  puts "계정 생성/확인: #{user.name} (#{user.email})"
end

# 관리자 확인
admin = User.find_by(admin: true)
puts "\n관리자: #{admin.name} (#{admin.email})"

# 초기 마일스톤 생성
user = User.find_by(email: 'lawpass2727@gmail.com')
Post.find_or_create_by!(
  title: "AI 스터디 시작",
  category: "milestone"
) do |post|
  post.content = "법무법인 진심의 AI 기반 법률 서비스 개발을 위한 첫 걸음을 시작했습니다."
  post.milestone_date = Date.new(2025, 6, 18)
  post.milestone_status = "completed"
  post.author_name = user.name
  post.user = user
end

puts "\n초기 데이터 생성 완료!"
puts "\n⚠️  다른 변호사님들의 실제 이메일 주소로 변경 필요:"
puts "- 이정민 변호사: jungmin.lee@example.com"
puts "- 류제성 변호사: jesung.ryu@example.com"
puts "- 장우혁 변호사: woohyuk.jang@example.com"
puts "\n관리자(윤두철 변호사)가 production 환경에서 직접 수정하시거나,"
puts "이 파일을 업데이트 후 다시 실행하세요."
```

실행 방법:
```bash
rails db:seed
```

### 8.4 마이그레이션
Devise와 Post 모델을 위한 마이그레이션 생성:

```bash
# Devise 설치 및 User 모델 생성
rails generate devise:install
rails generate devise User

# Post 모델 생성
rails generate model Post title:string content:text category:string author_name:string user:references milestone_date:date milestone_status:string last_editor_name:string last_edited_at:datetime
```

생성된 마이그레이션 파일 수정:

```ruby
# db/migrate/xxx_devise_create_users.rb
class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :name,              null: false
      t.boolean :admin,            default: false

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
  end
end

# db/migrate/xxx_create_posts.rb
class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :category, null: false
      t.string :author_name, null: false
      t.references :user, null: false, foreign_key: true
      
      # 마일스톤 전용 필드
      t.date :milestone_date
      t.string :milestone_status
      t.string :last_editor_name
      t.datetime :last_edited_at
      
      t.timestamps
    end
    
    add_index :posts, :category
    add_index :posts, :created_at
    add_index :posts, [:category, :created_at]
  end
end
```

마이그레이션 실행:
```bash
rails db:migrate
```

## 9. UI/UX 가이드라인

### 색상 팔레트
- 메인 색상: #3B82F6 (파란색)
- 보조 색상:
  - 성공/완료: #10B981 (초록)
  - 진행중: #FCD34D (노란)
  - 계획/대기: #E5E7EB (회색)
  - 위험/삭제: #EF4444 (빨강)
- 배경: #F9FAFB
- 텍스트: #1F2937

### 타이포그래피
- 제목: text-2xl font-bold
- 부제목: text-lg font-semibold  
- 본문: text-base
- 작은 텍스트: text-sm text-gray-600

### 컴포넌트 스타일
- 카드: rounded-lg shadow-sm bg-white p-4
- 버튼 (Primary): bg-blue-600 text-white px-4 py-2 rounded
- 버튼 (Secondary): bg-gray-200 text-gray-800 px-4 py-2 rounded
- 입력 필드: border border-gray-300 rounded px-3 py-2

## 10. 성공 기준

### 기능적 요구사항
- [ ] 4명의 변호사 모두 정상적으로 로그인 가능 (미리 생성된 계정)
- [ ] 각 카테고리별 게시물 작성/조회/수정/삭제 정상 작동
- [ ] 마일스톤 날짜와 상태 관리 기능 정상 작동
- [ ] 마일스톤 팀 공동 수정 가능 확인
- [ ] 대시보드에서 모든 정보 한눈에 파악 가능
- [ ] 권한 체크 정상 작동 (일반 게시물 vs 마일스톤)
- [ ] 관리자(윤두철 변호사) 기능 정상 작동

### 사용성 요구사항
- [ ] 2025년 6월 18일 시작점이 타임라인에 명확히 표시
- [ ] 마일스톤 상태별 색상 구분 명확
- [ ] 모바일에서 모든 기능 정상 작동
- [ ] 페이지 로딩 시간 2초 이내
- [ ] 직관적인 네비게이션과 사용자 경험

### 협업 요구사항
- [ ] 여러 변호사가 동시에 사용해도 문제없음
- [ ] 마일스톤 수정 시 수정자 정보 정확히 기록
- [ ] 각 게시판의 목적이 명확히 구분됨

---

## 구현 지침

### 전제조건
이미 다음 명령어로 Rails 8 프로젝트가 생성되어 있다고 가정합니다:
```bash
rails new jinsim_ai_roadmap -d sqlite3 -c tailwind
cd jinsim_ai_roadmap
```

### AI 개발 도구에 제공할 지침

이 기획서를 AI 개발 도구에 제공하여 구현을 요청하세요:

```
Rails 8 프로젝트가 이미 생성되어 있는 상태에서 이 기획서를 바탕으로 MVP를 구현해주세요.

현재 상태:
- Rails 8 프로젝트 생성 완료 (sqlite3, tailwind 포함)
- 프로젝트명: jinsim_ai_roadmap

구현 요구사항:
1. Gemfile에 devise 추가부터 시작해주세요.
2. 4명의 변호사 계정을 미리 생성해주세요 (회원가입 기능 없음).
3. 윤두철 변호사(lawpass2727@gmail.com, 비밀번호: 1027)를 관리자로 설정해주세요.
4. 마일스톤은 모든 변호사가 수정할 수 있지만, 다른 게시물은 작성자만 수정할 수 있도록 권한을 설정해주세요.
5. 마일스톤 작성/수정 시 날짜 선택과 상태 선택이 가능한 전용 폼을 만들어주세요.
6. 메인 색상 #3B82F6를 활용한 Tailwind CSS 스타일링을 적용해주세요.
7. Devise 설정에서 회원가입(registerable) 모듈을 제거해주세요.
8. 필요한 모든 컨트롤러, 뷰, 모델 파일을 생성해주세요.
```

**중요 사항**:
- 다른 변호사님들의 실제 이메일 주소는 나중에 윤두철 변호사님이 직접 수정할 예정입니다.
- 현재는 example.com 도메인으로 임시 설정되어 있습니다.

---

**작성일**: 2025년 7월 8일  
**관리자**: 윤두철 변호사 (lawpass2727@gmail.com)