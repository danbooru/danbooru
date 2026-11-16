require "test_helper"

class UserUpgradesControllerTest < ActionDispatch::IntegrationTest
  context "The upgrade codes controller" do
    should "return 404 for actions that don't exist" do
      post_auth "/upgrade_codes", create(:superadmin_user)
      assert_response 404
    end

    context "index action" do
      should "not render for superadmins" do
        create(:upgrade_code)
        get_auth upgrade_codes_path, create(:superadmin_user)

        assert_response 403
      end

      should "not render for superadmins in the API" do
        create(:upgrade_code)
        get_auth upgrade_codes_path(format: :json), create(:superadmin_user)

        assert_response 403
      end

      should "not render for non-privileged users" do
        create(:upgrade_code)
        @user = create(:admin_user)
        get_auth upgrade_codes_path, @user

        assert_response 403
      end
    end

    context "redeem action" do
      should "render for an anonymous user" do
        get redeem_upgrade_codes_path

        assert_response :success
      end

      should "render for a member user" do
        get_auth redeem_upgrade_codes_path, create(:user)

        assert_response :success
      end

      should "render for a Gold user" do
        get_auth redeem_upgrade_codes_path, create(:gold_user)

        assert_response :success
      end
    end

    context "upgrade action" do
      should "return an error for an invalid code" do
        code = create(:upgrade_code)
        user = create(:user)
        post_auth upgrade_upgrade_codes_path, user, params: { upgrade_code: { code: "abcd" }}, xhr: true

        assert_response 422
        assert_equal(false, user.reload.is_gold?)
        assert_equal(false, code.reload.redeemed?)
        assert_nil(code.redeemer)
      end

      should "rate limit code attempts" do
        user = create(:user)
        login_as(user)
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)

        responses = 4.times.map do
          post upgrade_upgrade_codes_path, params: { upgrade_code: { code: "abcd" }}, xhr: true
          response.status
        end

        assert_equal([422, 422, 422, 429], responses)
      end

      should "return an error for an already redeemed code" do
        code = create(:upgrade_code, status: :redeemed)
        user = create(:user)
        post_auth upgrade_upgrade_codes_path, user, params: { upgrade_code: { code: code.code }}, xhr: true

        assert_response 422
        assert_equal(false, user.reload.is_gold?)
      end

      should "return an error for an already upgraded user" do
        code = create(:upgrade_code)
        user = create(:builder_user)
        post_auth upgrade_upgrade_codes_path, user, params: { upgrade_code: { code: code.code }}, xhr: true

        assert_response 422
        assert_equal(true, user.reload.is_builder?)
        assert_equal(false, code.reload.redeemed?)
        assert_nil(code.redeemer)
      end

      should "upgrade the user for a unredeemed code" do
        code = create(:upgrade_code)
        user = create(:user)
        post_auth upgrade_upgrade_codes_path, user, params: { upgrade_code: { code: code.code }}, xhr: true

        assert_response 200
        assert_equal(true, user.reload.is_gold?)
        assert_equal(true, code.reload.redeemed?)
        assert_equal(user, code.redeemer)
      end
    end
  end
end
