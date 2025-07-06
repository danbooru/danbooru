require 'test_helper'

class NewsUpdateTest < ActiveSupport::TestCase
  context "News updates:" do
    context "during validation" do
      should normalize_attribute(:message).from("  foo  ").to("foo")

      should_not allow_value("").for(:message)
      should_not allow_value(" ").for(:message)
      should_not allow_value("x" * 281).for(:message)

      should_not allow_value(0.days).for(:duration)
      should_not allow_value(365.days).for(:duration)

      should "not allow more than one active news update at a time" do
        create(:news_update)
        news_update = build(:news_update)

        assert_equal(false, news_update.valid?)
        assert_includes(news_update.errors[:base], "Can't have more than one active news update at a time")
      end
    end
  end
end
