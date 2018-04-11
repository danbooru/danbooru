require 'test_helper'

class BulkUpdateRequestsControllerTest < ActionDispatch::IntegrationTest
  context "BulkUpdateRequestsController" do
    setup do
      @user = create(:user)
      @admin = create(:admin_user)
    end

    context "#new" do
      should "render" do
        get_auth bulk_update_requests_path, @user
        assert_response :success
      end
    end

    context "#create" do
      should "succeed" do
        assert_difference("BulkUpdateRequest.count", 1) do
          post_auth bulk_update_requests_path, @user, params: {bulk_update_request: {skip_secondary_validations: "1", script: "create alias aaa -> bbb", title: "xxx"}}
        end
      end
    end

    context "#update" do
      setup do
        as_user do
          @bulk_update_request = create(:bulk_update_request)
        end
      end

      should "still handle enabled secondary validations correctly" do
        put_auth bulk_update_request_path(@bulk_update_request.id), @user, params: {bulk_update_request: {script: "create alias zzz -> 222", skip_secondary_validations: "0"}}
        @bulk_update_request.reload
        assert_equal("create alias zzz -> 222", @bulk_update_request.script)
      end

      should "still handle disabled secondary validations correctly" do
        put_auth bulk_update_request_path(@bulk_update_request.id), @user, params: {bulk_update_request: {script: "create alias zzz -> 222", skip_secondary_validations: "1"}}
        @bulk_update_request.reload
        assert_equal("create alias zzz -> 222", @bulk_update_request.script)
      end
    end

    context "#index" do
      setup do
        as_user do
          @bulk_update_request = create(:bulk_update_request)
        end
      end

      should "render" do
        get bulk_update_requests_path
        assert_response :success
      end
    end

    context "#destroy" do
      setup do
        as_user do
          @bulk_update_request = create(:bulk_update_request)
        end
      end

      context "for the creator" do
        should "succeed" do
          delete_auth bulk_update_request_path(@bulk_update_request), @user
          @bulk_update_request.reload
          assert_equal("rejected", @bulk_update_request.status)
        end
      end

      context "for another member" do
        setup do
          @another_user = create(:user)
        end

        should "fail" do
          assert_difference("BulkUpdateRequest.count", 0) do
            delete_auth bulk_update_request_path(@bulk_update_request), @another_user
          end
        end
      end

      context "for an admin" do
        should "succeed" do
          delete_auth bulk_update_request_path(@bulk_update_request), @admin
          @bulk_update_request.reload
          assert_equal("rejected", @bulk_update_request.status)
        end
      end
    end

    context "#approve" do
      setup do
        as_user do
          @bulk_update_request = create(:bulk_update_request)
        end
      end

      context "for a member" do
        should "fail" do
          post_auth approve_bulk_update_request_path(@bulk_update_request), @user
          @bulk_update_request.reload
          assert_equal("pending", @bulk_update_request.status)
        end
      end

      context "for an admin" do
        should "succeed" do
          post_auth approve_bulk_update_request_path(@bulk_update_request), @admin
          @bulk_update_request.reload
          assert_equal("approved", @bulk_update_request.status)
        end
      end
    end
  end
end
