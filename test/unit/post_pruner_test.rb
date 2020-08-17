require 'test_helper'

class PostPrunerTest < ActiveSupport::TestCase
  context "PostPruner" do
    context "for a pending post" do
      should "prune expired posts" do
        @post = create(:post, created_at: 5.days.ago, is_pending: true)
        PostPruner.prune!

        assert_equal(true, @post.reload.is_deleted?)
        assert_equal(false, @post.is_pending?)

        assert_equal(1, @post.flags.size)
        assert_equal("Unapproved in three days", @post.flags.last.reason)
      end
    end

    context "for a flagged post" do
      should "prune expired flags" do
        @post = create(:post, created_at: 4.weeks.ago, is_flagged: true)
        @flag = create(:post_flag, post: @post, created_at: 5.days.ago)
        PostPruner.prune!

        assert_equal(true, @post.reload.is_deleted?)
        assert_equal(false, @post.is_pending?)
        assert_equal(false, @post.is_flagged?)
        assert_equal(true, @flag.reload.succeeded?)

        assert_equal(2, @post.flags.size)
        assert_equal("Unapproved in three days after returning to moderation queue", @post.flags.last.reason)
      end

      should "not prune unexpired flags" do
        @post = create(:post, created_at: 4.weeks.ago, is_flagged: true)
        @flag = create(:post_flag, post: @post, created_at: 1.day.ago)
        PostPruner.prune!

        assert_equal(false, @post.reload.is_deleted?)
        assert_equal(false, @post.is_pending?)
        assert_equal(true, @post.is_flagged?)
        assert_equal(true, @flag.reload.pending?)

        assert_equal(1, @post.flags.size)
      end

      should "leave the status of old flags unchanged" do
        @post = create(:post, created_at: 4.weeks.ago, is_flagged: true)
        @flag1 = create(:post_flag, post: @post, created_at: 3.weeks.ago, status: :succeeded)
        @flag2 = create(:post_flag, post: @post, created_at: 2.weeks.ago, status: :rejected)
        @flag3 = create(:post_flag, post: @post, created_at: 1.weeks.ago, status: :pending)
        PostPruner.prune!

        assert_equal(true, @post.reload.is_deleted?)
        assert_equal(false, @post.is_pending?)
        assert_equal(false, @post.is_flagged?)

        assert_equal(true, @flag1.reload.succeeded?)
        assert_equal(true, @flag2.reload.rejected?)
        assert_equal(true, @flag3.reload.succeeded?)
      end
    end

    context "for an appealed post" do
      should "prune expired appeals" do
        @post = create(:post, created_at: 4.weeks.ago, is_deleted: true)
        @appeal = create(:post_appeal, post: @post, created_at: 5.days.ago)
        PostPruner.prune!

        assert_equal(false, @post.reload.is_pending?)
        assert_equal(false, @post.is_flagged?)
        assert_equal(true, @post.is_deleted?)
        assert_equal(true, @appeal.reload.rejected?)

        assert_equal(1, @post.flags.size)
        assert_equal("Unapproved in three days after returning to moderation queue", @post.flags.last.reason)
      end

      should "not prune unexpired appeals" do
        @post = create(:post, created_at: 4.weeks.ago, is_deleted: true)
        @appeal = create(:post_appeal, post: @post, created_at: 1.day.ago)
        PostPruner.prune!

        assert_equal(false, @post.reload.is_pending?)
        assert_equal(false, @post.is_flagged?)
        assert_equal(true, @post.is_deleted?)
        assert_equal(true, @appeal.reload.pending?)

        assert_equal(0, @post.flags.size)
      end

      should "leave the status of old appeals unchanged" do
        @post = create(:post, created_at: 4.weeks.ago, is_deleted: true)
        @appeal1 = create(:post_appeal, post: @post, created_at: 3.weeks.ago, status: :succeeded)
        @appeal2 = create(:post_appeal, post: @post, created_at: 2.weeks.ago, status: :rejected)
        @appeal3 = create(:post_appeal, post: @post, created_at: 1.weeks.ago, status: :pending)
        PostPruner.prune!

        assert_equal(true, @post.reload.is_deleted?)
        assert_equal(false, @post.is_pending?)
        assert_equal(false, @post.is_flagged?)

        assert_equal(true, @appeal1.reload.succeeded?)
        assert_equal(true, @appeal2.reload.rejected?)
        assert_equal(false, @appeal3.reload.pending?)
      end
    end
  end
end
