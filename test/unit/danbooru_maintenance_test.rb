require 'test_helper'

class DanbooruMaintenanceTest < ActiveSupport::TestCase
  context "hourly maintenance" do
    should "work" do
      assert_nothing_raised { DanbooruMaintenance.hourly }
    end

    should "prune expired posts" do
      @pending = create(:post, is_pending: true, created_at: 5.days.ago)
      @flagged = create(:post, is_flagged: true, created_at: 5.days.ago)
      @appealed = create(:post, is_deleted: true, created_at: 5.days.ago)

      @flag = create(:post_flag, post: @flagged, created_at: 4.days.ago)
      @appeal = create(:post_appeal, post: @appealed, created_at: 4.days.ago)

      DanbooruMaintenance.hourly

      assert_equal(true, @pending.reload.is_deleted?)
      assert_equal(true, @flagged.reload.is_deleted?)
      assert_equal(true, @appealed.reload.is_deleted?)
      assert_equal(true, @flag.reload.succeeded?)
      assert_equal(true, @appeal.reload.rejected?)
    end
  end

  context "hourly maintenance" do
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

  context "PostAppealForumUpdater" do
    should "work when there are no pending appeals" do
      assert_nothing_raised do
        PostAppealForumUpdater.update_forum!
      end
    end

    should "post pending appeals to the deletion appeal thread" do
      @topic = as(create(:user)) { create(:forum_topic, title: PostAppealForumUpdater::APPEAL_TOPIC_TITLE) }
      @appeal1 = create(:post_appeal, reason: "test")
      @appeal2 = create(:post_appeal, reason: "")
      @appeal3 = create(:post_appeal, created_at: 2.hours.ago)

      PostAppealForumUpdater.update_forum!

      assert_equal(@topic.id, ForumPost.last.topic_id)
      assert_equal("post ##{@appeal1.post_id}: #{@appeal1.reason}\npost ##{@appeal2.post_id}", ForumPost.last.body)
    end

    should "create the deletion appeal thread if it doesn't already exist" do
      @appeal = create(:post_appeal, reason: "")
      PostAppealForumUpdater.update_forum!

      assert_equal(PostAppealForumUpdater::APPEAL_TOPIC_TITLE, ForumPost.last.topic.title)
      assert_equal("post ##{@appeal.post_id}", ForumPost.last.body)
    end
  end
end
