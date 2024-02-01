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

    if @user.authenticate_password(params[:user][:old_password]) || @user.authenticate_login_key(params[:user][:signed_user_id]) || CurrentUser.user.is_owner?
      UserEvent.build_from_request(@user, :password_change, request)
      @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
    else
      @user.errors.add(:base, "Incorrect password")
    end

    flash[:notice] = @user.errors.none? ? "Password updated" : @user.errors.full_messages.join("; ")

    respond_with(@user, location: @user)
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
