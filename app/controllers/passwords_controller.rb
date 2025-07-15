# frozen_string_literal: true

class PasswordsController < ApplicationController
  respond_to :html, :xml, :json

  def edit
    @user = authorize user, policy_class: PasswordPolicy

    if @user.is_anonymous?
      redirect_to login_path(url: edit_password_path)
    else
      respond_with(@user)
    end
  end

  def update
    @user = authorize user, policy_class: PasswordPolicy

    success = @user.change_password(
      current_password: params.dig(:user, :current_password),
      new_password: params.dig(:user, :password),
      password_confirmation: params.dig(:user, :password_confirmation),
      verification_code: params.dig(:user, :verification_code),
      request: request
    )

    notice = "Password updated" if success
    respond_with(@user, notice: notice)
  end

  private

  def user
    if params[:user_id].present?
      User.find(params[:user_id])
    else
      CurrentUser.user
    end
  end
end
