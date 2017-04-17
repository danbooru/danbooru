require 'test_helper'

class UserFeedbackTest < ActiveSupport::TestCase
  context "A user's feedback" do
    setup do
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "create a dmail" do
      user = FactoryGirl.create(:user)
      gold = FactoryGirl.create(:gold_user)
      member = FactoryGirl.create(:user)

      CurrentUser.user = gold
      assert_difference("Dmail.count", 1) do
        FactoryGirl.create(:user_feedback, :user => user)
      end
    end
    
    should "not validate if the creator is the user" do
      gold_user = FactoryGirl.create(:gold_user)
      CurrentUser.user = gold_user
      feedback = FactoryGirl.build(:user_feedback, :user => gold_user)
      feedback.save
      assert_equal(["You cannot submit feedback for yourself"], feedback.errors.full_messages)
    end

    should "not validate if the creator is not gold" do
      user = FactoryGirl.create(:user)
      gold = FactoryGirl.create(:gold_user)
      member = FactoryGirl.create(:user)

      CurrentUser.user = gold
      feedback = FactoryGirl.create(:user_feedback, :user => user)
      assert(feedback.errors.empty?)

      CurrentUser.user = member
      feedback = FactoryGirl.build(:user_feedback, :user => user)
      feedback.save
      assert_equal(["You must be gold"], feedback.errors.full_messages)
    end
  end
end
