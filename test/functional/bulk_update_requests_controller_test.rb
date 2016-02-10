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
          post :create, {:bulk_update_request => {:skip_secondary_validations => "1", :script => "create alias aaa -> bbb", :title => "xxx"}}, {:user_id => @user.id}
        end
      end
    end

    context "#update" do
      setup do
        CurrentUser.scoped(@user) do
          @bulk_update_request = FactoryGirl.create(:bulk_update_request)
        end
      end

      should "still handle enabled secondary validations correctly" do
        post :update, {:id => @bulk_update_request.id, :bulk_update_request => {:script => "create alias zzz -> 222", :skip_secondary_validations => "0"}}, {:user_id => @user.id}
        @bulk_update_request.reload
        assert_equal("create alias aaa -> bbb", @bulk_update_request.script)
      end

      should "still handle disabled secondary validations correctly" do
        post :update, {:id => @bulk_update_request.id, :bulk_update_request => {:script => "create alias zzz -> 222", :skip_secondary_validations => "1"}}, {:user_id => @user.id}
        @bulk_update_request.reload
        assert_equal("create alias zzz -> 222", @bulk_update_request.script)
      end
    end

    context "#index" do
      setup do
        CurrentUser.scoped(@user) do
          @bulk_update_request = FactoryGirl.create(:bulk_update_request)
        end
      end

      should "render" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "#destroy" do
      setup do
        CurrentUser.scoped(@user) do
          @bulk_update_request = FactoryGirl.create(:bulk_update_request)
        end
      end

      context "for the creator" do
        should "succeed" do
          delete :destroy, {:id => @bulk_update_request.id}, {:user_id => @user.id}
          @bulk_update_request.reload
          assert_equal("rejected", @bulk_update_request.status)
        end
      end

      context "for another member" do
        setup do
          @another_user = FactoryGirl.create(:user)
        end

        should "fail" do
          assert_difference("BulkUpdateRequest.count", 0) do
            delete :destroy, {:id => @bulk_update_request.id}, {:user_id => @another_user.id}
          end
        end
      end

      context "for an admin" do
        should "succeed" do
          delete :destroy, {:id => @bulk_update_request.id}, {:user_id => @admin.id}
          @bulk_update_request.reload
          assert_equal("rejected", @bulk_update_request.status)
        end
      end
    end

    context "#approve" do
      setup do
        CurrentUser.scoped(@user) do
          @bulk_update_request = FactoryGirl.create(:bulk_update_request)
        end
      end

      context "for a member" do
        should "fail" do
          post :approve, {:id => @bulk_update_request.id}, {:user_id => @user.id}
          @bulk_update_request.reload
          assert_equal("pending", @bulk_update_request.status)
        end
      end

      context "for an admin" do
        should "succeed" do
          post :approve, {:id => @bulk_update_request.id}, {:user_id => @admin.id}
          @bulk_update_request.reload
          assert_equal("approved", @bulk_update_request.status)
        end
      end
    end
  end
end
