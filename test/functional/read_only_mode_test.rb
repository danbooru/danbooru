require "test_helper"

class ReadOnlyModeTest < ActionDispatch::IntegrationTest
  teardown do
    Danbooru.config.unstub(:read_only_mode?)
  end

  def enable_read_only_mode
    Danbooru.config.stubs(:read_only_mode?).returns(true)
  end

  context "In read-only mode" do
    should "show the banner on GET requests" do
      enable_read_only_mode

      get root_path

      assert_response :success
      assert_select "#read-only-mode-notice"
    end

    should "not affect requests when disabled" do
      get root_path

      assert_response :success
      assert_select "#read-only-mode-notice", count: 0
    end

    should "block login attempts" do
      user = create(:user)
      enable_read_only_mode

      assert_no_difference("LoginSession.count") do
        post session_path, params: { session: { name: user.name, password: "password" }}
      end

      assert_response 503
    end

    should "block write requests" do
      user = create(:user)
      login_as(user)
      enable_read_only_mode

      assert_no_difference("Post.count") do
        post posts_path, params: { post: { tag_string: "test" }}
      end

      assert_response 503
    end

    should "not update API key usage" do
      api_key = create(:api_key)
      enable_read_only_mode

      get profile_path(login: api_key.user.name, api_key: api_key.key), as: :json

      assert_response :success
      assert_equal(0, api_key.reload.uses)
    end

    should "not update the login session last seen time" do
      user = create(:user)
      login_as(user)
      login_session = user.login_sessions.last
      last_seen_at = login_session.last_seen_at
      enable_read_only_mode

      travel_to(2.hours.from_now) do
        get root_path
      end

      assert_response :success
      assert_equal(last_seen_at.to_i, login_session.reload.last_seen_at.to_i)
    end

    should "not mark dmails as read" do
      user = create(:user)
      dmail = create(:dmail, owner: user, to: user, from: create(:user), is_read: false)
      login_as(user)
      enable_read_only_mode

      get dmail_path(dmail)

      assert_response :success
      assert_equal(false, dmail.reload.is_read)
    end

    should "not mark forum topics as read" do
      user = create(:user)
      forum_topic = create(:forum_topic)
      login_as(user)
      enable_read_only_mode

      get forum_topic_path(forum_topic)

      assert_response :success
      assert_equal(false, ForumTopicVisit.exists?(user: user, forum_topic: forum_topic))
    end
  end
end
