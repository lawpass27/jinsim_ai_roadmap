class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_user, only: [:edit, :update, :reset_password]
  
  def index
    @users = User.all
  end
  
  def edit
  end
  
  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: '사용자 정보가 수정되었습니다.'
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def reset_password
    new_password = SecureRandom.hex(4)
    @user.update!(password: new_password)
    redirect_to admin_users_path, notice: "#{@user.name}님의 새 비밀번호: #{new_password}"
  end
  
  private
  
  def require_admin!
    redirect_to root_path, alert: '관리자만 접근 가능합니다.' unless current_user.admin?
  end
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def user_params
    params.require(:user).permit(:email, :name)
  end
end