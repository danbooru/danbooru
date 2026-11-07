# frozen_string_literal: true

require "test_helper"

class PasskeysControllerTest < ActionDispatch::IntegrationTest
  context "The passkeys controller" do
    setup do
      @user = create(:user)
      @origin = "http://www.example.com"
      @rp_id = "www.example.com"
    end

    context "#index action" do
      should "render the current user's passkeys" do
        login_as(@user)
        create_passkey(@user, nickname: "My phone")

        get passkeys_path

        assert_response :success
        assert_select "div", text: /My phone/
      end

      should "not let an anonymous user see passkeys" do
        get passkeys_path

        assert_response 403
      end
    end

    context "#options action" do
      should "return registration options" do
        login_as(@user)

        post options_passkeys_path, as: :json

        assert_response :success
        assert(response.parsed_body["challenge"].present?)
        assert_equal(@rp_id, response.parsed_body["rp"]["id"])
      end
    end

    context "#create action" do
      should "create a passkey" do
        login_as(@user)

        client = WebAuthn::FakeClient.new(@origin)
        post options_passkeys_path, as: :json
        challenge = session[:passkey_registration_challenge]
        credential = client.create(challenge: challenge, rp_id: @rp_id, user_verified: true)

        assert_difference(-> { @user.passkeys.count }, 1) do
          post passkeys_path, params: { credential: credential, nickname: "My phone" }, as: :json
        end

        assert_response 201
        assert_equal("My phone", @user.passkeys.last.nickname)
        assert_equal(true, @user.user_events.passkey_create.exists?)
        assert_equal(true, @user.reload.backup_codes.present?)
      end

      should "reject a nickname that is too long" do
        login_as(@user)

        client = WebAuthn::FakeClient.new(@origin)
        post options_passkeys_path, as: :json
        challenge = session[:passkey_registration_challenge]
        credential = client.create(challenge: challenge, rp_id: @rp_id, user_verified: true)

        assert_no_difference(-> { @user.passkeys.count }) do
          post passkeys_path, params: { credential: credential, nickname: "a" * 101 }, as: :json
        end

        assert_response 422
      end

      should "reject an invalid credential" do
        login_as(@user)

        post options_passkeys_path, as: :json

        assert_no_difference(-> { @user.passkeys.count }) do
          post passkeys_path, params: { credential: { id: "invalid" }, nickname: "My phone" }, as: :json
        end

        assert_response 422
      end
    end

    context "#destroy action" do
      should "delete a passkey" do
        login_as(@user)
        passkey, = create_passkey(@user)

        assert_difference(-> { @user.passkeys.count }, -1) do
          delete passkey_path(passkey)
        end

        assert_redirected_to passkeys_path
        assert_equal(true, @user.user_events.passkey_delete.exists?)
      end

      should "clear backup codes when deleting the last passkey" do
        login_as(@user)
        passkey, = create_passkey(@user)
        @user.update!(backup_codes: [1111_1111])

        delete passkey_path(passkey)

        assert_nil(@user.reload.backup_codes)
      end

      should "not delete another user's passkey" do
        login_as(@user)
        passkey, = create_passkey(create(:user))

        delete passkey_path(passkey)

        assert_response 404
        assert(Passkey.exists?(passkey.id))
      end
    end
  end
end
