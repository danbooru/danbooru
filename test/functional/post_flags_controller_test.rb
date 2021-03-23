require 'test_helper'

class PostFlagsControllerTest < ActionDispatch::IntegrationTest
  context "The post flags controller" do
    setup do
      @user = create(:user)
      @flagger = create(:gold_user, id: 999, created_at: 2.weeks.ago)
      @uploader = create(:mod_user, name: "chen", created_at: 2.weeks.ago)
      @mod = create(:mod_user)
      @post = create(:post, id: 101, is_flagged: true, uploader: @uploader)
      @post_flag = create(:post_flag, reason: "xxx", post: @post, creator: @flagger)
    end

    context "new action" do
      should "render" do
        get_auth new_post_flag_path, @flagger
        assert_response :success
      end
    end

    context "show action" do
      should "work" do
        get post_flag_path(@post_flag), as: :json
        assert_response :success
      end
    end

    context "index action" do
      setup do
        @other_flag = create(:post_flag, post: build(:post, is_flagged: true, tag_string: "touhou"))
        @unrelated_flag = create(:post_flag, reason: "poor quality")
      end

      should "render" do
        get post_flags_path
        assert_response :success
      end

      should "render for json" do
        get post_flags_path, as: :json
        assert_response :success
      end

      should "hide flagger names from regular users" do
        get_auth post_flags_path, @user
        assert_response :success
        assert_select "tr#post-flag-#{@post_flag.id} .flagged-column a.user-gold", false
      end

      should "hide flagger names from uploaders" do
        get_auth post_flags_path, @uploader
        assert_response :success
        assert_select "tr#post-flag-#{@post_flag.id} .flagged-column a.user-gold", false
      end

      should "show flagger names to the flagger themselves" do
        get_auth post_flags_path, @flagger
        assert_response :success
        assert_select "tr#post-flag-#{@post_flag.id} .flagged-column a.user-gold", true
      end

      should "show flagger names to mods" do
        get_auth post_flags_path, @mod
        assert_response :success
        assert_select "tr#post-flag-#{@post_flag.id} .flagged-column a.user-gold", true
      end

      context "as a normal user" do
        setup do
          CurrentUser.user = @user
        end

        should respond_to_search({}).with { [@unrelated_flag, @other_flag, @post_flag] }
        should respond_to_search(reason_matches: "poor quality").with { @unrelated_flag }
        should respond_to_search(category: "normal").with { [@unrelated_flag, @other_flag, @post_flag] }
        should respond_to_search(category: "deleted").with { [] }

        context "using includes" do
          should respond_to_search(post_id: 101).with { @post_flag }
          should respond_to_search(post_tags_match: "touhou").with { @other_flag }
          should respond_to_search(post: {uploader_name: "chen"}).with { @post_flag }
          should respond_to_search(creator_id: 999).with { [] }
        end
      end

      context "when the user is the uploader" do
        setup do
          CurrentUser.user = @uploader
        end

        should respond_to_search(creator_id: 999).with { [] }
      end

      context "when the user is a mod and not the uploader" do
        setup do
          CurrentUser.user = @mod
        end

        should respond_to_search(creator_id: 999).with { @post_flag }
      end

      context "when the user is the flagger" do
        setup do
          CurrentUser.user = @flagger
        end

        should respond_to_search(creator_id: 999).with { @post_flag }
      end
    end

    context "create action" do
      should "create a new flag" do
        assert_difference("PostFlag.count", 1) do
          @post = create(:post)
          post_auth post_flags_path, @flagger, params: { post_flag: { post_id: @post.id, reason: "xxx" }}, as: :javascript
          assert_redirected_to PostFlag.last
          assert_equal(true, @post.reload.is_flagged?)
        end
      end
    end

    context "edit action" do
      should "allow the flagger to edit the flag" do
        get_auth edit_post_flag_path(@post_flag), @flagger

        assert_response :success
      end

      should "not allow the flagger to edit a resolved flag" do
        @post_flag.update!(status: "rejected")
        get_auth edit_post_flag_path(@post_flag), @flagger

        assert_response 403
      end

      should "not allow other users to edit the flag" do
        get_auth edit_post_flag_path(@post_flag), @mod

        assert_response 403
      end
    end

    context "update action" do
      should "allow the flagger to update the flag" do
        put_auth post_flag_path(@post_flag), @flagger, params: { post_flag: { reason: "no" }}

        assert_redirected_to @post_flag.post
        assert_equal("no", @post_flag.reload.reason)
      end

      should "not allow the flagger to update a resolved flag" do
        @post_flag.update!(status: "rejected")
        put_auth post_flag_path(@post_flag), @flagger, params: { post_flag: { reason: "no" }}

        assert_response 403
        assert_equal("xxx", @post_flag.reload.reason)
      end

      should "not allow other users to update the flag" do
        put_auth post_flag_path(@post_flag), @mod, params: { post_flag: { reason: "no" }}

        assert_response 403
        assert_equal("xxx", @post_flag.reload.reason)
      end
    end
  end
end
