module Admin
  class UsersController < ApplicationController
    before_filter :moderator_only
    rescue_from User::PrivilegeError, :with => :access_denied

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      sanitize_params!
      @user.promote_to!(params[:user][:level])
      redirect_to edit_admin_user_path(@user), :notice => "User updated"
    end

  protected
    def sanitize_params!
      # admins can do anything
      return if CurrentUser.is_admin?

      # can't promote/demote moderators
      raise User::PrivilegeError if @user.is_moderator?

      # can't promote to admin      
      raise User::PrivilegeError if params[:user] && params[:user][:level].to_i >= User::Levels::ADMIN
    end
  end
end
