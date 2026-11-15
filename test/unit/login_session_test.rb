require "test_helper"

class LoginSessionTest < ActiveSupport::TestCase
  context "LoginSession.expire!" do
    should "expire active sessions that have been idle for longer than the idle period" do
      freeze_time

      idle = create(:login_session, last_seen_at: (LoginSession::MAX_IDLE_PERIOD + 1.minute).ago)
      recent = create(:login_session, last_seen_at: 1.day.ago)
      logged_out = create(:login_session, last_seen_at: 1.year.ago, status: :logged_out)

      LoginSession.expire!

      assert_equal(true, idle.reload.expired?)
      assert_equal(true, recent.reload.active?)
      assert_equal(true, logged_out.reload.logged_out?)
    end
  end
end
