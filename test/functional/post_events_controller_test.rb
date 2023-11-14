require 'test_helper'

class PostEventsControllerTest < ActionDispatch::IntegrationTest
  context "The post approvals controller" do
    context "index action" do
      setup do
        @user = create(:user)
        @post = create(:post, uploader: @user, is_pending: true)

        @approval = create(:post_approval, post: @post)
        @flag = create(:post_flag, post: @post, creator: @user, is_deletion: true)
        @post.update!(is_deleted: true)
        @appeal = create(:post_appeal, post: @post, creator: @user)
        @disapproval = create(:post_disapproval, post: @post, user: @user)
        @replacement = create(:post_replacement, post: @post, creator: @user)

        create(:mod_action, category: :post_delete, description: "deleted post ##{@post.id}", subject: @post)
        create(:mod_action, category: :post_undelete, description: "undeleted post ##{@post.id}", subject: @post)
        create(:mod_action, category: :post_ban, description: "banned post ##{@post.id}", subject: @post)
        create(:mod_action, category: :post_unban, description: "unbanned post ##{@post.id}", subject: @post)
        create(:mod_action, category: :post_move_favorites, description: "moved favorites from post ##{@post.id} to post #1234", subject: @post)
        create(:mod_action, category: :post_regenerate, description: "regenerated post ##{@post.id}", subject: @post)
        create(:mod_action, category: :post_regenerate_iqdb, description: "regenerated IQDB for post ##{@post.id}", subject: @post)
        create(:mod_action, category: :post_note_lock_create, description: "locked notes for post ##{@post.id}", subject: @post)
        create(:mod_action, category: :post_note_lock_delete, description: "unlocked notes for post ##{@post.id}", subject: @post)
        create(:mod_action, category: :post_rating_lock_create, description: "locked rating for post ##{@post.id}", subject: @post)
        create(:mod_action, category: :post_rating_lock_delete, description: "unlocked ratineg for post ##{@post.id}", subject: @post)
      end

      should "render for a global listing" do
        get post_events_path

        assert_response :success
      end

      should "render for a single post listing" do
        get post_post_events_path(@post.id)

        assert_response :success
      end

      should "render for a json response" do
        get post_events_path, as: :json

        assert_response :success
      end

      context "for a moderator" do
        should "render" do
          get_auth post_events_path, create(:mod_user)
          assert_response :success
        end

        should "allow searching flags by creator" do
          get_auth post_events_path(search: { creator_name: @user.name }), create(:mod_user), as: :json

          assert_response :success
          assert_equal(5, response.parsed_body.size)
          assert_equal(@flag.creator_id, response.parsed_body.find { |event| event["model_type"] == "PostFlag" }["creator_id"])
          assert_equal(@disapproval.user_id, response.parsed_body.find { |event| event["model_type"] == "PostDisapproval" }["creator_id"])
        end

        should "include the creator_id in the API" do
          get_auth post_events_path, create(:mod_user), as: :json

          assert_response :success
          assert_equal(@flag.creator_id, response.parsed_body.find { |event| event["model_type"] == "PostFlag" }["creator_id"])
        end

        should respond_to_search(category: "Upload").with { PostEvent.find_by!(model: @post) }
        should respond_to_search(category: "Flag").with { PostEvent.find_by!(model: @flag) }
        should respond_to_search(category: "Delete").with { PostEvent.find_by!(model: ModAction.post_delete.first) }
        should respond_to_search(category: "Blah").with { [] }
      end

      context "for a non-moderator" do
        should "not allow searching flags by creator" do
          get post_events_path(search: { creator_name: @user.name }), as: :json

          assert_response :success
          assert_equal(3, response.parsed_body.size)
          assert_nil(response.parsed_body.find { |event| event["model_type"] == "PostFlag" })
          assert_nil(response.parsed_body.find { |event| event["model_type"] == "PostDisapproval" })
        end

        should "not include the creator_id in the API" do
          get post_events_path, as: :json

          assert_response :success
          assert_nil(response.parsed_body.find { |event| event["model_type"] == "PostFlag" }["creator_id"])
        end

        should respond_to_search(category: "Upload").with { PostEvent.find_by!(model: @post) }
        should respond_to_search(category: "Flag").with { PostEvent.find_by!(model: @flag) }
        should respond_to_search(category: "Delete").with { PostEvent.find_by!(model: ModAction.post_delete.first) }
        should respond_to_search(category: "Blah").with { [] }
      end
    end
  end
end
