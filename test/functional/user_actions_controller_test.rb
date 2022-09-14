require 'test_helper'

class UserActionsControllerTest < ActionDispatch::IntegrationTest
  context "The user actions controller" do
    context "index action" do
      setup do
        @user = create(:user)

        as(@user) do
          create(:artist)
          create(:artist_commentary)
          create(:ban)
          create(:bulk_update_request)
          create(:comment)
          create(:comment_vote)
          create(:dmail)
          create(:favorite_group)
          create(:forum_post)
          create(:forum_post_vote)
          create(:forum_topic)
          create(:mod_action)
          create(:moderation_report)
          create(:note)
          create(:post)
          create(:post_appeal)
          create(:post_approval)
          create(:post_disapproval)
          create(:post_flag)
          create(:post_replacement)
          create(:post_vote)
          create(:wiki_page)
          create(:saved_search)
          create(:tag)
          create(:tag_alias)
          create(:tag_implication)
          create(:upload)
          create(:user_event)
          create(:user_feedback)
          create(:user_name_change_request)
          create(:user_upgrade)
          create(:wiki_page)
        end
      end

      should "render for the owner" do
        get_auth user_events_path(limit: 1000), create(:admin_user)
        assert_response :success
      end

      should "render for an admin" do
        get_auth user_events_path(limit: 1000), create(:admin_user)
        assert_response :success
      end

      should "render for a mod" do
        get_auth user_events_path(limit: 1000), create(:moderator_user)
        assert_response :success
      end

      should "fail for a normal user" do
        get_auth user_actions_path(limit: 1000), create(:user)
        assert_response 403
      end

      should "render when filtering on a single user" do
        get_auth user_events_path(user_id: @user.id, limit: 1000), create(:owner_user)
        assert_response :success
      end
    end
  end
end

