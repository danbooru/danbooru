require 'test_helper'

class PoolElementsControllerTest < ActionDispatch::IntegrationTest
  context "The pools posts controller" do
    setup do
      mock_pool_archive_service!
      start_pool_archive_transaction
      @user = travel_to(1.month.ago) {create(:user)}
      @mod = create(:moderator_user)
      as_user do
        @post = create(:post)
        @pool = create(:pool, :name => "abc")
      end
    end

    teardown do
      rollback_pool_archive_transaction
    end

    context "create action" do
      should "add a post to a pool" do
        post_auth pool_element_path, @user, params: {:pool_id => @pool.id, :post_id => @post.id, :format => "json"}
        @pool.reload
        assert_equal([@post.id], @pool.post_id_array)
      end

      should "add a post to a pool once and only once" do
        @pool.add!(@post)
        post_auth pool_element_path, @user, params: {:pool_id => @pool.id, :post_id => @post.id, :format => "json"}
        @pool.reload
        assert_equal([@post.id], @pool.post_id_array)
      end
    end

    context "destroy action" do
      setup do
        @pool.add!(@post)
      end

      should "remove a post from a pool" do
        delete_auth pool_element_path, @user, params: {:pool_id => @pool.id, :post_id => @post.id, :format => "json"}
        @pool.reload
        assert_equal([], @pool.post_id_array)
      end

      should "do nothing if the post is not a member of the pool" do
        @pool.reload
        as_user do
          @pool.remove!(@post)
        end
        delete_auth pool_element_path, @user, params: {:pool_id => @pool.id, :post_id => @post.id, :format => "json"}
        @pool.reload
        assert_equal([], @pool.post_id_array)
      end
    end
  end
end
