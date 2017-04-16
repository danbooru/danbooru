require 'test_helper'
require 'helpers/pool_archive_test_helper'

module PostSets
  class PoolTest < ActiveSupport::TestCase
    include PoolArchiveTestHelper

    context "In all cases" do
      setup do
        @user = FactoryGirl.create(:user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"

        mock_pool_archive_service!
        start_pool_archive_transaction

        @post_1 = FactoryGirl.create(:post)
        @post_2 = FactoryGirl.create(:post)
        @post_3 = FactoryGirl.create(:post)
        @pool = FactoryGirl.create(:pool)
        @pool.add!(@post_2)
        @pool.add!(@post_1)
        @pool.add!(@post_3)
      end

      teardown do
        rollback_pool_archive_transaction
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      context "a post pool set for page 2" do
        setup do
          @set = PostSets::Pool.new(@pool, 2)
          @set.stubs(:limit).returns(1)
        end

        should "return the second element" do
          assert_equal(1, @set.posts.size)
          assert_equal(@post_1.id, @set.posts.first.id)
        end

        should "know the total number of pages" do
          assert_equal(3, @set.total_pages)
        end

        should "know the current page" do
          assert_equal(2, @set.current_page)
        end
      end

      context "a post pool set with no page specified" do
        setup do
          @set = PostSets::Pool.new(@pool)
          @set.stubs(:limit).returns(1)
        end

        should "return the first element" do
          assert_equal(1, @set.posts.size)
          assert_equal(@post_2.id, @set.posts.first.id)
        end
      end
    end
  end
end
