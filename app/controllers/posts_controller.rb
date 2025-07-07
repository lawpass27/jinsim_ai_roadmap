class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :check_permission!, only: [:edit, :update, :destroy]
  
  def index
    @posts = Post.all.recent
  end
  
  def show
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
  
  # Collection actions
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
    params.require(:post).permit(:title, :content, :category, :milestone_date, :milestone_status)
  end
  
  def check_permission!
    if @post.milestone?
      # 마일스톤은 모든 로그인 사용자가 수정 가능
      # authenticate_user!로 이미 체크됨
    else
      # 다른 카테고리는 작성자만 수정 가능
      redirect_to root_path, alert: '권한이 없습니다.' unless @post.user == current_user
    end
  end
end