require 'test_helper'

class ApproverPrunerTest < ActiveSupport::TestCase
  context "ApproverPruner" do
    setup do
      @approver = create(:user, can_approve_posts: true)
    end

    should "demote inactive approvers" do
      assert_equal([@approver.id], ApproverPruner.inactive_approvers.map(&:id))
    end

    should "not demote active approvers" do
      posts = create_list(:post, ApproverPruner::MINIMUM_APPROVALS + 1, is_pending: true)
      posts.each { |post| post.approve!(@approver) }

      assert_equal([], ApproverPruner.inactive_approvers.map(&:id))
    end

    should "not demote recently promoted approvers" do
      as(create(:admin_user)) do
        @user = create(:user)
        @user.promote_to!(User::Levels::BUILDER, can_approve_posts: true)
      end

      assert_not_includes(ApproverPruner.inactive_approvers.map(&:id), @user.id)
    end
  end
end
