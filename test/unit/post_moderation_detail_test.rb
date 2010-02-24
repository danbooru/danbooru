require File.dirname(__FILE__) + '/../test_helper'

class PostModerationDetailTest < ActiveSupport::TestCase
  context "A post moderation detail" do
    should "hide posts" do
      posts = []
      posts << Factory.create(:post)
      posts << Factory.create(:post)
      posts << Factory.create(:post)
      user = Factory.create(:user)
      detail = PostModerationDetail.create(:user => user, :post => posts[0])
      results = PostModerationDetail.filter(posts, user)
      assert_equal(2, results.size)
      assert(results.all? {|x| x.id != posts[0].id})
      results = PostModerationDetail.filter(posts, user, true)
      assert_equal(1, results.size)
      assert_equal(posts[0].id, results[0].id)
      user = Factory.create(:user)
      results = PostModerationDetail.filter(posts, user)
      assert_equal(3, results.size)
      results = PostModerationDetail.filter(posts, user, true)
      assert_equal(0, results.size)
    end
    
    should "prune itself" do
      post = Factory.create(:post, :is_flagged => true)
      user = Factory.create(:user)
      detail = PostModerationDetail.create(:user => user, :post => post)
      assert_difference("PostModerationDetail.count", 0) do
        PostModerationDetail.prune!
      end
      post.is_flagged = false
      post.updater_id = user.id
      post.updater_ip_addr = "127.0.0.1"
      post.save
      assert(post.errors.empty?)
      assert_difference("PostModerationDetail.count", -1) do
        PostModerationDetail.prune!
      end      
    end
  end
end
