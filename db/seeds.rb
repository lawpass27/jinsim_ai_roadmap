# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

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