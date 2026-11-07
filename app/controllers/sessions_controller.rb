# frozen_string_literal: true

class SessionsController < ApplicationController
  PASSKEY_CHALLENGE_EXPIRY = 5.minutes

  respond_to :html

  verify_captcha only: :create

  rescue_from ActiveSupport::MessageVerifier::InvalidSignature do
    redirect_to login_path, notice: "Login expired. Login again to continue", status: 303
  end

  def new
    @session = authorize SessionLoader.new(request)
    @url = params.dig(:session, :url).presence || params[:url].presence || root_path

    if params[:signed_login_event].present? && @session.authorize_login_event!(params[:signed_login_event])
      notice = "New location verified. Login again to continue"
    end

    respond_with(@session, notice: notice)
  end

  # Verify the user's password and either log them in, or show them the 2FA page if they have 2FA enabled.
  def create
    @session = authorize SessionLoader.new(request)
    @user = @session.login(params.dig(:session, :name), params.dig(:session, :password))
    @url = params.dig(:session, :url).presence || params[:url].presence || root_path

    if @user&.has_2fa?
      @passkeys = @user.passkeys.to_a
      session[:passkey_login_user_id] = @user.id
      session[:passkey_login_started_at] = Time.zone.now.to_i
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
    @passkeys = @user.passkeys.to_a
    @session = authorize SessionLoader.new(request)
    @url = params.dig(:session, :url).presence || params[:url].presence || root_path
  end

  # Verify the user's password and 2FA code before sensitive actions.
  def reauthenticate
    @user = CurrentUser.user
    @passkeys = @user.passkeys.to_a
    @session = authorize SessionLoader.new(request)
    @url = params.dig(:session, :url).presence || params[:url].presence || root_path

    if @session.reauthenticate(@user, params.dig(:session, :password), params.dig(:session, :verification_code))
      redirect_to @url
    else
      render :confirm_password
    end
  end

  # Verify the user's 2FA code after they log in with their password.
  def verify_totp
    @user = User.find_signed!(params.dig(:totp, :user_id), purpose: "verify_totp/#{session[:session_id]}")
    @url = params.dig(:totp, :url).presence || root_url
    @session = authorize SessionLoader.new(request)
    @passkeys = @user.passkeys.to_a

    if @session.verify_totp!(@user, params.dig(:totp, :code))
      redirect_to @url
    else
      @user.totp.errors.add(:code, "is incorrect") if @user.totp.present?
      flash.now[:alert] = "Invalid code"
      render :confirm_totp
    end
  end

  # Return passkey authentication options for the user who just entered their password.
  def passkey_options
    @user = find_passkey_login_user
    @session = authorize SessionLoader.new(request)
    options = Passkey.authentication_options(@user, request)
    session[:passkey_login_challenge] = options.challenge
    session[:passkey_login_challenge_at] = Time.zone.now.to_i

    render json: options
  end

  # Verify a passkey after the user has entered their password.
  def verify_passkey
    @user = find_passkey_login_user
    @url = safe_redirect_url(params[:url].presence, root_url)
    @session = authorize SessionLoader.new(request)
    @passkeys = @user.passkeys.to_a
    challenge = passkey_challenge(:passkey_login_challenge, :passkey_login_challenge_at)

    if challenge.present? && @session.verify_passkey!(@user, credential_params, challenge)
      if request.format.json?
        render json: { redirect_url: @url }
      else
        redirect_to @url
      end
    elsif request.format.json?
      render json: { error: "Passkey verification failed" }, status: 422
    else
      @session.errors.add(:base, "Passkey verification failed") if challenge.blank?
      flash.now[:alert] = "Passkey verification failed"
      render :confirm_totp, status: 422
    end
  end

  # Return passkey authentication options for the current user before a sensitive action.
  def reauthenticate_passkey_options
    @user = CurrentUser.user
    @session = authorize SessionLoader.new(request)
    options = Passkey.authentication_options(@user, request)
    session[:passkey_reauth_challenge] = options.challenge
    session[:passkey_reauth_challenge_at] = Time.zone.now.to_i

    render json: options
  end

  # Verify a passkey before a sensitive action.
  def reauthenticate_passkey
    @user = CurrentUser.user
    @passkeys = @user.passkeys.to_a
    @url = safe_redirect_url(params[:url].presence, root_path)
    @session = authorize SessionLoader.new(request)
    challenge = passkey_challenge(:passkey_reauth_challenge, :passkey_reauth_challenge_at)

    if challenge.present? && @session.reauthenticate_passkey(@user, credential_params, challenge)
      if request.format.json?
        render json: { redirect_url: @url }
      else
        redirect_to @url
      end
    elsif request.format.json?
      render json: { error: "Passkey verification failed" }, status: 422
    else
      @session.errors.add(:base, "Passkey verification failed") if challenge.blank?
      flash.now[:alert] = "Passkey verification failed"
      render :confirm_password, status: 422
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

  private

  def find_passkey_login_user
    user_id = session[:passkey_login_user_id]
    started_at = session[:passkey_login_started_at]

    if user_id.blank? || started_at.blank? || Time.zone.at(started_at.to_i) <= 10.minutes.ago
      raise ActiveSupport::MessageVerifier::InvalidSignature
    end

    User.find_by(id: user_id) || raise(ActiveSupport::MessageVerifier::InvalidSignature)
  end

  def passkey_challenge(challenge_key, timestamp_key)
    challenge = session.delete(challenge_key)
    issued_at = session.delete(timestamp_key)
    return nil if challenge.blank? || issued_at.blank?

    (Time.zone.at(issued_at.to_i) > PASSKEY_CHALLENGE_EXPIRY.ago) ? challenge : nil
  end

  def credential_params
    credential = params[:credential]
    credential.is_a?(ActionController::Parameters) ? credential.to_unsafe_h : {}
  end

  def safe_redirect_url(value, default)
    url_from(value) || default
  end
end
