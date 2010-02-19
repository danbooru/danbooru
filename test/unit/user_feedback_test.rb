require File.dirname(__FILE__) + '/../test_helper'

class UserFeedbackTest < ActiveSupport::TestCase
  context "A user's feedback" do
    should "should not validate if the creator is not privileged" do
      user = Factory.create(:user)
      admin = Factory.create(:admin_user)
      moderator = Factory.create(:moderator_user)
      janitor = Factory.create(:janitor_user)
      contributor = Factory.create(:contributor_user)
      privileged = Factory.create(:privileged_user)
      member = Factory.create(:user)
      
      feedback = Factory.create(:user_feedback, :user => user, :creator => admin)
      assert(feedback.errors.empty?)
      feedback = Factory.create(:user_feedback, :user => user, :creator => moderator)
      assert(feedback.errors.empty?)
      feedback = Factory.create(:user_feedback, :user => user, :creator => janitor)
      assert(feedback.errors.empty?)
      feedback = Factory.create(:user_feedback, :user => user, :creator => contributor)
      assert(feedback.errors.empty?)
      feedback = Factory.create(:user_feedback, :user => user, :creator => privileged)
      assert(feedback.errors.empty?)
      feedback = Factory.build(:user_feedback, :user => user, :creator => member)
      feedback.save
      assert(feedback.errors.any?)
    end
  end
end
