require 'test_helper'

class TagSubscriptionTest < ActiveSupport::TestCase
  setup do
    user = FactoryGirl.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end

  context "A tag subscription" do
    should "migrate to saved searches" do
      sub = FactoryGirl.create(:tag_subscription, tag_query: "foo bar\r\nbar\nbaz", :name => "Artist 1")
      sub.migrate_to_saved_searches

      assert_equal(1, CurrentUser.user.subscriptions.size)
      assert_equal(3, CurrentUser.user.saved_searches.size)
      assert_equal(["foo bar", "bar", "baz"], CurrentUser.user.saved_searches.pluck(:query))
      assert_equal([%w[artist_1]]*3, CurrentUser.user.saved_searches.pluck(:labels))
    end
  end
end
