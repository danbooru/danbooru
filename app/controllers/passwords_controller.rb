class PasswordsController < ApplicationController
  respond_to :html, :xml, :json

  def edit
    @user = authorize User.find(params[:user_id]), policy_class: PasswordPolicy
    respond_with(@user)
  end

  def update
    @user = authorize User.find(params[:user_id]), policy_class: PasswordPolicy
    @user.update(user_params)
    flash[:notice] = @user.errors.none? ? "Password updated" : @user.errors.full_messages.join("; ")

    respond_with(@user, location: @user)
  end

  def user_params
    params.fetch(:user, {}).permit(policy(:password).permitted_attributes)
  end
end
