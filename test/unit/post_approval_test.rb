require 'test_helper'

class PostApprovalTest < ActiveSupport::TestCase
  context "Post approvals:" do
    setup do
      @user = create(:user, created_at: 2.weeks.ago)
      @post = create(:post, uploader: @user, is_pending: true)
      @approver = create(:user, can_approve_posts: true)
    end

    context "a pending post" do
      context "that is approved" do
        should "create a postapproval record" do
          create(:post_approval, post: @post, user: @approver)

          assert_equal(1, @post.approvals.count)
          assert_equal(@approver, @post.approver)
          assert_equal(false, @post.reload.is_pending?)
          assert_equal(true, @post.reload.is_active?)
        end

        should "prevent an approver from approving the same post twice" do
          @approval1 = create(:post_approval, post: @post, user: @approver)
          @approval2 = build(:post_approval, post: @post, user: @approver)

          assert_equal(false, @approval2.valid?)
          assert_equal(["You have previously approved this post and cannot approve it again"], @approval2.errors[:base])
        end

        should "allow an admin to approve the same post twice" do
          @approver = create(:admin_user)

          create(:post_approval, post: @post, user: @approver)
          assert_equal(1, @post.approvals.count)
          assert_equal(@approver, @post.approver)
          assert_equal(false, @post.reload.is_pending?)
          assert_equal(true, @post.reload.is_active?)

          flag = create(:post_flag, post: @post, creator: create(:user))
          assert_equal(true, @post.reload.is_flagged?)
          assert_equal(false, @post.reload.is_active?)
          assert_equal("pending", flag.reload.status)

          create(:post_approval, post: @post, user: @approver)
          assert_equal(2, @post.approvals.count)
          assert_equal(@approver, @post.approver)
          assert_equal(false, @post.reload.is_flagged?)
          assert_equal(true, @post.reload.is_active?)
          assert_equal("rejected", flag.reload.status)
        end
      end
    end

    context "a deleted post" do
      setup do
        create(:post_approval, post: @post, user: @approver)
        @post.delete!("Unapproved in three days", user: User.system)
      end

      context "that is undeleted by a different approver" do
        should "be updated with the new approver" do
          @new_approver = create(:user)
          create(:post_approval, post: @post, user: @new_approver)

          assert_equal(2, @post.approvals.count)
          assert_equal(@new_approver, @post.approver)
          assert_equal(false, @post.reload.is_deleted?)
          assert_equal(true, @post.reload.is_active?)
          assert_equal("post_undelete", ModAction.last.category)
          assert_equal("undeleted post ##{@post.id}", ModAction.last.description)
        end
      end

      context "that is undeleted by the same approver" do
        should "not be permitted" do
          @approval = build(:post_approval, post: @post, user: @approver)

          assert_equal(false, @approval.valid?)
          assert_equal(["You have previously approved this post and cannot approve it again"], @approval.errors.full_messages)
        end
      end

      context "that is undeleted by the uploader" do
        should "not be permitted" do
          @approval = build(:post_approval, post: @post, user: @post.uploader)

          assert_equal(false, @approval.valid?)
          assert_equal(["You cannot approve a post you uploaded"], @approval.errors.full_messages)
        end
      end
    end

    context "#search method" do
      should "work" do
        CurrentUser.scoped(@approver) do
          @post.update!(tag_string: "touhou")
          @approval = create(:post_approval, post: @post, user: @approver)

          assert_search_equals(@approval, user_name: @approver.name, post_tags_match: "touhou", post_id: @post.id)
        end
      end
    end
  end
end
