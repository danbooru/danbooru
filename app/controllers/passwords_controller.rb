class PasswordsController < ApplicationController
  before_action :member_only
  respond_to :html, :xml, :json

  def edit
    @user = User.find(params[:user_id])
    check_privilege(@user)

    respond_with(@user)
  end

  def update
    @user = User.find(params[:user_id])
    check_privilege(@user)

    @user.update(user_params)
    flash[:notice] = @user.errors.none? ? "Password updated" : @user.errors.full_messages.join("; ")

    respond_with(@user, location: @user)
  end

  private

  def check_privilege(user)
    raise User::PrivilegeError unless user.id == CurrentUser.id || CurrentUser.is_admin?
  end

  def user_params
    params.require(:user).permit(%i[old_password password password_confirmation])
  end
end
