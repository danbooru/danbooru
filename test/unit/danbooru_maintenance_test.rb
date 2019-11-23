require 'test_helper'

class DanbooruMaintenanceTest < ActiveSupport::TestCase
  context "daily maintenance" do
    setup do
      @admin = create(:admin_user) # for SuperVoter.init!
    end

    should "work" do
      assert_nothing_raised { DanbooruMaintenance.daily }
    end

    should "update the curated pool" do
      pool = as(@admin) { create(:pool, name: "curated") }
      Danbooru.config.stubs(:curated_pool_id).returns(pool.id)

      assert_nothing_raised { DanbooruMaintenance.daily }
    end

    should "prune expired posts" do
      @pending = FactoryBot.create(:post, is_pending: true, created_at: 4.days.ago)
      @flagged = FactoryBot.create(:post, is_flagged: true, created_at: 4.days.ago)

      DanbooruMaintenance.daily

      assert(true, @pending.reload.is_deleted)
      assert(true, @flagged.reload.is_deleted)
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
