# frozen_string_literal: true

# This handles generating and verifying TOTP (time-based one-time-password) codes for 2FA.
#
# @see app/controllers/session_controller.rb
# @see app/controllers/totp_controller.rb
# @see https://en.wikipedia.org/wiki/Time-based_one-time_password
# @see https://github.com/mdp/rotp
# @see https://github.com/whomwah/rqrcode
class TOTP
  include ActiveModel::API

  attr_reader :totp, :secret, :username, :issuer

  # Create a new TOTP verifier.
  #
  # @param secret [String] The secret used to generate the code. This is shared by the server and the user.
  # @param username [String] The user's name. Only used for display purposes by the authenticator app.
  # @param issuer [String] The site name. Only used for display purposes by the authenticator app.
  def initialize(secret = TOTP.generate_secret, username: nil, issuer: Danbooru.config.canonical_app_name)
    @secret = secret
    @username = username
    @issuer = issuer
    @totp = ROTP::TOTP.new(secret, issuer: issuer)
  end

  # Generate a new 16-character secret.
  def self.generate_secret
    ROTP::Base32.random_base32(16)
  end

  # Create a new TOTP verifier from a signed secret.
  def self.from_signed_secret(signed_secret, **options)
    secret = Danbooru::MessageVerifier.new(:totp).verify(signed_secret)
    TOTP.new(secret, **options)
  end

  # The secret, cryptographically signed so it can't be modified by the user.
  def signed_secret
    Danbooru::MessageVerifier.new(:totp).generate(secret, expires_in: 1.hour)
  end

  # Verify whether the given 6-digit code is correct.
  #
  # @param code [String] The 6-digit code to verify.
  # @param window [Integer] How long to allow codes to be accepted before or after the current time,
  #   to account for clock drift between the server and client, or users entering codes just before they expire.
  def verify(code, window: 30.seconds)
    totp.verify(code.to_s, drift_behind: window.to_i, drift_ahead: window.to_i) != nil
  end

  # @return [String] The current 6-digit code.
  def code
    totp.now
  end

  # Return an URL containing the TOTP secret, for use in generating the QR code.
  #
  # The format is like this: otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example
  #
  # The URL may change if the user changes their username, or if the site's app name changes (for example, Danbooru vs.
  # Donmai.moe). This is okay because these are only used for display purposes by the authenticator app.
  #
  # @see https://github.com/google/google-authenticator/wiki/Key-Uri-Format
  def url
    totp.provisioning_uri(username)
  end

  # Return a QR code containing the TOTP secret.
  def qr_code
    RQRCode::QRCode.new(url)
  end
end
