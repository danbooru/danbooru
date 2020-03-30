require 'test_helper'

class BulkUpdateRequestsControllerTest < ActionDispatch::IntegrationTest
  context "BulkUpdateRequestsController" do
    setup do
      @user = create(:user)
      @admin = create(:admin_user)
      @bulk_update_request = create(:bulk_update_request, user: @user)
    end

    context "#new" do
      should "render" do
        get_auth new_bulk_update_request_path, @user
        assert_response :success
      end
    end

    context "#edit" do
      should "render" do
        get_auth edit_bulk_update_request_path(@bulk_update_request), @user
        assert_response :success
      end
    end

    context "#create" do
      should "succeed" do
        assert_difference("BulkUpdateRequest.count", 1) do
          post_auth bulk_update_requests_path, @user, params: {bulk_update_request: {skip_secondary_validations: "1", script: "create alias aaa -> bbb", title: "xxx"}}
          assert_response :redirect
        end
      end
    end

    context "#update" do
      should "still handle enabled secondary validations correctly" do
        put_auth bulk_update_request_path(@bulk_update_request.id), @user, params: {bulk_update_request: {script: "create alias zzz -> 222", skip_secondary_validations: "0"}}
        assert_response :redirect
        assert_equal("create alias zzz -> 222", @bulk_update_request.reload.script)
      end

      should "still handle disabled secondary validations correctly" do
        put_auth bulk_update_request_path(@bulk_update_request.id), @user, params: {bulk_update_request: {script: "create alias zzz -> 222", skip_secondary_validations: "1"}}
        assert_response :redirect
        assert_equal("create alias zzz -> 222", @bulk_update_request.reload.script)
      end

      should "allow builders to update other people's requests" do
        put_auth bulk_update_request_path(@bulk_update_request.id), create(:builder_user), params: {bulk_update_request: {script: "create alias zzz -> 222", skip_secondary_validations: "0"}}
        assert_response :redirect
        assert_equal("create alias zzz -> 222", @bulk_update_request.reload.script)
      end

      should "not allow members to update other people's requests" do
        put_auth bulk_update_request_path(@bulk_update_request.id), create(:user), params: {bulk_update_request: {script: "create alias zzz -> 222", skip_secondary_validations: "0"}}
        assert_response 403
        assert_equal("create alias aaa -> bbb", @bulk_update_request.reload.script)
      end
    end

    context "#index" do
      should "render" do
        get bulk_update_requests_path
        assert_response :success
      end
    end

    context "#show" do
      should "render" do
        get bulk_update_request_path(@bulk_update_request)
        assert_response :success
      end
    end

    context "#destroy" do
      context "for the creator" do
        should "succeed" do
          delete_auth bulk_update_request_path(@bulk_update_request), @user
          assert_response :redirect
          assert_equal("rejected", @bulk_update_request.reload.status)
        end
      end

      context "for another member" do
        should "fail" do
          assert_difference("BulkUpdateRequest.count", 0) do
            delete_auth bulk_update_request_path(@bulk_update_request), create(:user)
            assert_response 403
          end
        end
      end

      context "for an admin" do
        should "succeed" do
          delete_auth bulk_update_request_path(@bulk_update_request), @admin
          assert_response :redirect
          assert_equal("rejected", @bulk_update_request.reload.status)
        end
      end
    end

    context "#approve" do
      context "for a member" do
        should "fail" do
          post_auth approve_bulk_update_request_path(@bulk_update_request), @user
          assert_response 403
          assert_equal("pending", @bulk_update_request.reload.status)
        end
      end

      context "for an admin" do
        should "succeed" do
          post_auth approve_bulk_update_request_path(@bulk_update_request), @admin
          assert_response :redirect
          assert_equal("approved", @bulk_update_request.reload.status)
        end
      end
    end
  end
end
