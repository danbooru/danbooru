require 'test_helper'

class PostLocksControllerTest < ActionDispatch::IntegrationTest
  context "The post lock controller" do
    setup do
      @member = create(:member_user)
      @builder = create(:builder_user)
      @moderator = create(:moderator_user)
      @post = create(:post)
    end

    context "index action" do
      setup do
        create(:post_lock, post: @post, creator: @builder, tags_lock: true)
      end

      should "render the access denied page for members" do
        get_auth post_locks_path, @member
        assert_response 403
      end

      should "render for builders" do
        get_auth post_locks_path, @builder
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get_auth post_locks_path, @builder, params: {:search => {:creator_id => @builder.id}}
          assert_response :success
        end
      end
    end

    context "show action" do
      should "redirect" do
        @lock = create(:post_lock, post: @post, creator: @builder, tags_lock: true)
        get_auth post_lock_path(@lock), @builder
        assert_redirected_to post_locks_path(search: { id: @lock.id })
      end
    end

    context "create action" do
      should "create a new post lock on a post" do
        assert_difference("PostLock.count", 1) do
          post_auth create_or_update_post_locks_path, @builder, params: {:_method => "put", :format => "js", :post_lock => {:post_id => @post.id, :tags_lock => "1", :reason => "xxx"}}
          assert_response :success
        end
      end

      should "not create a post lock when the level is restricted" do
        CurrentUser.scoped(@moderator) do
          @lock = create(:post_lock, post: @post, creator: @moderator, edit_level: User::Levels::MODERATOR, comments_lock: true)
        end
        assert_difference("PostLock.count", 0) do
          CurrentUser.scoped(@builder) do
            post_auth create_or_update_post_locks_path, @builder, params: {:_method => "put", :format => "json", :post_lock => {:post_id => @post.id, :tags_lock => "1", :reason => "xxx"}}
          end
          assert_response 403
        end
      end
    end
  end
end
