require 'test_helper'

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  context "An api keys controller" do
    setup do
      @user = create(:user)
      @api_key = create(:api_key, user: @user)
    end

    context "#index action" do
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

    context "#new action" do
      should "render for a Member user" do
        get_auth new_user_api_key_path(@user.id), @user
        assert_response :success
      end

      should "fail for an Anonymous user" do
        get new_user_api_key_path(@user.id)
        assert_response 403
      end
    end

    context "#create action" do
      should "create a new API key" do
        post_auth user_api_keys_path(@user.id), @user, params: { api_key: { name: "blah" }}

        assert_redirected_to user_api_keys_path(@user.id)
        assert_equal("blah", @user.api_keys.last.name)
      end
    end

    context "#edit action" do
      should "render for the API key owner" do
        get_auth edit_api_key_path(@api_key.id), @user
        assert_response :success
      end

      should "fail for someone else" do
        get_auth edit_api_key_path(@api_key.id), create(:user)
        assert_response 403
      end
    end

    context "#update action" do
      should "render for the API key owner" do
        put_auth api_key_path(@api_key.id), @user, params: { api_key: { name: "blah" }}

        assert_redirected_to user_api_keys_path(@user.id)
        assert_equal("blah", @api_key.reload.name)
      end

      should "fail for someone else" do
        put_auth api_key_path(@api_key.id), create(:user)
        assert_response 403
      end
    end

    context "#destroy" do
      should "delete the user's API key" do
        delete_auth api_key_path(@api_key.id), @user

        assert_redirected_to user_api_keys_path(@user.id)
        assert_raise(ActiveRecord::RecordNotFound) { @api_key.reload }
      end

      should "not allow deleting another user's API key" do
        delete_auth api_key_path(@api_key.id), create(:user)

        assert_response 403
        assert_not_nil(@api_key.reload)
      end
    end
  end
end
