require 'test_helper'

class BulkUpdateRequestsControllerTest < ActionController::TestCase
  context "BulkUpdateRequestsController" do
    setup do
      @user = FactoryGirl.create(:user)
      @admin = FactoryGirl.create(:admin_user)
    end

    context "#new" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "#create" do
      should "succeed" do
        assert_difference("BulkUpdateRequest.count", 1) do
          post :create, {:bulk_update_request => {:script => "create alias aaa -> bbb"}}, {:user_id => @user.id}
        end
      end
    end

    context "#index" do
      setup do
        @bulk_update_request = FactoryGirl.create(:bulk_update_request, :user_id => @admin.id)
      end

      should "render" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "#update" do
      setup do
        @bulk_update_request = FactoryGirl.create(:bulk_update_request, :user_id => @admin.id)
      end

      context "for a member" do
        should "fail" do
          post :update, {:status => "approved", :id => @bulk_update_request.id}, {:user_id => @user.id}
          @bulk_update_request.reload
          assert_equal("pending", @bulk_update_request.status)
        end
      end

      context "for an admin" do
        should "succeed" do
          post :update, {:status => "approved", :id => @bulk_update_request.id}, {:user_id => @admin.id}
          @bulk_update_request.reload
          assert_equal("approved", @bulk_update_request.status)
        end
      end
    end
  end
end
