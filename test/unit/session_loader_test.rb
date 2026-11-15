require "test_helper"

class SessionLoaderTest < ActiveSupport::TestCase
  context "SessionLoader" do
    setup do
      @request = mock
      @request.stubs(:host).returns("danbooru")
      @request.stubs(:remote_ip).returns("127.0.0.1")
      @request.stubs(:path).returns("/")
      @request.stubs(:authorization).returns(nil)
      @request.stubs(:cookie_jar).returns({})
      @request.stubs(:cookies).returns({})
      @request.stubs(:parameters).returns({})
      @request.stubs(:query_parameters).returns({})
      @request.stubs(:session).returns({})
      @request.stubs(:headers).returns({})
      SessionLoader.any_instance.stubs(:initialize_session_cookies)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.safe_mode = nil
    end

    context ".load" do
      should "not log in a session without a login session" do
        @user = create(:user)
        @request.stubs(:session).returns({ user_id: @user.id })
        UserEvent.expects(:create_from_request!).never
        User.any_instance.expects(:with_lock).never
        SessionLoader.new(@request).load

        assert_equal(true, CurrentUser.user.is_anonymous?)
        assert_nil(@request.session[:user_id])
      end

      context "for a login session" do
        setup do
          freeze_time
          @user = create(:user)
        end

        should "update when the session was last seen" do
          login_session = create(:login_session, user: @user, last_seen_at: 2.hours.ago)
          @request.stubs(:session).returns({ user_id: @user.id, login_id: login_session.login_id })
          SessionLoader.new(@request).load

          assert_equal(@user, CurrentUser.user)
          assert_equal(Time.zone.now, login_session.reload.last_seen_at)
        end

        should "not update when the session was last seen less than an hour ago" do
          login_session = create(:login_session, user: @user, last_seen_at: 30.minutes.ago)
          @request.stubs(:session).returns({ user_id: @user.id, login_id: login_session.login_id })
          SessionLoader.new(@request).load

          assert_equal(@user, CurrentUser.user)
          assert_equal(30.minutes.ago, login_session.reload.last_seen_at)
        end

        should "not log in a session that has been idle for longer than the idle period" do
          login_session = create(:login_session, user: @user, last_seen_at: (LoginSession::MAX_IDLE_PERIOD + 1.minute).ago)
          @request.stubs(:session).returns({ user_id: @user.id, login_id: login_session.login_id })
          SessionLoader.new(@request).load

          assert_equal(true, CurrentUser.user.is_anonymous?)
          assert_nil(@request.session[:user_id])
          assert_nil(@request.session[:login_id])
        end
      end
    end

    context ".safe_mode?" do
      should "return true if the hostname is safebooru.donmai.us" do
        @request.stubs(:host).returns("safebooru.donmai.us")
        SessionLoader.new(@request).load

        assert_equal(true, CurrentUser.safe_mode?)
      end

      should "return false if the host contains the string danbooru" do
        @request.stubs(:host).returns("danbooru")
        SessionLoader.new(@request).load

        assert_equal(false, CurrentUser.safe_mode?)
      end

      should "return true if the user has enabled the safe mode account setting" do
        @user = create(:user, enable_safe_mode: true)
        @login_session = create(:login_session, user: @user)
        @request.stubs(:session).returns(user_id: @user.id, login_id: @login_session.login_id)
        SessionLoader.new(@request).load

        assert_equal(true, CurrentUser.safe_mode?)
      end

      should "not raise if the request has no remote ip" do
        @request.stubs(:remote_ip).returns(nil)

        assert_nothing_raised do
          SessionLoader.new(@request).load
        end
      end
    end
  end
end
