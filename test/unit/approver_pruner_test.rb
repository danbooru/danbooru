require 'test_helper'

class ApproverPrunerTest < ActiveSupport::TestCase
  context "ApproverPruner" do
    setup do
      @approver = create(:approver)
    end

    should "demote inactive approvers" do
      assert_equal([@approver.id], ApproverPruner.inactive_approvers.map(&:id))
      assert_nothing_raised { ApproverPruner.prune! }
      assert_equal(User::Levels::CONTRIBUTOR, @approver.reload.level)
      assert_equal(1, @approver.dmails.received.count)
      assert_equal("Approver inactivity", @approver.dmails.received.last.title)
    end

    should "not demote active approvers" do
      posts = create_list(:post, ApproverPruner::MINIMUM_APPROVALS + 1, is_pending: true)
      posts.each { |post| create(:post_approval, post: post, user: @approver) }

      assert_equal([], ApproverPruner.inactive_approvers.map(&:id))
    end

    should "not demote recently promoted approvers" do
      as(create(:owner_user)) do
        @user = create(:user)
        @user.promote_to!(User::Levels::APPROVER)
      end

      assert_not_includes(ApproverPruner.inactive_approvers.map(&:id), @user.id)
    end

    should "dmail inactive approvers" do
      travel_to(Date.parse("2020-01-20")) do
        ApproverPruner.dmail_inactive_approvers!
      end

      assert_equal("You will lose approval privileges soon", @approver.dmails.received.last.title)
    end
  end
end
