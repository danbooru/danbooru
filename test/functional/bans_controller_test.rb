require 'test_helper'

class BansControllerTest < ActionController::TestCase
  context "A bans controller" do
    setup do
      CurrentUser.user = Factory.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
      @ban = Factory.create(:ban)
      @user = Factory.create(:moderator_user)
    end
    
    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end
    
    should "render the new page" do
      get :new, {}, {:user_id => @user.id}
      assert_response :success
    end
    
    should "render the edit page" do
      get :edit, {:id => @ban.id}, {:user_id => @user.id}
      assert_response :success
    end
    
    should "render the show page" do
      get :show, {:id => @ban.id}
      assert_response :success
    end
    
    should "render the index page" do
      get :index
      assert_response :success
    end
    
    should "create a ban" do
      assert_difference("Ban.count", 1) do
        post :create, {:ban => Factory.attributes_for(:ban)}, {:user_id => @user.id}
      end
      ban = Ban.last
      assert_redirected_to(ban_path(ban))
    end
    
    should "update a ban" do
      post :update, {:id => @ban.id, :ban => {:reason => "xxx"}}, {:user_id => @user.id}
      ban = Ban.last
      assert_equal("xxx", ban.reason)
      assert_redirected_to(ban_path(ban))
    end
    
    should "destroy a ban" do
      assert_difference("Ban.count", -1) do
        post :destroy, {:id => @ban.id}, {:user_id => @user.id}
      end
      assert_redirected_to(bans_path)
    end
  end
end
