# frozen_string_literal: true

# A passkey is a WebAuthn credential the user can use instead of a 2FA code.
#
# @see app/controllers/passkeys_controller.rb
# @see app/controllers/sessions_controller.rb
# @see https://github.com/cedarcode/webauthn-ruby
class Passkey < ApplicationRecord
  belongs_to :user

  validates :external_id, presence: true, uniqueness: true
  validates :public_key, presence: true
  validates :sign_count, numericality: { greater_than_or_equal_to: 0 }
  validates :nickname, length: { maximum: 100 }

  # @return [WebAuthn::RelyingParty] The relying party for the current request.
  def self.relying_party(request)
    uri = URI.parse(request.base_url)

    WebAuthn::RelyingParty.new(
      allowed_origins: [request.base_url],
      id: uri.host,
      name: Danbooru.config.app_name,
    )
  end

  # @return [WebAuthn::PublicKeyCredential::CreationOptions] Options for registering a new passkey.
  def self.registration_options(user, request)
    relying_party(request).options_for_registration(
      user: { id: user.passkey_user_id, name: user.name, display_name: user.name },
      exclude: user.passkeys.pluck(:external_id),
      authenticator_selection: { user_verification: "required", resident_key: "preferred" },
      attestation: "none",
    )
  end

  # @return [WebAuthn::PublicKeyCredential::RequestOptions] Options for authenticating with a passkey.
  def self.authentication_options(user, request)
    relying_party(request).options_for_authentication(
      allow: user.passkeys.pluck(:external_id),
      user_verification: "required",
    )
  end

  # Verify a registration response and save the passkey.
  #
  # @param user [User] The user registering the passkey.
  # @param credential [Hash] The credential returned by the browser.
  # @param challenge [String] The challenge from the registration options.
  # @param request [ActionDispatch::Request] The current request.
  # @param nickname [String, nil] An optional name for the passkey.
  # @return [Passkey] The newly created passkey.
  def self.register(user, credential, challenge, request, nickname: nil)
    webauthn_credential = relying_party(request).verify_registration(credential, challenge, user_verification: true)

    user.passkeys.create!(
      external_id: webauthn_credential.id,
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count,
      nickname: nickname.presence,
    )
  end

  # Verify an authentication response and update the passkey's sign count.
  #
  # @param credential [Hash] The credential returned by the browser.
  # @param challenge [String] The challenge from the authentication options.
  # @param request [ActionDispatch::Request] The current request.
  # @raise [WebAuthn::Error] If the credential is invalid.
  def verify!(credential, challenge, request)
    webauthn_credential = self.class.relying_party(request).verify_authentication(
      credential,
      challenge,
      public_key: public_key,
      sign_count: sign_count,
      user_verification: true,
    )

    update!(sign_count: webauthn_credential.sign_count, last_used_at: Time.zone.now)
  end

  def display_name
    nickname.presence || "Passkey"
  end
end
