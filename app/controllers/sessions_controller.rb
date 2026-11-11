# frozen_string_literal: true

class SessionsController < ApplicationController
  respond_to :html

  verify_captcha only: :create
  skip_before_action :redirect_if_name_invalid?, only: [:confirm_password, :reauthenticate]

  rescue_from ActiveSupport::MessageVerifier::InvalidSignature do
    redirect_to login_path, notice: "Login expired. Login again to continue", status: 303
  end

  def new
    @session = authorize SessionLoader.new(request)
    @url = local_path(params.dig(:session, :url).presence || params[:url]) || root_path

    if params[:signed_login_event].present? && @session.authorize_login_event!(params[:signed_login_event])
      notice = "New location verified. Login again to continue"
    end

    respond_with(@session, notice: notice)
  end

  # Verify the user's password and either log them in, or show them the 2FA page if they have 2FA enabled.
  def create
    @session = authorize SessionLoader.new(request)
    @user = @session.login(params.dig(:session, :name), params.dig(:session, :password))
    @url = local_path(params.dig(:session, :url).presence || params[:url]) || root_path

    if @user&.totp.present?
      render :confirm_totp
    elsif @user
      redirect_to @url
    else
      render :new, status: 401
    end
  end

  # Ask for the user's password before sensitive actions.
  def confirm_password
    @user = CurrentUser.user
    @session = authorize SessionLoader.new(request)
    @url = local_path(params.dig(:session, :url).presence || params[:url]) || root_path
  end

  # Verify the user's password and 2FA code before sensitive actions.
  def reauthenticate
    @user = CurrentUser.user
    @session = authorize SessionLoader.new(request)
    @url = local_path(params.dig(:session, :url).presence || params[:url]) || root_path

    if @session.reauthenticate(@user, params.dig(:session, :password), params.dig(:session, :verification_code))
      redirect_to @url
    else
      render :confirm_password
    end
  end

  # Verify the user's 2FA code after they log in with their password.
  def verify_totp
    @user = User.find_signed!(params.dig(:totp, :user_id), purpose: "verify_totp/#{session[:session_id]}")
    @url = local_path(params.dig(:totp, :url)) || root_path
    @session = authorize SessionLoader.new(request)

    if @session.verify_totp!(@user, params.dig(:totp, :code))
      redirect_to @url
    else
      @user.totp.errors.add(:code, "is incorrect")
      render :confirm_totp
    end
  end

  def destroy
    @session = authorize SessionLoader.new(request)
    @session.logout(CurrentUser.user)
    redirect_to root_path, notice: "You are now logged out", status: 303
  end

  def logout
    @session = authorize SessionLoader.new(request)
    render layout: "blank"
  end
end
