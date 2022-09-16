require 'test_helper'

class UserEventsControllerTest < ActionDispatch::IntegrationTest
  context "The user events controller" do
    context "index action" do
      setup do
        @user = create(:user)
        create(:user_event, user: @user, category: :login)
        create(:user_event, user: @user, category: :password_change)
        create(:user_event, user: @user, category: :logout)
      end

      should "render for an admin" do
        get_auth user_events_path, create(:admin_user)
        assert_response :success
      end

      should "render for a mod" do
        get_auth user_events_path, create(:moderator_user)
        assert_response :success
      end

      should "fail for a normal user" do
        get_auth user_events_path, @user
        assert_response 403
      end

      should "show mods all events" do
        get_auth user_events_path(search: { category: "password_change" }), create(:moderator_user)

        assert_response :success
        assert_select "tbody tr", count: 1
      end
    end
  end
end
