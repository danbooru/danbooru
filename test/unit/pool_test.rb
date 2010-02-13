require File.dirname(__FILE__) + '/../test_helper'

class PoolTest < ActiveSupport::TestCase
  context "A pool" do
    should "create versions for each distinct user" do
      pool = Factory.create(:pool)
      user = Factory.create(:user)
      assert_equal(1, pool.versions(true).size)
      pool.update_attributes(:post_ids => "1", :updater_id => user.id, :updater_ip_addr => "128.0.0.1")
      assert_equal(2, pool.versions(true).size)
      pool.update_attributes(:post_ids => "1 2", :updater_id => user.id, :updater_ip_addr => "128.0.0.1")
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
      p1.add_pool(pool)
      p2.add_pool(pool)
      p3.add_pool(pool)
      
      assert_equal("#{p1.id} #{p2.id} #{p3.id}", pool.post_ids)
      assert_equal([p1.id, p2.id, p3.id], pool.post_id_array)
      posts = pool.posts.all
      assert_equal(3, posts.size)
      assert_equal([p1.id, p2.id, p3.id], posts.map(&:id))
      posts = pool.posts(:limit => 1, :offset => 1).all
      assert_equal(1, posts.size)
      assert_equal([p2.id], posts.map(&:id))
    end
    
    should "return the neighboring posts for any member element" do
      pool = Factory.create(:pool)
      p1 = Factory.create(:post)
      p2 = Factory.create(:post)
      p3 = Factory.create(:post)
      p1.add_pool(pool)
      p2.add_pool(pool)
      p3.add_pool(pool)
      neighbors = pool.neighbor_posts(p1)
      assert_nil(neighbors[:previous])
      assert_equal(p2.id, neighbors[:next])
      neighbors = pool.neighbor_posts(p2)
      assert_equal(p1.id, neighbors[:previous])
      assert_equal(p3.id, neighbors[:next])
      neighbors = pool.neighbor_posts(p3)
      assert_equal(p2.id, neighbors[:previous])
      assert_nil(neighbors[:next])
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
