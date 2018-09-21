require 'test_helper'

class DmailFilterTest < ActiveSupport::TestCase
  def setup
    super

    @receiver = FactoryBot.create(:user)
    @sender = FactoryBot.create(:user)
  end

  def create_dmail(body, title)
    CurrentUser.scoped(@sender, "127.0.0.1") do
      Dmail.create_split(:to_id => @receiver.id, :body => body, :title => title)
    end
  end

  context "a dmail filter for a word" do
    setup do
      @dmail_filter = @receiver.create_dmail_filter(:words => "banned")
    end

    should "filter on that word in the body" do
      create_dmail("banned", "okay")
      assert_equal(true, @receiver.dmails.last.is_read?)
    end

    should "filter on that word in the title" do
      create_dmail("okay", "banned")
      assert_equal(true, @receiver.dmails.last.is_read?)
    end

    should "be case insensitive" do
      create_dmail("Banned.", "okay")
      assert_equal(true, @receiver.dmails.last.is_read?)
    end
  end

  context "a dmail filter for a user name" do
    setup do
      @dmail_filter = @receiver.create_dmail_filter(:words => @sender.name)
    end

    should "filter on the sender" do
      create_dmail("okay", "okay")
      assert_equal(true, @receiver.dmails.last.is_read?)
    end
  end

  context "a dmail filter containing multiple words" do
    should "filter dmails containing any of the words" do
      @receiver.create_dmail_filter(words: "foo bar spam")
      create_dmail("this is a test (not *SPAM*)", "hello world")

      assert_equal(true, @receiver.dmails.last.is_read?)
    end
  end
end
