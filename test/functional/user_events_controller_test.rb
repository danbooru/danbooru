require 'test_helper'

class UserEventsControllerTest < ActionDispatch::IntegrationTest
  context "The user events controller" do
    context "index action" do
      setup do
        @user = create(:user)
        create(:user_event, user: @user, category: :login)
        create(:user_event, user: @user, category: :password_change)
        create(:user_event, user: @user, category: :logout)

        @user2 = create(:user)
        create(:user_event, user: @user2, category: :password_reset_request)
        create(:user_event, user: @user2, category: :password_reset)
      end

      should "render" do
        get_auth user_events_path, @user
        assert_response :success
      end

      should "show mods all events" do
        get_auth user_events_path, create(:moderator_user)

        assert_response :success
        assert_select "tbody tr", count: UserEvent.count
      end

      should "show users their own events" do
        get_auth user_events_path, @user

        assert_response :success
        assert_select "tbody tr", count: @user.user_events.count
      end

      should "not show users events belonging to other users" do
        get_auth user_events_path(search: { user_id: @user.id }), @user2

        assert_response :success
        assert_select "tbody tr", count: 0
      end

      should "not show anonymous users any events" do
        get user_events_path

        assert_response :success
        assert_select "tbody tr", count: 0
      end
    end
  end
end
