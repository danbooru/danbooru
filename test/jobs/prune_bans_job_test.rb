require 'test_helper'

class PruneBansJobTest < ActiveJob::TestCase
  context "PruneBansJob" do
    should "prune all expired bans" do
      @expired_ban = travel_to(1.month.ago) { create(:ban, duration: 1.week) }
      @unexpired_ban = create(:ban, duration: 1.week)

      assert_equal(true, @expired_ban.user.is_banned?)
      assert_equal(true, @unexpired_ban.user.is_banned?)

      PruneBansJob.perform_now

      assert_equal(false, @expired_ban.user.reload.is_banned?)
      assert_equal(true, @unexpired_ban.user.reload.is_banned?)
    end
  end
end
