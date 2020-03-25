class PasswordsController < ApplicationController
  respond_to :html, :xml, :json

  def edit
    @user = authorize User.find(params[:user_id]), policy_class: PasswordPolicy
    respond_with(@user)
  end

  def update
    @user = authorize User.find(params[:user_id]), policy_class: PasswordPolicy

    if @user.authenticate_password(params[:user][:old_password]) || @user.authenticate_login_key(params[:user][:signed_user_id])
      @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
    else
      @user.errors[:base] << "Incorrect password"
    end

    flash[:notice] = @user.errors.none? ? "Password updated" : @user.errors.full_messages.join("; ")

    respond_with(@user, location: @user)
  end
end
