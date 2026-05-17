require "test_helper"

class UserFeedbackTest < ActiveSupport::TestCase
  context "A user's feedback" do
    should "create a dmail" do
      user = create(:user)
      gold = create(:gold_user)
      member = create(:user)
      dmail = <<~EOS.chomp
        @#{gold.name} created a "positive record":/user_feedbacks?search%5Buser_id%5D=#{user.id} for your account:

        good job!
      EOS

      assert_difference("Dmail.count", 1) do
        create(:user_feedback, creator: gold, user: user, body: "good job!")
        assert_equal(dmail, user.dmails.last.body)
      end
    end

    context "on validation" do
      should allow_value("x" * 1500).for(:body)

      should_not allow_value("").for(:body)
      should_not allow_value("   ").for(:body)
      should_not allow_value("\u200B").for(:body)
      should_not allow_value("x" * 1501).for(:body)
    end

    context "when normalizing the body" do
      should normalize_attribute(:body).from(" ").to("")
      should normalize_attribute(:body).from("  \u200B  ").to("")
      should normalize_attribute(:body).from(" foo ").to("foo")
      should normalize_attribute(:body).from("foo\tbar").to("foo bar")
      should normalize_attribute(:body).from("foo\nbar").to("foo\r\nbar")
      should normalize_attribute(:body).from("Pokémon".unicode_normalize(:nfd)).to("Pokémon".unicode_normalize(:nfc))
    end
  end
end
