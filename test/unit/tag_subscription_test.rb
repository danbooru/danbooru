require 'test_helper'

class TagSubscriptionTest < ActiveSupport::TestCase
  setup do
    user = FactoryGirl.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
    MEMCACHE.flush_all
  end
  
  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end
  
  context "A tag subscription" do
    should "find the union of all posts for each tag in its tag query" do
      posts = []
      user = FactoryGirl.create(:user)
      posts << FactoryGirl.create(:post, :tag_string => "aaa")
      posts << FactoryGirl.create(:post, :tag_string => "bbb")
      posts << FactoryGirl.create(:post, :tag_string => "ccc")
      posts << FactoryGirl.create(:post, :tag_string => "ddd")
      sub_1 = FactoryGirl.create(:tag_subscription, :tag_query => "aaa bbb", :creator => user, :name => "zzz")
      sub_2 = FactoryGirl.create(:tag_subscription, :tag_query => "ccc", :creator => user, :name => "yyy")
      assert_equal([posts[1].id, posts[0].id], TagSubscription.find_posts(user.id, "zzz").map(&:id))
      assert_equal([posts[2].id, posts[1].id, posts[0].id], TagSubscription.find_posts(user.id).map(&:id))
    end
    
    should "cache its tag query results" do
      posts = []
      user = FactoryGirl.create(:user)
      posts << FactoryGirl.create(:post, :tag_string => "aaa")
      posts << FactoryGirl.create(:post, :tag_string => "bbb")
      posts << FactoryGirl.create(:post, :tag_string => "ccc")
      sub = FactoryGirl.create(:tag_subscription, :tag_query => "aaa bbb", :creator => user, :name => "zzz")
      assert_equal("#{posts[1].id},#{posts[0].id}", sub.post_ids)
    end
    
    should "find posts based on its cached post ids" do
      user = FactoryGirl.create(:user)
      subs = []
      subs << FactoryGirl.create(:tag_subscription, :tag_query => "aaa", :creator => user, :name => "zzz")
      subs << FactoryGirl.create(:tag_subscription, :tag_query => "bbb", :creator => user, :name => "yyy")
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
      subscriptions << FactoryGirl.create(:tag_subscription, :tag_query => "aaa", :creator => users[0])
      subscriptions << FactoryGirl.create(:tag_subscription, :tag_query => "bbb", :creator => users[1])
      TagSubscription.process_all
      subscriptions.each {|x| x.reload}
      assert_equal("#{posts[0].id}", subscriptions[0].post_ids)
      assert_equal("#{posts[1].id}", subscriptions[1].post_ids)
    end
  end
end
