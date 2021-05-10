require 'test_helper'

class PoolVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The pool versions controller" do
    setup do
      @user = create(:user)
    end

    context "index action" do
      setup do
        @pool = as(@user) { create(:pool) }
        @user_2 = create(:user)
        @user_3 = create(:user)

        as(@user_2) { @pool.update(post_ids: "1 2") }
        as(@user_3) { @pool.update(post_ids: "1 2 3 4") }

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
        get pool_versions_path, params: {:search => {:updater_id => @user_2.id}}
        assert_response :success
        assert_select "#pool-version-#{@versions[0].id}", false
        assert_select "#pool-version-#{@versions[1].id}"
        assert_select "#pool-version-#{@versions[2].id}", false
      end
    end

    context "diff action" do
      should "render" do
        @post = as(@user) { create(:post) }
        @pool = as(@user) { create(:pool) }
        as (@user) { @pool.update(name: "blah", description: "desc", post_ids: [@post.id]) }

        get diff_pool_version_path(@pool.versions.last.id)
        assert_response :success
      end
    end
  end
end
