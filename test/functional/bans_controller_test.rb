require 'test_helper'

class BansControllerTest < ActionController::TestCase
  context "A bans controller" do
    setup do
      @mod = FactoryGirl.create(:moderator_user)
      CurrentUser.user = @mod
      CurrentUser.ip_addr = "127.0.0.1"
      @user = FactoryGirl.create(:user)
      @ban = FactoryGirl.create(:ban, :user_id => @user.id)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    should "get the new page" do
      get :new, {}, {:user_id => @mod.id}
      assert_response :success
    end

    should "get the edit page" do
      get :edit, {:id => @ban.id}, {:user_id => @mod.id}
      assert_response :success
    end

    should "get the show page" do
      get :show, {:id => @ban.id}
      assert_response :success
    end

    should "get the index page" do
      get :index
      assert_response :success
    end

    should "create a ban" do
      assert_difference("Ban.count", 1) do
        post :create, {:ban => {:duration => 60, :reason => "xxx", :user_id => @user.id}}, {:user_id => @mod.id}
      end
      ban = Ban.last
      assert_redirected_to(ban_path(ban))
    end

    should "update a ban" do
      post :update, {:id => @ban.id, :ban => {:reason => "xxx", :duration => 60}}, {:user_id => @mod.id}
      @ban.reload
      assert_equal("xxx", @ban.reason)
      assert_redirected_to(ban_path(@ban))
    end

    should "destroy a ban" do
      assert_difference("Ban.count", -1) do
        post :destroy, {:id => @ban.id}, {:user_id => @mod.id}
      end
      assert_redirected_to(bans_path)
    end
  end
end
