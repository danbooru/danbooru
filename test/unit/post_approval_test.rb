require 'test_helper'

class PostApprovalTest < ActiveSupport::TestCase
  context "a pending post" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"

      @post = FactoryGirl.create(:post, uploader_id: @user.id, is_pending: true)

      @approver = FactoryGirl.create(:user)
      @approver.can_approve_posts = true
      @approver.save
      CurrentUser.user = @approver

      CurrentUser.stubs(:can_approve_posts?).returns(true)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "allow approval" do
      assert_equal(false, @post.approved_by?(@approver))
    end

    context "That is approved" do
      should "create a postapproval record" do
        assert_difference("PostApproval.count") do
          @post.approve!
        end
      end

      context "that is then flagged" do
        setup do
          @user2 = FactoryGirl.create(:user)
          @user3 = FactoryGirl.create(:user)
          @approver2 = FactoryGirl.create(:user)
          @approver2.can_approve_posts = true
          @approver2.save
        end

        should "prevent the first approver from approving again" do
          @post.approve!(@approver)
          CurrentUser.user = @user2
          @post.flag!("blah")
          @post.approve!(@approver2)
          assert_not_equal(@approver.id, @post.approver_id)
          CurrentUser.user = @user3
          travel_to(PostFlag::COOLDOWN_PERIOD.from_now + 1.minute) do
            @post.flag!("blah blah")
          end

          approval = @post.approve!(@approver)
          assert_includes(approval.errors.full_messages, "You have previously approved this post and cannot approve it again")
        end
      end
    end
  end
end
