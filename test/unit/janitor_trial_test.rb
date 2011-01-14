require_relative '../test_helper'

class JanitorTrialTest < ActiveSupport::TestCase
  context "A janitor trial" do
    setup do
      @admin = Factory.create(:admin_user)
      @user = Factory.create(:user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
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
      
      should "toggle the janitor flag on the user" do
        janitor_trial = JanitorTrial.create(:user_id => @user.id)
        @user.reload
        assert(@user.is_janitor?)
      end
    end

    context "upon demotion" do
      setup do
        @janitor_trial = Factory.create(:janitor_trial, :user_id => @user.id)
      end
      
      should "create a negative feedback record" do
        assert_difference("UserFeedback.count", 1) do
          @janitor_trial.demote!
        end
      end
    end
    
    context "upon promotion" do
      setup do
        @janitor_trial = Factory.create(:janitor_trial, :user_id => @user.id)
      end
      
      should "destroy the trial object" do
        assert_difference("JanitorTrial.count", -1) do
          @janitor_trial.promote!
        end
      end
    end
  end
end
