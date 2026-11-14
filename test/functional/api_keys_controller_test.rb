require "test_helper"

class ApiKeysControllerTest < ActionDispatch::IntegrationTest
  context "An api keys controller" do
    setup do
      @user = create(:user)
      @api_key = create(:api_key, user: @user, request: nil)
    end

    context "#index action" do
      should "let a user see their own API keys" do
        get_auth user_api_keys_path(@user.id), @user, reauthenticate: true

        assert_response :success
        assert_select "#api-key-#{@api_key.id}", count: 1
      end

      should "not let a user see API keys belonging to other users" do
        get_auth user_api_keys_path(@user.id), create(:user), reauthenticate: true

        assert_response :success
        assert_select "#api-key-#{@api_key.id}", count: 0
      end

      should "let the owner see all API keys" do
        get_auth user_api_keys_path(@user.id), create(:owner_user), reauthenticate: true

        assert_response :success
        assert_select "#api-key-#{@api_key.id}", count: 1
      end

      should "not return the key in the API" do
        get_auth user_api_keys_path(@user.id), @user, as: :json, reauthenticate: true

        assert_response :success
        assert_nil response.parsed_body.first["key"]
      end

      should "show Never for a permanent key" do
        @api_key.update!(expires: false)
        get_auth user_api_keys_path(@user.id), @user

        assert_response :success
        assert_select "#api-key-#{@api_key.id}", text: /Never/
      end

      should "not show the key in HTML" do
        get_auth user_api_keys_path(@user.id), @user

        assert_response :success
        assert_not_includes(response.body, @api_key.key)
      end

      should "not allow searching by key" do
        get_auth user_api_keys_path(@user.id, search: { key_like: "#{@api_key.key[0]}*" }), @user, as: :json, reauthenticate: true
        assert_response :success
        assert_equal(1, response.parsed_body.size)

        get_auth user_api_keys_path(@user.id, search: { key_like: "does-not-match*" }), @user, as: :json, reauthenticate: true
        assert_response :success
        assert_equal(1, response.parsed_body.size)

        get_auth user_api_keys_path(@user.id, search: { key: "does-not-match" }), @user, as: :json, reauthenticate: true
        assert_response :success
        assert_equal(1, response.parsed_body.size)
      end

      should "redirect to the confirm password page if the user hasn't recently authenticated" do
        login_as(@user)
        travel_to 2.hours.from_now do
          get user_api_keys_path(@user.id)
        end

        assert_redirected_to confirm_password_session_path(url: user_api_keys_path(@user.id))
      end

      should "redirect to the confirm password page if the user has just logged in" do
        post session_path, params: { session: { name: @user.name, password: "password" }}
        get user_api_keys_path(@user.id)

        assert_redirected_to confirm_password_session_path(url: user_api_keys_path(@user.id))
      end
    end

    context "#new action" do
      should "render for a Member user" do
        get_auth new_user_api_key_path(@user.id), @user, reauthenticate: true
        assert_response :success
      end

      should "pre-fill the form from the URL params" do
        get_auth new_user_api_key_path(@user.id, api_key: { name: "MyApp", permissions: ["posts:index"] }), @user, reauthenticate: true

        assert_response :success
        assert_select "input[name='api_key[name]'][value='MyApp']"
      end

      should "render an expiration date field" do
        get_auth new_user_api_key_path(@user.id), @user

        assert_response :success
        assert_select "input[name='api_key[expires_on]']"
      end

      should "render an expiry checkbox" do
        get_auth new_user_api_key_path(@user.id), @user

        assert_response :success
        assert_select "input[name='api_key[expires]'][type='checkbox']"
      end

      should "fail for an Anonymous user" do
        get new_user_api_key_path(@user.id)
        assert_response 403
      end
    end

    context "#create action" do
      should "create a new API key" do
        post_auth user_api_keys_path(@user.id), @user, params: { api_key: { name: "blah" }}, reauthenticate: true

        assert_response :success
        assert_equal("no-store", response.headers["Cache-Control"])
        assert_equal("blah", @user.api_keys.last.name)
        assert_match(/dbru_[A-Za-z0-9]+/, response.body)
        assert_equal(true, @user.user_events.api_key_create.exists?(login_session_id: @user.login_sessions.last.login_id))
      end

      should "set the expiration date from the form" do
        date = 1.month.from_now.to_date
        post_auth user_api_keys_path(@user.id), @user, params: { api_key: { name: "blah", expires: "1", expires_on: date }}

        assert_response :success
        assert_in_delta(date.end_of_day, @user.api_keys.last.expires_at, 0.001)
      end

      should "create a permanent key when expiry is unchecked" do
        post_auth user_api_keys_path(@user.id), @user, params: { api_key: { name: "blah", expires: "0" }}

        assert_response :success
        assert_nil(@user.api_keys.last.expires_at)
        assert_match(/This key does not expire/, response.body)
      end

      should "return the new key once in API responses" do
        post_auth user_api_keys_path(@user.id), @user, params: { api_key: { name: "blah" }}, as: :json

        assert_response :success
        assert_match(/\Adbru_[A-Za-z0-9]+\z/, response.parsed_body["key"])

        get_auth user_api_keys_path(@user.id), @user, as: :json

        assert_response :success
        assert_nil(response.parsed_body.first["key"])
      end

      should "not create a new API key using the user's API key with another user's recently authenticated session" do
        login_as(create(:user), reauthenticate: true)
        post user_api_keys_path(@user.id), as: :json, params: { api_key: { name: "blah" }}, headers: { HTTP_AUTHORIZATION: "Basic #{::Base64.strict_encode64("#{@user.name}:#{@api_key.key}")}" }

        assert_response 401
        assert_equal([@api_key], @user.api_keys.to_a)
      end
    end

    context "#edit action" do
      should "render for the API key owner" do
        get_auth edit_api_key_path(@api_key.id), @user, reauthenticate: true
        assert_response :success
      end

      should "show the expiration date without editable fields" do
        @api_key.update!(expires: true, expires_on: Date.tomorrow)

        get_auth edit_api_key_path(@api_key.id), @user

        assert_response :success
        assert_select "input[name='api_key[expires]']", count: 0
        assert_select "input[name='api_key[expires_on]']", count: 0
        assert_match(@api_key.expires_at.to_date.to_fs(:long), response.body)
      end

      should "fail for someone else" do
        get_auth edit_api_key_path(@api_key.id), create(:user), reauthenticate: true
        assert_response 403
      end
    end

    context "#update action" do
      should "render for the API key owner" do
        put_auth api_key_path(@api_key.id), @user, params: { api_key: { name: "blah", permitted_ip_addresses: "1.2.3.4" }}, reauthenticate: true

        assert_redirected_to user_api_keys_path(@user.id)
        assert_equal("blah", @api_key.reload.name)
        assert_equal(["1.2.3.4"], @api_key.permitted_ip_addresses.map(&:to_s))
        assert_equal(true, @user.user_events.api_key_update.exists?(login_session_id: @user.login_sessions.last.login_id))
      end

      should "not change the expiration date" do
        @api_key.update!(expires: true, expires_on: Date.tomorrow)
        expires_at = @api_key.expires_at
        name = @api_key.name

        put_auth api_key_path(@api_key.id), @user, params: { api_key: { name: "blah", expires: "0", expires_on: 1.month.from_now.to_date }}

        assert_response 403
        assert_equal(name, @api_key.reload.name)
        assert_equal(expires_at.to_i, @api_key.expires_at.to_i)
      end

      should "update without changing the expiration date" do
        @api_key.update!(expires: true, expires_on: Date.tomorrow)
        expires_at = @api_key.expires_at

        put_auth api_key_path(@api_key.id), @user, params: { api_key: { name: "blah", permitted_ip_addresses: "1.2.3.4" }}

        assert_redirected_to user_api_keys_path(@user.id)
        assert_equal(expires_at.to_i, @api_key.reload.expires_at.to_i)
      end

      should "fail for someone else" do
        put_auth api_key_path(@api_key.id), create(:user), reauthenticate: true
        assert_response 403
      end
    end

    context "#destroy" do
      should "delete the user's API key" do
        delete_auth api_key_path(@api_key.id), @user, reauthenticate: true

        assert_redirected_to user_api_keys_path(@user.id)
        assert_raise(ActiveRecord::RecordNotFound) { @api_key.reload }
        assert_equal(true, @user.user_events.api_key_delete.exists?(login_session_id: @user.login_sessions.last.login_id))
      end

      should "not allow deleting another user's API key" do
        delete_auth api_key_path(@api_key.id), create(:user), reauthenticate: true

        assert_response 403
        assert_not_nil(@api_key.reload)
      end
    end
  end
end
