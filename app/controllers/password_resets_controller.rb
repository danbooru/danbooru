# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  respond_to :html, :xml, :json

  rate_limit :create, rate: 1.0/1.minute, burst: 5
  verify_captcha only: :create

  def create
    name_or_email = params.dig(:user, :name)
    @user = User.find_by_name_or_email(name_or_email)

    if @user&.can_receive_email?(require_verified_email: false)
      UserMailer.with_request(request).password_reset(@user).deliver_later
    end

    if @user.present?
      UserEvent.create_from_request!(@user, :password_reset, request)
    end

    if Danbooru::EmailAddress.is_valid?(name_or_email)
      flash[:notice] = "Check your email. You will be sent a password reset link if an account with this email exists"
    else
      flash[:notice] = "Check your email. You will be sent a password reset link if this account has an email address"
    end

    redirect_to password_reset_path
  end

  def show
  end
end
