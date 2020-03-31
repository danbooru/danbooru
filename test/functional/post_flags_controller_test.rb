require 'test_helper'

class PostFlagsControllerTest < ActionDispatch::IntegrationTest
  context "The post flags controller" do
    setup do
      @user = create(:user)
      @flagger = create(:gold_user, created_at: 2.weeks.ago)
      @uploader = create(:mod_user, created_at: 2.weeks.ago)
      @mod = create(:mod_user)
      @post = create(:post, is_flagged: true, uploader: @uploader)
      @post_flag = create(:post_flag, post: @post, creator: @flagger)
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

      context "with search parameters" do
        should "render" do
          get_auth post_flags_path(search: { post_id: @post_flag.post_id }), @user
          assert_response :success
        end

        should "hide flagged posts when the searcher is the uploader" do
          get_auth post_flags_path(search: { creator_id: @flagger.id }), @uploader
          assert_response :success
          assert_select "tr#post-flag-#{@post_flag.id}", false
        end

        should "show flagged posts when the searcher is not the uploader" do
          get_auth post_flags_path(search: { creator_id: @flagger.id }), @mod
          assert_response :success
          assert_select "tr#post-flag-#{@post_flag.id}", true
        end
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
  end
end
