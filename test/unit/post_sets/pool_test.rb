require_relative '../../test_helper'

module PostSets
  class PoolTest < ActiveSupport::TestCase
    context "In all cases" do
      setup do
        @user = Factory.create(:user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        MEMCACHE.flush_all

        @post_1 = Factory.create(:post)
        @post_2 = Factory.create(:post)
        @post_3 = Factory.create(:post)
        @pool = Factory.create(:pool)
        @pool.add_post!(@post_2)
        @pool.add_post!(@post_1)
        @pool.add_post!(@post_3)
        @post_2.add_pool(@pool)
        @post_1.add_pool(@pool)
        @post_3.add_pool(@pool)
        @set = PostSets::Pool.new(@pool, :page => 1)
      end
      
      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end
      
      context "a pool with three posts" do
        should "by default sort the posts by id" do
          assert_equal([@post_1.id, @post_2.id, @post_3.id], @set.posts.map(&:id))
        end
        
        should "be capable of sorting by pool sequence" do
          assert_equal([@post_2.id, @post_1.id, @post_3.id], @set.sorted_posts.map(&:id))
        end
      end
    end
  end
end
