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
      end
      
      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end
      
      context "a post pool set for page 2" do
        setup do
          @set = PostSets::Base.new(:id => @pool.id, :page => 2)
          @set.stubs(:limit).returns(1)
          @set.extend(PostSets::Pool)
        end

        context "a numbered paginator" do
          setup do
            @set.extend(PostSets::Numbered)
          end

          should "return the second element" do
            assert_equal(1, @set.posts.size)
            assert_equal(@post_1.id, @set.posts.first.id)
          end
        end
      end
      
      context "a post pool set with no page specified" do
        setup do
          @set = PostSets::Base.new(:id => @pool.id)
          @set.stubs(:limit).returns(1)
          @set.extend(PostSets::Pool)
        end

        context "a numbered paginator" do
          setup do
            @set.extend(PostSets::Numbered)
          end

          should "return the first element" do
            assert_equal(3, @set.count)
            assert_equal(1, @set.posts.size)
            assert_equal(@post_2.id, @set.posts.first.id)
          end
        end
      end
    end
  end
end
