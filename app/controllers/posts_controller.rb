class PostsController < ApplicationController
  # show 액션은 인증 없이 접근 가능
  before_action :authenticate_user!, except: [:show]
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :check_permission!, only: [:edit, :update, :destroy]
  
  def index
    @posts = Post.all.recent
  end
  
  def show
    # 누구나 게시물을 볼 수 있음
  end
  
  def new
    @post = current_user.posts.build(category: params[:category] || 'study')
  end
  
  def create
    @post = current_user.posts.build(post_params)
    @post.author_name = current_user.name
    
    if @post.save
      redirect_to @post, notice: '게시물이 작성되었습니다.'
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
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
      redirect_to @post, notice: '게시물이 수정되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @post.destroy
    redirect_to root_path, notice: '게시물이 삭제되었습니다.'
  end
  
  # Collection actions - 전체 목록은 로그인 필요
  def study
    @posts = Post.by_category('study').recent
    render :index
  end
  
  def planning
    @posts = Post.by_category('planning').recent
    render :index
  end
  
  def development
    @posts = Post.by_category('development').recent
    render :index
  end
  
  def milestones
    @posts = Post.by_category('milestone').order(milestone_date: :asc)
    render :index
  end
  
  private
  
  def set_post
    @post = Post.find(params[:id])
  end
  
  def post_params
    params.require(:post).permit(:title, :content, :category, :milestone_date, :milestone_status, files: [])
  end
  
  def check_permission!
    # 로그인하지 않은 경우 처리
    unless user_signed_in?
      redirect_to new_user_session_path, alert: '로그인이 필요합니다.'
      return
    end
    
    if @post.milestone?
      # 마일스톤은 모든 로그인 사용자가 수정 가능
    else
      # 다른 카테고리는 작성자만 수정 가능
      redirect_to root_path, alert: '권한이 없습니다.' unless @post.user == current_user
    end
  end
end