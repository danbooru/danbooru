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

    should "show a notice for blocked javascript requests" do
      user = create(:user)
      post_record = create(:post)
      login_as(user)
      enable_read_only_mode

      post favorites_path(post_id: post_record.id), xhr: true

      assert_response 503
      assert_equal("text/javascript", response.media_type)
      assert_equal("true", response.headers["X-Danbooru-Read-Only"])
      assert_includes(response.body, "Danbooru.Notice.error")
      assert_includes(response.body, "The site is in read-only mode")
    end

    should "identify blocked json write requests" do
      user = create(:user)
      post_record = create(:post)
      login_as(user)
      enable_read_only_mode

      post favorites_path(post_id: post_record.id), as: :json

      assert_response 503
      assert_equal("application/json", response.media_type)
      assert_equal("true", response.headers["X-Danbooru-Read-Only"])
      assert_equal("ActiveRecord::ReadOnlyError", response.parsed_body["error"])
    end

    should "allow actions that only read data" do
      user = create(:user)
      login_as(user)
      enable_read_only_mode

      post dtext_preview_path, params: { body: "test" }

      assert_response :success
    end

    should "allow note previews" do
      user = create(:user)
      note = as(user) { create(:note, body: "test") }
      login_as(user)
      enable_read_only_mode

      post preview_notes_path(format: :json), params: { note: { post_id: note.post_id, x: 0, y: 0, width: 1, height: 1, body: "test" }}

      assert_response :success
    end

    should "ignore login verification links" do
      user = create(:user)
      login_event = create(:user_event, user: user, category: :login_pending_verification)
      signed_login_event = login_event.signed_id(purpose: :login_verification, expires_in: 15.minutes)
      enable_read_only_mode

      assert_no_difference(-> { user.user_events.login_verification.count }) do
        get new_session_path, params: { signed_login_event: signed_login_event }
      end

      assert_response :success
    end

    should "not set the read-only header on successful requests" do
      enable_read_only_mode

      get root_path

      assert_response :success
      assert_nil(response.headers["X-Danbooru-Read-Only"])
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

  context "Configuration" do
    should "parse the read only mode environment variable" do
      ENV["DANBOORU_READ_ONLY_MODE"] = "false"

      assert_equal(false, Danbooru.config.read_only_mode?)
    ensure
      ENV.delete("DANBOORU_READ_ONLY_MODE")
    end
  end

  context "Background jobs" do
    teardown do
      ApplicationJob.unpause_jobs!
      GoodJob::Setting.unpause(queue: "default") if GoodJob::Setting.paused?(queue: "default")
    end

    should "pause and unpause application jobs" do
      ApplicationJob.pause_jobs!
      assert_equal(true, GoodJob::Setting.paused?(label: ApplicationJob::READ_ONLY_LABEL))

      ApplicationJob.unpause_jobs!
      assert_equal(false, GoodJob::Setting.paused?(label: ApplicationJob::READ_ONLY_LABEL))
    end

    should "not unpause a manually paused queue" do
      GoodJob::Setting.pause(queue: "default")

      ApplicationJob.unpause_jobs!

      assert_equal(true, GoodJob::Setting.paused?(queue: "default"))
    end

    should "label application jobs" do
      assert_equal([ApplicationJob::READ_ONLY_LABEL], PruneJobsJob.new.good_job_labels)
    end

    should "not enqueue maintenance jobs in read-only mode" do
      enable_read_only_mode

      assert_no_enqueued_jobs do
        DanbooruMaintenance.queue(PruneJobsJob)
      end
    end
  end
end
