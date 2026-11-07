# frozen_string_literal: true

class PasskeysController < ApplicationController
  respond_to :html

  before_action :requires_reauthentication

  def index
    authorize Passkey

    @passkeys = CurrentUser.user.passkeys.order(:created_at)
    respond_with(@passkeys)
  end

  def options
    authorize Passkey, :create?

    options = Passkey.registration_options(CurrentUser.user, request)
    session[:passkey_registration_challenge] = options.challenge
    session[:passkey_registration_challenge_at] = Time.zone.now.to_i

    render json: options
  end

  def create
    authorize Passkey, :create?

    challenge = session.delete(:passkey_registration_challenge)
    challenge_at = session.delete(:passkey_registration_challenge_at)
    if challenge.blank? || challenge_at.blank? || Time.zone.at(challenge_at.to_i) <= 5.minutes.ago
      raise WebAuthn::Error, "Registration challenge expired"
    end

    nickname = params[:nickname].is_a?(String) ? params[:nickname].presence : nil

    ApplicationRecord.transaction do
      Passkey.register(CurrentUser.user, credential_params, challenge, request, nickname: nickname)
      CurrentUser.user.generate_backup_codes!(request) if CurrentUser.user.backup_codes.blank?
      UserEvent.create_from_request!(CurrentUser.user, :passkey_create, request)
    end

    render json: { redirect_url: passkeys_path }, status: 201
  rescue WebAuthn::Error, ArgumentError, TypeError, NoMethodError, KeyError, JSON::ParserError, CBOR::MalformedFormatError, EOFError, ActiveRecord::RecordInvalid => e
    Rails.logger.error("Passkey registration failed: #{e.class}: #{e.message}")
    render json: { error: "Invalid passkey" }, status: 422
  end

  def destroy
    passkey = CurrentUser.user.passkeys.find(params.expect(:id))
    authorize passkey

    passkey.destroy!
    CurrentUser.user.update!(backup_codes: nil) if CurrentUser.user.passkeys.reload.empty? && CurrentUser.user.totp_secret.blank?
    UserEvent.create_from_request!(CurrentUser.user, :passkey_delete, request)

    redirect_to passkeys_path, notice: "Passkey deleted"
  end

  private

  def credential_params
    credential = params[:credential]
    credential.is_a?(ActionController::Parameters) ? credential.to_unsafe_h : {}
  end
end
