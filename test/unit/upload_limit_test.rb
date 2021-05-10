require 'test_helper'

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
        @post = create(:post, uploader: @user, is_deleted: true, created_at: 1.days.ago)

        assert_equal(5, @user.upload_limit.used_upload_slots)
      end
    end

    context "a pending post that is approved" do
      should "increase the uploader's upload points" do
        @post = create(:post, uploader: @user, is_pending: true, created_at: 7.days.ago)
        assert_equal(1000, @user.reload.upload_points)

        @post.approve!(@approver)
        assert_equal(1010, @user.reload.upload_points)
      end

      should "not increase the uploader's upload points beyond the maximum" do
        @user.update!(upload_points: UploadLimit::MAXIMUM_POINTS)

        @post = create(:post, uploader: @user, is_pending: true, created_at: 7.days.ago)
        assert_equal(UploadLimit::MAXIMUM_POINTS, @user.reload.upload_points)

        @post.approve!(@approver)
        assert_equal(UploadLimit::MAXIMUM_POINTS, @user.reload.upload_points)
      end
    end

    context "an approved post that is deleted" do
      should "decrease the uploader's upload points" do
        @post = create(:post, uploader: @user, is_pending: true)
        assert_equal(1000, @user.reload.upload_points)

        @post.approve!(@approver)
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

        @post.approve!(@approver)
        assert_equal(1010, @user.reload.upload_points)
      end
    end
  end
end
