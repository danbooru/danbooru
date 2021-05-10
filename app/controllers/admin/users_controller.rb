module Admin
  class UsersController < ApplicationController
    def edit
      @user = authorize User.find(params[:id]), :promote?
    end

    def update
      @user = authorize User.find(params[:id]), :promote?

      @level = params.dig(:user, :level)
      @can_upload_free = params.dig(:user, :can_upload_free)
      @can_approve_posts = params.dig(:user, :can_approve_posts)

      @user.promote_to!(@level, CurrentUser.user, can_upload_free: @can_upload_free, can_approve_posts: @can_approve_posts)

      redirect_to edit_admin_user_path(@user), :notice => "User updated"
    end
  end
end
