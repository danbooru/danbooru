# frozen_string_literal: true

class PasswordsController < ApplicationController
  respond_to :html, :xml, :json

  rate_limit :update, rate: 1.0/10.minute, burst: 20

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
      current_user: CurrentUser.user,
      current_password: params.dig(:user, :current_password),
      new_password: params.dig(:user, :password),
      password_confirmation: params.dig(:user, :password_confirmation),
      verification_code: params.dig(:user, :verification_code),
      request: request
    )

    if success
      flash[:notice] = "Password updated"
    end

    respond_with(@user)
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
