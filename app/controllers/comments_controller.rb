class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post
  before_action :set_comment, only: [:destroy]

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    
    if @comment.save
      redirect_to @post, notice: '댓글이 작성되었습니다.'
    else
      redirect_to @post, alert: '댓글 작성에 실패했습니다.'
    end
  end

  def destroy
    if @comment.user == current_user || current_user.admin?
      @comment.destroy
      redirect_to @post, notice: '댓글이 삭제되었습니다.'
    else
      redirect_to @post, alert: '권한이 없습니다.'
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end