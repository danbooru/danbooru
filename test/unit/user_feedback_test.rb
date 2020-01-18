require 'test_helper'

class UserFeedbackTest < ActiveSupport::TestCase
  context "A user's feedback" do
    should "create a dmail" do
      user = FactoryBot.create(:user)
      gold = FactoryBot.create(:gold_user)
      member = FactoryBot.create(:user)
      dmail = <<~EOS.chomp
        @#{gold.name} created a "positive record":/user_feedbacks?search[user_id]=#{user.id} for your account:

        good job!
      EOS

      assert_difference("Dmail.count", 1) do
        create(:user_feedback, creator: gold, user: user, body: "good job!")
        assert_equal(dmail, user.dmails.last.body)
      end
    end

    should "not validate if the creator is the user" do
      user = FactoryBot.create(:gold_user)
      feedback = build(:user_feedback, creator: user, user: user)
      feedback.save
      assert_equal(["You cannot submit feedback for yourself"], feedback.errors.full_messages)
    end

    should "not validate if the creator is not gold" do
      user = FactoryBot.create(:user)
      gold = FactoryBot.create(:gold_user)
      member = FactoryBot.create(:user)

      feedback = FactoryBot.create(:user_feedback, creator: gold, user: user)
      assert(feedback.errors.empty?)

      feedback = build(:user_feedback, creator: member, user: user)
      feedback.save
      assert_equal(["You must be gold"], feedback.errors.full_messages)
    end
  end
end
