require 'test_helper'

class UserNameChangeRequestsControllerTest < ActionController::TestCase
  context "The user name change requests controller" do
    setup do
      @user = FactoryGirl.create(:privileged_user)
      @admin = FactoryGirl.create(:admin_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      @change_request = UserNameChangeRequest.create!(
        :user_id => @user.id,
        :original_name => @user.name,
        :desired_name => "abc",
        :change_reason => "hello"
      )
    end
    
    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end
    
    context "show action" do
      should "render" do
        get :show, {:id => @change_request.id}, {:user_id => @user.id}
        assert_response :success
      end
    end
    
    context "for actions restricted to admins" do
      context "index action" do
        should "render" do
          get :index, {}, {:user_id => @admin.id}
          assert_response :success
        end
      end
      
      context "approve action" do
        should "succeed" do
          post :approve, {:id => @change_request.id}, {:user_id => @admin.id}
          assert_redirected_to(user_name_change_request_path(@change_request))
        end
      end
      
      context "reject action" do
        should "succeed" do
          post :reject, {:id => @change_request.id}, {:user_id => @admin.id}
          assert_redirected_to(user_name_change_request_path(@change_request))
        end
      end
      
      context "destroy action" do
        should "destroy" do
          post :destroy, {:id => @change_request.id}, {:user_id => @admin.id}
          assert_redirected_to(user_name_change_requests_path)
        end
      end
    end
  end
end
