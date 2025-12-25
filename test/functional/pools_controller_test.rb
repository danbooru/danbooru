require 'test_helper'

class PoolsControllerTest < ActionDispatch::IntegrationTest
  context "The pools controller" do
    setup do
      @user = create(:user, created_at: 1.month.ago)
      @mod = create(:moderator_user, created_at: 1.month.ago)

      as(@user) do
        @post = create(:post)
        @pool = create(:pool, name: "Beautiful Smile", description: "[[touhou]]")
      end
    end

    context "index action" do
      should "list all pools" do
        get pools_path
        assert_response :success
      end

      should "render for a sitemap" do
        get pools_path(format: :sitemap)

        assert_response :success
        assert_equal(Pool.count, response.parsed_body.css("urlset url loc").size)
      end

      should respond_to_search(name_contains: "eautiful").with { @pool }
      should respond_to_search(name_contains: "beautiful smile").with { @pool }
      should respond_to_search(name_contains: "smiling beauty").with { [] }
      should respond_to_search(name_matches: "eautiful").with { [] }
      should respond_to_search(name_matches: "beautiful smile").with { @pool }
      should respond_to_search(name_matches: "smiling beauty").with { @pool }
      should respond_to_search(linked_to: "touhou").with { @pool }
      should respond_to_search(not_linked_to: "touhou").with { [] }
    end

    context "show action" do
      should "render" do
        get pool_path(@pool)
        assert_response :success
      end
    end

    context "gallery action" do
      should "render" do
        get gallery_pools_path
        assert_response :success
      end
    end

    context "new action" do
      should "render" do
        get_auth new_pool_path, @user
        assert_response :success
      end
    end

    context "create action" do
      should "create a pool" do
        post_auth pools_path, @user, params: { pool: { name: "xxx", description: "abc"}}

        assert_redirected_to Pool.last
        assert_equal(true, Pool.exists?(name: "xxx", description: "abc"))
        assert_equal("Pool created", flash[:notice])
      end
    end

    context "edit action" do
      should "render" do
        get_auth edit_pool_path(@pool), @user
        assert_response :success
      end
    end

    context "update action" do
      should "update a pool" do
        put_auth pool_path(@pool), @user, params: { pool: { name: "xyz", post_ids: [@post.id] }}

        assert_redirected_to @pool
        assert_equal("xyz", @pool.reload.name)
        assert_equal([@post.id], @pool.post_ids)
        assert_equal("Pool updated", flash[:notice])
      end

      should "not allow updating unpermitted attributes" do
        put_auth pool_path(@pool), @user, params: { pool: { is_deleted: true, post_count: -42 }}

        assert_response 403
        assert_equal(false, @pool.reload.is_deleted?)
        assert_equal(0, @pool.post_count)
      end
    end

    context "destroy action" do
      should "soft delete a pool" do
        delete_auth pool_path(@pool), @mod

        assert_redirected_to @pool
        assert_equal(true, @pool.reload.is_deleted?)
        assert_equal("Pool deleted", flash[:notice])
      end
    end

    context "undelete action" do
      should "restore a pool" do
        @pool = as(@mod) { create(:pool, is_deleted: true) }
        post_auth undelete_pool_path(@pool), @mod

        assert_redirected_to @pool
        assert_equal(false, @pool.reload.is_deleted?)
        assert_equal("Pool undeleted", flash[:notice])
      end
    end

    context "revert action" do
      setup do
        @post_2 = as(@user) { create(:post) }
        @pool = as(@user) { create(:pool, post_ids: [@post.id]) }
        as(@mod) { @pool.update!(post_ids: [@post.id, @post_2.id]) }
      end

      should "revert to a previous version" do
        put_auth revert_pool_path(@pool), @mod, params: { version_id: @pool.versions.first.id }

        assert_redirected_to @pool
        assert_equal([@post.id], @pool.reload.post_ids)
        assert_equal("Pool reverted", flash[:notice])
      end

      should "not allow reverting to a previous version of another pool" do
        @pool2 = as(@user) { create(:pool) }
        put_auth revert_pool_path(@pool), @user, params: {:version_id => @pool2.versions.first.id }

        assert_response 404
        assert_not_equal(@pool.reload.name, @pool2.name)
        assert_nil(flash[:notice])
      end
    end
  end
end
