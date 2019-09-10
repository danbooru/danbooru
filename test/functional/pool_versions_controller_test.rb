require 'test_helper'

class PoolVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The pool versions controller" do
    setup do
      mock_pool_archive_service!
      start_pool_archive_transaction
      @user = create(:user)
    end

    teardown do
      rollback_pool_archive_transaction
    end

    context "index action" do
      setup do
        as_user do
          @pool = create(:pool)
        end
        @user_2 = create(:user)
        @user_3 = create(:user)

        CurrentUser.scoped(@user_2, "1.2.3.4") do
          @pool.update(:post_ids => "1 2")
        end

        CurrentUser.scoped(@user_3, "5.6.7.8") do
          @pool.update(:post_ids => "1 2 3 4")
        end

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
        @post = create(:post)
        @pool = as (@user) { create(:pool) }
        as (@user) { @pool.update(name: "blah", description: "desc", post_ids: [@post.id]) }

        get diff_pool_version_path(@pool.versions.last.id)
        assert_response :success
      end
    end
  end
end
