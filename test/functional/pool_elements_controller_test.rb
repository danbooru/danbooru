require "test_helper"

class PoolElementsControllerTest < ActionDispatch::IntegrationTest
  context "The pools posts controller" do
    setup do
      @user = travel_to(1.month.ago) { create(:user) }
      @mod = create(:moderator_user)
      as(@user) do
        @post = create(:post)
        @pool = create(:pool, name: "abc")
      end
    end

    context "create action" do
      should "return 400 for a post_id param that isn't a string or integer" do
        post_auth pool_element_path, @user, params: { pool_id: @pool.id, post_id: [@post.id] }, as: :json
        assert_response 400
        assert_equal([], @pool.reload.post_ids)
      end

      should "return 400 for a pool_name param that isn't a string" do
        post_auth pool_element_path, @user, params: { pool_name: [@pool.name], post_id: @post.id }, as: :json
        assert_response 400
      end

      should "add a post to a pool" do
        post_auth pool_element_path, @user, params: { pool_id: @pool.id, post_id: @post.id, format: "json" }
        assert_response :success
        assert_equal([@post.id], @pool.reload.post_ids)
      end

      should "work with only=" do
        post_auth pool_element_path, @user, params: { pool_id: @pool.id, post_id: @post.id, only: "id,name", format: "json" }
        assert_response :success
        assert_equal({ "id" => @pool.id, "name" => "abc" }, response.parsed_body)
      end

      should "add a post to a pool once and only once" do
        as(@user) { @pool.add!(@post) }
        post_auth pool_element_path, @user, params: { pool_id: @pool.id, post_id: @post.id, format: "json" }
        assert_response :success
        assert_equal([@post.id], @pool.reload.post_ids)
      end
    end
  end
end
