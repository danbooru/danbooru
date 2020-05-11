require 'test_helper'

class BulkUpdateRequestsControllerTest < ActionDispatch::IntegrationTest
  context "BulkUpdateRequestsController" do
    setup do
      @user = create(:user)
      @builder = create(:builder_user)
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
          post_auth bulk_update_requests_path, @user, params: { bulk_update_request: attributes_for(:bulk_update_request) }
          assert_response :redirect
        end
      end

      should "fail for an invalid script" do
        assert_difference("BulkUpdateRequest.count", 0) do
          post_auth bulk_update_requests_path, @user, params: { bulk_update_request: attributes_for(:bulk_update_request).merge(script: "create alis gray -> grey") }
          assert_response :success
        end
      end

      should "fail for a blank reason" do
        assert_difference("BulkUpdateRequest.count", 0) do
          post_auth bulk_update_requests_path, @user, params: { bulk_update_request: attributes_for(:bulk_update_request).merge(reason: "") }
          assert_response :success
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

      context "for a builder" do
        should "fail for a large artist move" do
          create(:tag, name: "artist1", category: Tag.categories.artist, post_count: 1000)
          @bulk_update_request = create(:bulk_update_request, script: "create alias artist1 -> artist2")

          post_auth approve_bulk_update_request_path(@bulk_update_request), @builder

          assert_response 403
          assert_equal("pending", @bulk_update_request.reload.status)
          assert_equal(false, TagAlias.where(antecedent_name: "artist1", consequent_name: "artist2").exists?)
        end

        should "succeed for a small artist move" do
          create(:tag, name: "artist1a", category: Tag.categories.artist, post_count: 10)
          create(:tag, name: "artist1b", category: Tag.categories.general, post_count: 0)
          create(:tag, name: "artist2a", category: Tag.categories.artist, post_count: 20)
          @bulk_update_request = create(:bulk_update_request, script: "mass update artist1a -> artist1b\ncreate alias artist2a -> artist2b")

          post_auth approve_bulk_update_request_path(@bulk_update_request), @builder

          assert_redirected_to(bulk_update_requests_path)
          assert_equal("approved", @bulk_update_request.reload.status)
          assert_equal(@builder, @bulk_update_request.approver)
          assert_equal(true, TagAlias.where(antecedent_name: "artist2a", consequent_name: "artist2b").exists?)
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
