require 'test_helper'

class DailyMaintenanceTest < ActiveSupport::TestCase
  context "daily maintenance" do
    setup do
      # have ApiCacheGenerator save files to a temp dir.
      @temp_shared_dir_path = "/tmp/#{SecureRandom.uuid}"
      Danbooru.config.stubs(:shared_dir_path).returns(@temp_shared_dir_path)

      FactoryBot.create(:tag, post_count: 1) # for ApiCacheGenerator
      FactoryBot.create(:admin_user) # for SuperVoter.init!
    end

    teardown do
      FileUtils.rm_rf(@temp_shared_dir_path)
      Danbooru.config.unstub(:shared_dir_path)
    end

    should "work" do
      assert_nothing_raised { DailyMaintenance.new.run }
    end

    should "prune expired posts" do
      @pending = FactoryBot.create(:post, is_pending: true, created_at: 4.days.ago)
      @flagged = FactoryBot.create(:post, is_flagged: true, created_at: 4.days.ago)

      DailyMaintenance.new.run

      assert(true, @pending.reload.is_deleted)
      assert(true, @flagged.reload.is_deleted)
    end

    context "when pruning bans" do
      should "clear the is_banned flag for users who are no longer banned" do
        banner = FactoryBot.create(:admin_user)
        user = FactoryBot.create(:user)

        CurrentUser.as(banner) { FactoryBot.create(:ban, user: user, banner: banner, duration: 1) }

        assert_equal(true, user.reload.is_banned)
        travel_to(2.days.from_now) { DailyMaintenance.new.run }
        assert_equal(false, user.reload.is_banned)
      end
    end
  end
end
