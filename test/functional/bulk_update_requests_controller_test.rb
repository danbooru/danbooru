require 'test_helper'

class BulkUpdateRequestsControllerTest < ActionDispatch::IntegrationTest
  context "BulkUpdateRequestsController" do
    setup do
      @user = create(:user, id: 999)
      @builder = create(:builder_user)
      @admin = create(:admin_user)
      as(@admin) { @forum_topic = create(:forum_topic, id: 100, category_id: 0) }
      as(@user) { @bulk_update_request = create(:bulk_update_request, user: @user, forum_topic: @forum_topic, script: "create alias aaa -> bbb") }
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

      should "fail for an invalid script" do
        put_auth bulk_update_request_path(@bulk_update_request.id), @user, params: { bulk_update_request: { script: "create alis gray -> grey" }}
        assert_response :success
        assert_equal("create alias aaa -> bbb", @bulk_update_request.reload.script)
      end
    end

    context "#index" do
      setup do
        @other_BUR = create(:bulk_update_request, user: @builder, script: "create alias cirno -> 9")
        @rejected_BUR = create(:bulk_update_request, status: "rejected")
        @approved_BUR = create(:bulk_update_request, status: "approved", approver: @admin)
      end

      should "render" do
        get bulk_update_requests_path
        assert_response :success
      end

      should respond_to_search({}).with { [@other_BUR, @bulk_update_request, @approved_BUR, @rejected_BUR] }
      should respond_to_search(order: "id_desc").with { [@approved_BUR, @rejected_BUR, @other_BUR, @bulk_update_request] }
      should respond_to_search(status: "pending").with { [@other_BUR, @bulk_update_request] }
      should respond_to_search(script_matches: "cirno -> 9").with { @other_BUR }
      should respond_to_search(tags_include_any: "cirno").with { @other_BUR }

      context "using includes" do
        should respond_to_search(forum_topic_id: 100).with { @bulk_update_request }
        should respond_to_search(forum_topic: {category_id: 0}).with { @bulk_update_request }
        should respond_to_search(user_id: 999).with { @bulk_update_request }
        should respond_to_search(user: {level: User::Levels::BUILDER}).with { @other_BUR }
        should respond_to_search(has_approver: "true").with { @approved_BUR }
        should respond_to_search(has_approver: "false").with { [@other_BUR, @bulk_update_request, @rejected_BUR] }
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
