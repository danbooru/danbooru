require 'test_helper'

class JanitorTrialTest < ActiveSupport::TestCase
  context "A janitor trial" do
    setup do
      @admin = FactoryBot.create(:admin_user)
      @user = FactoryBot.create(:user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "upon creation" do
      should "create a dmail when testing a new janitor" do
        assert_difference("Dmail.count", 2) do
          JanitorTrial.create(:user_id => @user.id)
        end
      end

      should "toggle the can_approve_posts flag on the user" do
        janitor_trial = JanitorTrial.create(:user_id => @user.id)
        @user.reload
        assert(@user.can_approve_posts?)
      end
    end

    context "upon demotion" do
      setup do
        @janitor_trial = FactoryBot.create(:janitor_trial, :user_id => @user.id)
      end

      should "create a negative feedback record" do
        assert_difference("UserFeedback.count", 1) do
          @janitor_trial.demote!
        end
      end

      should "revoke approval privileges" do
        @janitor_trial.demote!
        @user.reload
        assert_equal(false, @user.can_approve_posts?)
      end
    end

    context "upon promotion" do
      setup do
        @janitor_trial = FactoryBot.create(:janitor_trial, :user_id => @user.id)
      end

      should "destroy the trial object" do
        @janitor_trial.promote!
        assert_equal(false, @janitor_trial.active?)
      end
    end
  end
end
