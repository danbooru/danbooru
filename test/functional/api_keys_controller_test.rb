require 'test_helper'

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  context "An api keys controller" do
    setup do
      @user = create(:user)
    end

    context "#index action" do
      setup do
        @api_key = create(:api_key, user: @user)
      end

      should "let a user see their own API keys" do
        get_auth user_api_keys_path(@user.id), @user

        assert_response :success
        assert_select "#api-key-#{@api_key.id}", count: 1
      end

      should "not let a user see API keys belonging to other users" do
        get_auth user_api_keys_path(@user.id), create(:user)

        assert_response :success
        assert_select "#api-key-#{@api_key.id}", count: 0
      end

      should "let the owner see all API keys" do
        get_auth user_api_keys_path(@user.id), create(:owner_user)

        assert_response :success
        assert_select "#api-key-#{@api_key.id}", count: 1
      end

      should "not return the key in the API" do
        get_auth user_api_keys_path(@user.id), @user, as: :json

        assert_response :success
        assert_nil response.parsed_body.first["key"]
      end
    end

    context "#create action" do
      should "create a new API key" do
        post_auth user_api_keys_path(@user.id), @user

        assert_redirected_to user_api_keys_path(@user.id)
        assert_equal(true, @user.api_key.present?)
      end
    end

    context "#destroy" do
      setup do
        @api_key = create(:api_key, user: @user)
      end

      should "delete the user's API key" do
        delete_auth api_key_path(@api_key.id), @user

        assert_redirected_to user_api_keys_path(@user.id)
        assert_nil(@user.reload.api_key)
      end

      should "not allow deleting another user's API key" do
        delete_auth api_key_path(@api_key.id), create(:user)

        assert_response 403
        assert_not_nil(@user.reload.api_key)
      end
    end
  end
end
