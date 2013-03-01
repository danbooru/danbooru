require 'test_helper'

class UserFeedbackTest < ActiveSupport::TestCase
  context "A user's feedback" do
    setup do
      CurrentUser.ip_addr = "127.0.0.1"
      MEMCACHE.flush_all
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    should "create a dmail" do
      user = FactoryGirl.create(:user)
      privileged = FactoryGirl.create(:privileged_user)
      member = FactoryGirl.create(:user)
      
      CurrentUser.user = privileged
      assert_difference("Dmail.count", 2) do
        FactoryGirl.create(:user_feedback, :user => user)
      end
    end
    
    should "should not validate if the creator is not privileged" do
      user = FactoryGirl.create(:user)
      privileged = FactoryGirl.create(:privileged_user)
      member = FactoryGirl.create(:user)
      
      CurrentUser.user = privileged
      feedback = FactoryGirl.create(:user_feedback, :user => user)
      assert(feedback.errors.empty?)
      
      CurrentUser.user = member
      feedback = FactoryGirl.build(:user_feedback, :user => user)
      feedback.save
      assert(feedback.errors.any?)
    end
  end
end
