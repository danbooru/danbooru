# frozen_string_literal: true

class SessionsController < ApplicationController
  respond_to :html

  rate_limit :create, rate: 1.0/10.minutes, burst: 20
  rate_limit :reauthenticate, rate: 1.0/10.minutes, burst: 20, key: "sessions:create"
  rate_limit :verify_totp, rate: 1.0/30.minutes, burst: 50

  verify_captcha only: :create

  def new
    @user = User.new
    @session = SessionLoader.new(request)
  end

  # Verify the user's password and either log them in, or show them the 2FA page if they have 2FA enabled.
  def create
    @session = SessionLoader.new(request)
    @user = @session.login(params.dig(:session, :name), params.dig(:session, :password))
    @url = params.dig(:session, :url).presence || params[:url].presence || root_path

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
    @session = SessionLoader.new(request)
    @url = params.dig(:session, :url).presence || params[:url].presence || root_path
  end

  # Verify the user's password and 2FA code before sensitive actions.
  def reauthenticate
    @user = CurrentUser.user
    @session = SessionLoader.new(request)
    @url = params.dig(:session, :url).presence || params[:url].presence || root_path

    if @session.reauthenticate(@user, params.dig(:session, :password), params.dig(:session, :verification_code))
      redirect_to @url
    else
      render :confirm_password
    end
  end

  # Verify the user's 2FA code after they log in with their password.
  def verify_totp
    @user = User.find_signed(params.dig(:totp, :user_id), purpose: :verify_totp)
    @url = params.dig(:totp, :url).presence || root_url

    if SessionLoader.new(request).verify_totp!(@user, params.dig(:totp, :code))
      redirect_to @url
    else
      @user.totp.errors.add(:code, "is incorrect")
      render :confirm_totp
    end
  end

  def destroy
    SessionLoader.new(request).logout
    redirect_to(posts_path, :notice => "You are now logged out")
  end

  def sign_out
    destroy
  end
end
