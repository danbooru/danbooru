# frozen_string_literal: true

class PasswordResetsController < ApplicationController
  respond_to :html, :xml, :json

  verify_captcha only: :create

  rescue_from ActiveSupport::MessageVerifier::InvalidSignature do
    redirect_to password_reset_path, notice: "Password reset link is invalid or expired. Request a new one.", status: 303
  end

  rescue_from Pundit::NotAuthorizedError do
    redirect_to profile_path, notice: "Already logged in"
  end

  # Show the password reset request page.
  def show
    authorize CurrentUser.user, policy_class: PasswordResetPolicy
  end

  # Show the change password form.
  def edit
    @user = authorize User.find_signed!(params.dig(:user, :signed_id), purpose: :password_reset), policy_class: PasswordResetPolicy
  end

  # Send the password reset email.
  def create
    name_or_email = params.dig(:user, :name)
    @user = authorize User.find_by_name_or_email(name_or_email), policy_class: PasswordResetPolicy

    @user&.request_password_reset!(request)

    if Danbooru::EmailAddress.is_valid?(name_or_email)
      flash[:notice] = "Check your email. You will be sent a password reset link if an account with this email exists"
    else
      flash[:notice] = "Check your email. You will be sent a password reset link if this account has an email address"
    end

    redirect_to password_reset_path
  end

  # Change the user's password.
  def update
    @user = authorize User.find_signed!(params.dig(:user, :signed_id), purpose: :password_reset), policy_class: PasswordResetPolicy

    success = @user.reset_password(
      new_password: params.dig(:user, :password),
      password_confirmation: params.dig(:user, :password_confirmation),
      verification_code: params.dig(:user, :verification_code),
      request: request
    )

    if success
      SessionLoader.new(request).login_user(@user, :login)
      notice = "Password updated"
    end

    respond_with(@user, notice: notice)
  end
end
