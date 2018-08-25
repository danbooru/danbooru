module Admin
  class UsersController < ApplicationController
    before_action :moderator_only

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      @user.promote_to!(params[:user][:level], params[:user])
      redirect_to edit_admin_user_path(@user), :notice => "User updated"
    end
  end
end
