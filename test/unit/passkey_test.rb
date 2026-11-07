# frozen_string_literal: true

require "test_helper"

class PasskeyTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @origin = "http://www.example.com"
    @request = passkey_request(origin: @origin)
  end

  context "registration" do
    should "create a passkey" do
      client = WebAuthn::FakeClient.new(@origin)
      options = Passkey.registration_options(@user, @request)
      credential = client.create(challenge: options.challenge, rp_id: "www.example.com", user_verified: true)

      assert_difference(-> { @user.passkeys.count }, 1) do
        Passkey.register(@user, credential, options.challenge, @request, nickname: "My phone")
      end

      passkey = @user.passkeys.last
      assert_equal("My phone", passkey.nickname)
      assert_equal(credential["id"], passkey.external_id)
      assert(passkey.public_key.present?)
    end

    should "exclude existing passkeys from registration options" do
      passkey, = create_passkey(@user)

      options = Passkey.registration_options(@user, @request)

      assert_equal([passkey.external_id], options.exclude_credentials.pluck(:id))
    end

    should "reject an invalid registration" do
      client = WebAuthn::FakeClient.new(@origin)
      options = Passkey.registration_options(@user, @request)
      credential = client.create(challenge: options.challenge, rp_id: "www.example.com", user_verified: true)

      assert_raises(WebAuthn::Error) do
        Passkey.register(@user, credential, WebAuthn.standard_encoder.encode(SecureRandom.random_bytes(32)), @request)
      end
    end
  end

  context "authentication" do
    setup do
      @passkey, @client = create_passkey(@user)
    end

    should "include the user's passkeys in authentication options" do
      options = Passkey.authentication_options(@user, @request)

      assert_equal([@passkey.external_id], options.allow_credentials.pluck(:id))
    end

    should "verify a passkey" do
      options = Passkey.authentication_options(@user, @request)
      credential = passkey_assertion(@user, @client, @request, options.challenge)

      assert_changes(-> { @passkey.reload.last_used_at }) do
        assert_nothing_raised do
          @passkey.verify!(credential, options.challenge, @request)
        end
      end
    end

    should "reject an invalid passkey" do
      options = Passkey.authentication_options(@user, @request)
      credential = passkey_assertion(@user, @client, @request, options.challenge)

      assert_raises(WebAuthn::Error) do
        @passkey.verify!(credential, WebAuthn.standard_encoder.encode(SecureRandom.random_bytes(32)), @request)
      end
    end
  end
end
