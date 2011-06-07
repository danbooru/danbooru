require_relative '../test_helper'

class PoolTest < ActiveSupport::TestCase
  setup do
    user = Factory.create(:user)
    CurrentUser.user = user
    CurrentUser.ip_addr = "127.0.0.1"
    MEMCACHE.flush_all
  end
  
  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
  end
  
  context "A pool" do
    should "create versions for each distinct user" do
      pool = Factory.create(:pool)
      user = Factory.create(:user)
      assert_equal(1, pool.versions(true).size)
      pool.post_ids = "1"
      CurrentUser.ip_addr = "1.2.3.4"
      pool.save
      assert_equal(2, pool.versions(true).size)
      pool.post_ids = "1 2"
      pool.save
      assert_equal(2, pool.versions(true).size)
      pool.revert_to!(PoolVersion.first)
      assert_equal("", pool.post_ids)
    end
    
    should "have posts" do
      pool = Factory.create(:pool)
      p1 = Factory.create(:post)
      p2 = Factory.create(:post)
      p3 = Factory.create(:post)
      p4 = Factory.create(:post)
      pool.add_post!(p1)
      pool.add_post!(p2)
      pool.add_post!(p3)
      pool.reload
      
      assert_equal("#{p1.id} #{p2.id} #{p3.id}", pool.post_ids)
      assert_equal([p1.id, p2.id, p3.id], pool.post_id_array)
      posts = pool.posts.all
      assert_equal(3, posts.size)
      assert_equal([p1.id, p2.id, p3.id], posts.map(&:id))
      posts = pool.posts.limit(1).offset(1).all
      assert_equal(1, posts.size)
      assert_equal([p2.id], posts.map(&:id))
    end
    
    should "return the neighboring posts for any member element" do
      pool = Factory.create(:pool)
      p1 = Factory.create(:post)
      p2 = Factory.create(:post)
      p3 = Factory.create(:post)
      pool.add_post!(p1)
      pool.add_post!(p2)
      pool.add_post!(p3)

      pool.reload
      neighbors = pool.neighbor_posts(p1)
      assert_nil(neighbors.previous)
      assert_equal(p2.id, neighbors.next)

      pool.reload
      neighbors = pool.neighbor_posts(p2)
      assert_equal(p1.id, neighbors.previous)
      assert_equal(p3.id, neighbors.next)

      pool.reload
      neighbors = pool.neighbor_posts(p3)
      assert_equal(p2.id, neighbors.previous)
      assert_nil(neighbors.next)
    end
    
    should "know what its post_ids were" do
      p1 = Factory.create(:post)
      p2 = Factory.create(:post)
      pool = Factory.create(:pool, :post_ids => "#{p1.id}")
      pool.post_id_array = [p1.id, p2.id]
      assert_equal([p1.id], pool.post_id_array_was)
    end
    
    should "update its posts if the post_ids is updated directly" do
      p1 = Factory.create(:post)
      p2 = Factory.create(:post)
      pool = Factory.create(:pool, :post_ids => "#{p1.id}")
      pool.post_id_array = [p1.id, p2.id]
      pool.save
      p1.reload
      p2.reload
      assert_equal("pool:#{pool.id}", p1.pool_string)
      assert_equal("pool:#{pool.id}", p2.pool_string)
    end
    
    should "set its post count even if post_ids is updated directly" do
      p1 = Factory.create(:post)
      p2 = Factory.create(:post)
      pool = Factory.create(:pool, :post_ids => "#{p1.id}")
      pool.post_id_array = [p1.id, p2.id]
      pool.save
      assert_equal(2, pool.post_count)
    end
    
    should "increment the post count every time a post is added" do
      p1 = Factory.create(:post)
      pool = Factory.create(:pool)
      pool.add_post!(p1)
      assert_equal(1, pool.post_count)
    end
    
    should "not double increment when the same post is readded" do
      p1 = Factory.create(:post)
      pool = Factory.create(:pool)
      pool.add_post!(p1)
      pool.add_post!(p1)
      assert_equal(1, pool.post_count)
    end
    
    should "not double decrement" do
      p1 = Factory.create(:post)
      pool = Factory.create(:pool)
      pool.remove_post!(p1)
      assert_equal(0, pool.post_count)
    end
  end
  
  context "An anonymous pool" do
    should "have a name starting with anonymous" do
      user = Factory.create(:user)
      pool = Pool.create_anonymous(user, "127.0.0.1")
      assert_match(/^anonymous:\d+$/, pool.name)
    end
  end
end
