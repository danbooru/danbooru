require File.expand_path('../../test_helper',  __FILE__)

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
    
    should "should not validate if the creator is not privileged" do
      user = Factory.create(:user)
      privileged = Factory.create(:privileged_user)
      member = Factory.create(:user)
      
      CurrentUser.user = privileged
      feedback = Factory.create(:user_feedback, :user => user)
      assert(feedback.errors.empty?)
      
      CurrentUser.user = member
      feedback = Factory.build(:user_feedback, :user => user)
      feedback.save
      assert(feedback.errors.any?)
    end
  end
end
