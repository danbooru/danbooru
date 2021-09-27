require 'test_helper'

class PrunePostsJobTest < ActiveJob::TestCase
  context "PrunePostsJob" do
    should "prune expired posts" do
      @pending = create(:post, is_pending: true, created_at: 5.days.ago)
      @flagged = create(:post, is_flagged: true, created_at: 5.days.ago)
      @appealed = create(:post, is_deleted: true, created_at: 5.days.ago)

      @flag = create(:post_flag, post: @flagged, created_at: 4.days.ago)
      @appeal = create(:post_appeal, post: @appealed, created_at: 4.days.ago)

      PrunePostsJob.perform_now

      assert_equal(true, @pending.reload.is_deleted?)
      assert_equal(true, @flagged.reload.is_deleted?)
      assert_equal(true, @appealed.reload.is_deleted?)
      assert_equal(true, @flag.reload.succeeded?)
      assert_equal(true, @appeal.reload.rejected?)
    end
  end
end
