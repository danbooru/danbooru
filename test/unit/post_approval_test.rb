require 'test_helper'

class PostApprovalTest < ActiveSupport::TestCase
  context "a pending post" do
    setup do
      @user = create(:user, created_at: 2.weeks.ago)
      @post = create(:post, uploader: @user, is_pending: true)
      @approver = create(:user, can_approve_posts: true)
    end

    context "That is approved" do
      should "create a postapproval record" do
        assert_difference("PostApproval.count") do
          @post.approve!(@approver)
        end
      end

      should "prevent an approver from approving the same post twice" do
        @approval1 = create(:post_approval, post: @post, user: @approver)
        @approval2 = build(:post_approval, post: @post, user: @approver)

        assert_equal(false, @approval2.valid?)
        assert_equal(["You have previously approved this post and cannot approve it again"], @approval2.errors[:base])
      end
    end

    context "#search method" do
      should "work" do
        CurrentUser.scoped(@approver) do
          @post.update!(tag_string: "touhou")
          @approval = @post.approve!(@approver)
          @approvals = PostApproval.search(user_name: @approver.name, post_tags_match: "touhou", post_id: @post.id)

          assert_equal([@approval.id], @approvals.map(&:id))
        end
      end
    end
  end
end
