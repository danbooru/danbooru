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
    context "for a user with too many subscriptions" do
      setup do
        Danbooru.config.stubs(:max_tag_subscriptions).returns(0)
        @user = FactoryGirl.create(:user)
      end

      should "fail" do
        sub = FactoryGirl.build(:tag_subscription, :tag_query => "aaa\nbbb", :creator => @user, :name => "zzz")
        sub.save
        assert_equal(["You can create up to 0 tag subscriptions"], sub.errors.full_messages)
      end
    end

    should "find the union of all posts for each tag in its tag query" do
      posts = []
      user = FactoryGirl.create(:user)
      posts << FactoryGirl.create(:post, :tag_string => "aaa")
      posts << FactoryGirl.create(:post, :tag_string => "bbb")
      posts << FactoryGirl.create(:post, :tag_string => "ccc")
      posts << FactoryGirl.create(:post, :tag_string => "ddd")
      CurrentUser.scoped(user, "127.0.0.1") do
        sub_1 = FactoryGirl.create(:tag_subscription, :tag_query => "aaa\nbbb", :name => "zzz")
        sub_2 = FactoryGirl.create(:tag_subscription, :tag_query => "ccc", :name => "yyy")
        assert_equal([posts[1].id, posts[0].id], TagSubscription.find_posts(user.id, "zzz").map(&:id))
        assert_equal([posts[2].id, posts[1].id, posts[0].id], TagSubscription.find_posts(user.id).map(&:id))
      end
    end

    should "cache its tag query results" do
      posts = []
      user = FactoryGirl.create(:user)
      posts << FactoryGirl.create(:post, :tag_string => "aaa")
      posts << FactoryGirl.create(:post, :tag_string => "bbb")
      posts << FactoryGirl.create(:post, :tag_string => "ccc")
      CurrentUser.scoped(user, "127.0.0.1") do
        sub = FactoryGirl.create(:tag_subscription, :tag_query => "aaa\nbbb", :name => "zzz")
        assert_equal("#{posts[1].id},#{posts[0].id}", sub.post_ids)
      end
    end

    should "find posts based on its cached post ids" do
      user = FactoryGirl.create(:user)
      CurrentUser.scoped(user, "127.0.0.1") do
        subs = []
        subs << FactoryGirl.create(:tag_subscription, :tag_query => "aaa", :name => "zzz")
        subs << FactoryGirl.create(:tag_subscription, :tag_query => "bbb", :name => "yyy")
        assert_equal([], TagSubscription.find_posts(user.id))
        assert_equal([], TagSubscription.find_posts(user.id, "zzz"))
        assert_equal([], TagSubscription.find_posts(user.id, "yyy"))
        posts = []
        posts << FactoryGirl.create(:post, :tag_string => "aaa")
        posts << FactoryGirl.create(:post, :tag_string => "bbb")
        posts << FactoryGirl.create(:post, :tag_string => "ccc")
        subs.each {|x| x.process; x.save}
        assert_equal([posts[1].id, posts[0].id], TagSubscription.find_posts(user.id).map(&:id))
        assert_equal([posts[0].id], TagSubscription.find_posts(user.id, "zzz").map(&:id))
        assert_equal([posts[1].id], TagSubscription.find_posts(user.id, "yyy").map(&:id))
      end
    end

    should "migrate to saved searches" do
      sub = FactoryGirl.create(:tag_subscription, tag_query: "foo bar\r\nbar\nbaz", :name => "Artist 1")
      sub.migrate_to_saved_searches

      assert_equal(1, CurrentUser.user.subscriptions.size)
      assert_equal(3, CurrentUser.user.saved_searches.size)
      assert_equal(["bar foo", "bar", "baz"], CurrentUser.user.saved_searches.pluck(:query))
      assert_equal([%w[artist_1]]*3, CurrentUser.user.saved_searches.pluck(:labels))
    end
  end

  context "A tag subscription manager" do
    should "process all active tag subscriptions" do
      users = []
      users << FactoryGirl.create(:user)
      users << FactoryGirl.create(:user)
      posts = []
      posts << FactoryGirl.create(:post, :tag_string => "aaa")
      posts << FactoryGirl.create(:post, :tag_string => "bbb")
      posts << FactoryGirl.create(:post, :tag_string => "ccc")
      subscriptions = []
      CurrentUser.scoped(users[0], "127.0.0.1") do
        subscriptions << FactoryGirl.create(:tag_subscription, :tag_query => "aaa")
      end
      CurrentUser.scoped(users[1], "127.0.0.1") do
        subscriptions << FactoryGirl.create(:tag_subscription, :tag_query => "bbb")
      end
      TagSubscription.process_all
      subscriptions.each {|x| x.reload}
      assert_equal("#{posts[0].id}", subscriptions[0].post_ids)
      assert_equal("#{posts[1].id}", subscriptions[1].post_ids)
    end
  end
end
