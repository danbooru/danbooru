require 'test_helper'

class DmailFilterTest < ActiveSupport::TestCase
  def setup
    super

    @receiver = FactoryGirl.create(:user)
    @sender = FactoryGirl.create(:user)
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
end
