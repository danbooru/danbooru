require 'test_helper'

class PoolsControllerTest < ActionController::TestCase
  context "The pools controller" do
    setup do
      @user = Factory.create(:user)
      @mod = Factory.create(:moderator_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @post = Factory.create(:post)
    end
    
    teardown do
      CurrentUser.user = nil
    end
    
    context "index action" do
      setup do
        Factory.create(:pool, :name => "abc")
      end
      
      should "list all pools" do
        get :index
        assert_response :success
      end
      
      should "list all pools (with search)" do
        get :index, {:search => {:name_matches => "abc"}}
        assert_response :success
      end
    end
    
    context "show action" do
      setup do
        @pool = Factory.create(:pool)
      end
      
      should "render" do
        get :show, {:id => @pool.id}
        assert_response :success
      end
    end
    
    context "create action" do
      should "create a pool" do
        assert_difference("Pool.count", 1) do
          post :create, {:pool => {:name => "xxx", :description => "abc"}}, {:user_id => @user.id}
        end
      end
    end
    
    context "update action" do
      setup do
        @pool = Factory.create(:pool)
      end
      
      should "update a pool" do
        post :update, {:id => @pool.id, :pool => {:name => "xyz"}}, {:user_id => @user.id}
        @pool.reload
        assert_equal("xyz", @pool.name)
      end
    end
    
    context "destroy action" do
      setup do
        @pool = Factory.create(:pool)
      end
      
      should "destroy a pool" do
        assert_difference("Pool.count", -1) do
          post :destroy, {:id => @pool.id}, {:user_id => @mod.id}
        end
      end
    end
    
    context "revert action" do
      setup do
        @pool = Factory.create(:pool, :name => "000")
        @pool.update_attributes(:name => "111")
        @pool.update_attributes(:name => "222")
      end
      
      should "revert to a previous version" do
        post :revert, {:id => @pool.id, :version_id => @pool.versions(true).first.id}
        @pool.reload
        assert_equal("000", @pool.name)
      end
    end
  end
end
