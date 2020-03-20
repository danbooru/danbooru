require 'test_helper'

class PostVotesControllerTest < ActionDispatch::IntegrationTest
  context "The post vote controller" do
    setup do
      @user = create(:gold_user)
      @post = create(:post)
    end

    context "index action" do
      should "work" do
        as(@user) { create(:post_vote, post_id: @post.id, user_id: @user.id) }
        get_auth post_votes_path, @user

        assert_response :success
      end
    end

    context "create action" do
      should "not allow anonymous users to vote" do
        post post_post_votes_path(post_id: @post.id), params: {:score => "up", :format => "js"}
        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "not allow banned users to vote" do
        @banned = create(:user)
        @ban = create(:ban, user: @banned)
        post_auth post_post_votes_path(post_id: @post.id), @banned, params: {:score => "up", :format => "js"}
        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "not allow members to vote" do
        @member = create(:member_user)
        post_auth post_post_votes_path(post_id: @post.id), @member, params: {:score => "up", :format => "js"}
        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "increment a post's score if the score is positive" do
        post_auth post_post_votes_path(post_id: @post.id), @user, params: {:score => "up", :format => "js"}
        assert_response :success
        @post.reload
        assert_equal(1, @post.score)
      end

      context "for a post that has already been voted on" do
        should "not create another vote" do
          @post.vote!("up", @user)
          assert_no_difference("PostVote.count") do
            post_auth post_post_votes_path(post_id: @post.id), @user, params: { score: "up", format: "js" }
            assert_response 422
          end
        end
      end
    end

    context "destroy action" do
      should "remove a vote" do
        as(@user) { create(:post_vote, post_id: @post.id, user_id: @user.id) }

        assert_difference("PostVote.count", -1) do
          delete_auth post_post_votes_path(post_id: @post.id), @user, as: :javascript
          assert_redirected_to @post
        end
      end
    end
  end
end
