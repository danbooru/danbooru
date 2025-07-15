require 'test_helper'

class PruneBansJobTest < ActiveJob::TestCase
  context "PruneBansJob" do
    should "prune all expired bans" do
      @expired_ban = create(:ban, created_at: 1.month.ago, duration: 1.week)
      @unexpired_ban = create(:ban, duration: 1.week)
      @expired_ban.user.update!(is_banned: true)

      assert_equal(true, @expired_ban.user.is_banned?)
      assert_equal(true, @unexpired_ban.user.is_banned?)

      PruneBansJob.perform_now

      assert_equal(false, @expired_ban.user.reload.is_banned?)
      assert_equal(true, @unexpired_ban.user.reload.is_banned?)
    end

    should "unban users with no active ban records" do
      user = create(:user, is_banned: true)

      PruneBansJob.perform_now

      assert_equal(false, user.reload.is_banned?)
    end
  end
end
