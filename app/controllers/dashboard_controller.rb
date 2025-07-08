class DashboardController < ApplicationController
  # 대시보드는 로그인 없이 접근 가능
  
  def index
    @milestones = Post.by_category('milestone').order(milestone_date: :asc)
    @recent_study_posts = Post.by_category('study').recent.limit(5)
    @recent_planning_posts = Post.by_category('planning').recent.limit(5)
    @recent_development_posts = Post.by_category('development').recent.limit(5)
  end
end
