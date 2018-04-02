class UserRevertsController < ApplicationController
  before_action :moderator_only

  def new
    @user = User.find(params[:user_id])
  end

  def create
    user = User.find(params[:user_id])
    revert = UserRevert.new(user.id)
    revert.process
    redirect_to(user_path(user.id))
  end
end

