require 'test_helper'
require 'helpers/pool_archive_test_helper'

class PoolVersionsControllerTest < ActionController::TestCase
  include PoolArchiveTestHelper

  context "The pool versions controller" do
    setup do
      mock_pool_archive_service!
      start_pool_archive_transaction
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      rollback_pool_archive_transaction
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "index action" do
      setup do
        @pool = FactoryGirl.create(:pool)
        @user_2 = FactoryGirl.create(:user)
        @user_3 = FactoryGirl.create(:user)

        CurrentUser.scoped(@user_2, "1.2.3.4") do
          @pool.update_attributes(:post_ids => "1 2")
        end

        CurrentUser.scoped(@user_3, "5.6.7.8") do
          @pool.update_attributes(:post_ids => "1 2 3 4")
        end
      end

      should "list all versions" do
        get :index
        assert_response :success
        assert_not_nil(assigns(:pool_versions))
        assert_equal(3, assigns(:pool_versions).size)
      end

      should "list all versions that match the search criteria" do
        get :index, {:search => {:updater_id => @user_2.id}}
        assert_response :success
        assert_not_nil(assigns(:pool_versions))
        assert_equal(1, assigns(:pool_versions).size)
      end
    end
  end
end
