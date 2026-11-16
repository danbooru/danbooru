require "test_helper"

class PoolVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The pool versions controller" do
    setup do
      @user = create(:user)
    end

    context "index action" do
      should "return 422 for a post_id param that isn't a string or integer" do
        get pool_versions_path, params: { search: { post_id: ["1"] }}, as: :json
        assert_response 422
        assert_equal("post_id must be an integer", response.parsed_body["message"])
      end

      should "return nothing for post IDs that are too large" do
        get pool_versions_path, params: { search: { post_id: "2147483648" }}, as: :json
        assert_response :success
        assert_equal([], response.parsed_body)

        get pool_versions_path, params: { search: { post_id: "99999999999999999999" }}, as: :json
        assert_response :success
        assert_equal([], response.parsed_body)
      end

      setup do
        @pool = as(@user) { create(:pool) }
        @user2 = create(:user)
        @user3 = create(:user)

        as(@user2) { @pool.update(post_ids: "1 2") }
        as(@user3) { @pool.update(post_ids: "1 2 3 4") }

        @versions = @pool.versions
      end

      should "list all versions" do
        get pool_versions_path
        assert_response :success
        assert_select "#pool-version-#{@versions[0].id}"
        assert_select "#pool-version-#{@versions[1].id}"
        assert_select "#pool-version-#{@versions[2].id}"
      end

      should "list all versions that match the search criteria" do
        get pool_versions_path, params: { search: { updater_id: @user2.id }}
        assert_response :success
        assert_select "#pool-version-#{@versions[0].id}", false
        assert_select "#pool-version-#{@versions[1].id}"
        assert_select "#pool-version-#{@versions[2].id}", false
      end

      should "show reordered posts as a change" do
        as(@user) { @pool.update!(post_ids: "4 3 2 1") }
        version = @pool.versions.last

        get pool_versions_path, params: { search: { pool_id: @pool.id }}
        assert_response :success
        assert_select "#pool-version-#{version.id} .version-statuses", text: /Posts/
      end
    end

    context "diff action" do
      should "render" do
        @post = as(@user) { create(:post) }
        @pool = as(@user) { create(:pool) }
        as(@user) { @pool.update(name: "blah", description: "desc", post_ids: [@post.id]) }

        get diff_pool_version_path(@pool.versions.last.id)
        assert_response :success
      end
    end
  end
end
