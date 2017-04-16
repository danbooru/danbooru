require 'test_helper'

module Moderator
  class IpAddrsControllerTest < ActionController::TestCase
    context "The ip addrs controller" do
      setup do
        @user = FactoryGirl.create(:moderator_user)
        CurrentUser.user = @user
        CurrentUser.ip_addr = "127.0.0.1"
        FactoryGirl.create(:comment)
      end

      should "find by ip addr" do
        get :index, {:search => {:ip_addr => "127.0.0.1"}}, {:user_id => @user.id}
        assert_response :success
      end

      should "find by user id" do
        get :index, {:search => {:user_id => @user.id.to_s}}, {:user_id => @user.id}
        assert_response :success
      end

      should "find by user name" do
        get :index, {:search => {:user_name => @user.name}}, {:user_id => @user.id}
        assert_response :success
      end

      should "render the search page" do
        get :search, {}, {:user_id => @user.id}
        assert_response :success
      end
    end
  end
end
