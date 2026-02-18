require "test_helper"

class UploadLimitTest < ActiveSupport::TestCase
  context "Upload limits:" do
    setup do
      @user = create(:user, upload_points: 1000, created_at: 2.weeks.ago)
      @approver = create(:moderator_user)
    end

    context "a pending post that is deleted" do
      should "decrease the uploader's upload points" do
        @post = create(:post, uploader: @user, is_pending: true, created_at: 7.days.ago)
        assert_equal(1000, @user.reload.upload_points)

        PostPruner.prune!
        assert_equal(967, @user.reload.upload_points)
      end
    end

    context "a new post that is deleted within the first 3 days" do
      should "cost the uploader 5 upload slots" do
        @post = create(:post, uploader: @user, is_deleted: true, created_at: 1.day.ago)

        assert_equal(5, @user.upload_limit.used_upload_slots)
      end
    end

    context "a pending post that is approved" do
      should "increase the uploader's upload points" do
        @post = create(:post, uploader: @user, is_pending: true, created_at: 7.days.ago)
        assert_equal(1000, @user.reload.upload_points)

        create(:post_approval, post: @post, user: @approver)
        assert_equal(1010, @user.reload.upload_points)
      end

      should "not increase the uploader's upload points beyond the maximum" do
        @user.update!(upload_points: UploadLimit::MAXIMUM_POINTS)

        @post = create(:post, uploader: @user, is_pending: true, created_at: 7.days.ago)
        assert_equal(UploadLimit::MAXIMUM_POINTS, @user.reload.upload_points)

        create(:post_approval, post: @post, user: @approver)
        assert_equal(UploadLimit::MAXIMUM_POINTS, @user.reload.upload_points)
      end
    end

    context "an approved post that is deleted" do
      should "decrease the uploader's upload points" do
        @post = create(:post, uploader: @user, is_pending: true)
        assert_equal(1000, @user.reload.upload_points)

        create(:post_approval, post: @post, user: @approver)
        assert_equal(1010, @user.reload.upload_points)

        as(@approver) { @post.delete!("bad") }
        assert_equal(967, @user.reload.upload_points)
      end
    end

    context "a deleted post that is undeleted" do
      should "increase the uploader's upload points" do
        @post = create(:post, uploader: @user)
        as(@approver) { @post.delete!("bad") }
        assert_equal(967, @user.reload.upload_points)

        create(:post_approval, post: @post, user: @approver)
        assert_equal(1010, @user.reload.upload_points)
      end
    end

    context "an appealed post that is undeleted" do
      should "increase the uploader's upload points" do
        @post = create(:post, uploader: @user)

        as(@approver) { @post.delete!("bad") }
        assert_equal(967, @user.reload.upload_points)

        @appeal = create(:post_appeal, post: @post)
        create(:post_approval, post: @post, user: @approver)

        assert_equal(true, @appeal.reload.succeeded?)
        assert_equal(false, @post.reload.is_deleted?)
        assert_equal(1010, @user.reload.upload_points)
      end
    end

    context "an appealed post that is rejected" do
      should "not decrease the uploader's upload points" do
        @post = create(:post, uploader: @user)

        as(@approver) { @post.delete!("bad") }
        assert_equal(967, @user.reload.upload_points)

        @appeal = create(:post_appeal, post: @post)
        travel(4.days) { PostPruner.prune! }

        assert_equal(true, @appeal.reload.rejected?)
        assert_equal(true, @post.reload.is_deleted?)
        assert_equal(967, @user.reload.upload_points)
      end
    end

    context "a user who hasn't uploaded before" do
      should "be limited to 5 upload slots in the first hour" do
        assert_equal(5, @user.upload_limit.upload_slots)

        create(:post, uploader: @user, created_at: 2.hours.ago)
        assert_equal(15, @user.upload_limit.upload_slots)
      end
    end

    context "maxed?" do
      should "work" do
        points_to_max = UploadLimit.level_to_points(UploadLimit.points_to_level(UploadLimit::MAXIMUM_POINTS))

        create(:post, uploader: @user, created_at: 10.days.ago)
        @user.update!(upload_points: points_to_max)
        assert(@user.upload_limit.maxed?)
        @user.update!(upload_points: points_to_max - 1)
        assert_not(@user.upload_limit.maxed?)
      end
    end
  end
end
