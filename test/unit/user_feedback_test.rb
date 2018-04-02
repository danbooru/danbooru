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
      user = FactoryBot.create(:user)
      gold = FactoryBot.create(:gold_user)
      member = FactoryBot.create(:user)

      dmail = <<~EOS.chomp
        @#{gold.name} created a "positive record":/user_feedbacks?search[user_id]=#{user.id} for your account:

        good job!
      EOS

      CurrentUser.user = gold
      assert_difference("Dmail.count", 1) do
        FactoryBot.create(:user_feedback, :user => user, :body => "good job!")
        assert_equal(dmail, user.dmails.last.body)
      end
    end
    
    should "not validate if the creator is the user" do
      gold_user = FactoryBot.create(:gold_user)
      CurrentUser.user = gold_user
      feedback = FactoryBot.build(:user_feedback, :user => gold_user)
      feedback.save
      assert_equal(["You cannot submit feedback for yourself"], feedback.errors.full_messages)
    end

    should "not validate if the creator is not gold" do
      user = FactoryBot.create(:user)
      gold = FactoryBot.create(:gold_user)
      member = FactoryBot.create(:user)

      CurrentUser.user = gold
      feedback = FactoryBot.create(:user_feedback, :user => user)
      assert(feedback.errors.empty?)

      CurrentUser.user = member
      feedback = FactoryBot.build(:user_feedback, :user => user)
      feedback.save
      assert_equal(["You must be gold"], feedback.errors.full_messages)
    end
  end
end
