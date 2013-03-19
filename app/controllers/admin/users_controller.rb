module Admin
  class UsersController < ApplicationController
    before_filter :moderator_only

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      @user.level = params[:user][:level]
      @user.inviter_id = CurrentUser.id unless @user.inviter_id.present?
      @user.save
      redirect_to edit_admin_user_path(@user, :notice => "User updated"), :notice => "User updated"
    end
  end
end
