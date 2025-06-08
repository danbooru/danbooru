# frozen_string_literal: true

# This handles enabling, disabling, and updating 2FA settings for a user.
#
# See app/logical/totp.rb for the 2FA logic and app/controllers/session_controller.rb
# for the code for logging in using 2FA.
class TOTPController < ApplicationController
  respond_to :html, :xml, :json

  before_action :requires_reauthentication, only: [:edit, :update, :destroy]

  def edit
    @user = authorize User.find(params[:user_id]), policy_class: TOTPPolicy
    @totp = @user.totp || TOTP.new(username: @user.name)

    respond_with(@totp)
  end

  def update
    @user = authorize User.find(params[:user_id]), policy_class: TOTPPolicy
    @totp = TOTP.from_signed_secret(params.dig(:totp, :signed_secret), username: @user.name)

    if @totp.verify(params.dig(:totp, :verification_code))
      @user.update_totp_secret!(@totp.secret, request: request)
      @totp = @user.totp

      notice = "Two-factor authentication enabled"
    else
      @totp.errors.add(:verification_code, "is incorrect")
    end

    respond_with(@totp, notice: notice, location: user_backup_codes_path(@user, url: settings_path))
  end

  def destroy
    @user = authorize User.find(params[:user_id]), policy_class: TOTPPolicy
    @user.update_totp_secret!(nil, request: request)

    respond_with(@totp, notice: "Two-factor authentication disabled", location: settings_path)
  end
end
