# frozen_string_literal: true

require "webauthn/fake_client"

module PasskeyTestHelper
  def passkey_request(origin: "http://www.example.com")
    ActionDispatch::TestRequest.create("HTTP_HOST" => URI.parse(origin).host)
  end

  # Register a passkey for the user with a fake WebAuthn authenticator.
  #
  # @return [Array<(Passkey, WebAuthn::FakeClient)>] The passkey and the client that created it.
  def create_passkey(user, origin: "http://www.example.com", nickname: "Test passkey")
    request = passkey_request(origin: origin)
    client = WebAuthn::FakeClient.new(origin)
    options = Passkey.registration_options(user, request)
    credential = client.create(challenge: options.challenge, rp_id: URI.parse(origin).host, user_verified: true)
    passkey = Passkey.register(user, credential, options.challenge, request, nickname: nickname)

    [passkey, client]
  end

  def passkey_assertion(user, client, request, challenge)
    client.get(
      challenge: challenge,
      rp_id: URI.parse(request.base_url).host,
      allow_credentials: user.passkeys.pluck(:external_id),
      user_verified: true,
    )
  end
end
