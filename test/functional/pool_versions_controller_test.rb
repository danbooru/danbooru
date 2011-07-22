require 'test_helper'

class PoolVersionsControllerTest < ActionController::TestCase
  context "The pool versions controller" do
    setup do
      @user = Factory.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    context "index action" do
      setup do
        @pool = Factory.create(:pool)
        @user_2 = Factory.create(:user)
        @user_3 = Factory.create(:user)
        
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
        get :index, {:search => {:updater_id_equals => @user_2.id}}
        assert_response :success
        assert_not_nil(assigns(:pool_versions))
        assert_equal(1, assigns(:pool_versions).size)
      end
    end
  end
end
