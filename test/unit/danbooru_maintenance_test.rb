require 'test_helper'

class DanbooruMaintenanceTest < ActiveSupport::TestCase
  context "daily maintenance" do
    should "work" do
      assert_nothing_raised { DanbooruMaintenance.daily }
    end

    should "prune expired posts" do
      @pending = create(:post, is_pending: true, created_at: 5.days.ago)
      @flagged = create(:post, is_flagged: true, created_at: 5.days.ago)
      @appealed = create(:post, is_deleted: true, created_at: 5.days.ago)

      @flag = create(:post_flag, post: @flagged, created_at: 4.days.ago)
      @appeal = create(:post_appeal, post: @appealed, created_at: 4.days.ago)

      DanbooruMaintenance.daily

      assert_equal(true, @pending.reload.is_deleted?)
      assert_equal(true, @flagged.reload.is_deleted?)
      assert_equal(true, @appealed.reload.is_deleted?)
      assert_equal(true, @flag.reload.succeeded?)
      assert_equal(true, @appeal.reload.rejected?)
    end

    context "when pruning bans" do
      should "clear the is_banned flag for users who are no longer banned" do
        banner = FactoryBot.create(:admin_user)
        user = FactoryBot.create(:user)

        CurrentUser.as(banner) { FactoryBot.create(:ban, user: user, banner: banner, duration: 1) }

        assert_equal(true, user.reload.is_banned)
        travel_to(2.days.from_now) { DanbooruMaintenance.daily }
        assert_equal(false, user.reload.is_banned)
      end
    end
  end
end
