module Admin
  class UsersController < ApplicationController
    before_filter :moderator_only
    rescue_from User::PrivilegeError, :with => :access_denied

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      @user.promote_to!(
        params[:user][:level],
        :can_approve_posts => params[:user][:can_approve_posts],
        :can_upload_free => params[:user][:can_upload_free]
      )
      redirect_to edit_admin_user_path(@user), :notice => "User updated"
    end
  end
end
