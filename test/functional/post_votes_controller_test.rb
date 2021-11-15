require 'test_helper'

class PostVotesControllerTest < ActionDispatch::IntegrationTest
  context "The post vote controller" do
    setup do
      @user = create(:gold_user, name: "meiling")
      @post = create(:post, tag_string: "dragon")
    end

    context "index action" do
      setup do
        @admin = create(:admin_user)
        as(@user) { @post_vote = create(:post_vote, post: @post, user: @user) }
        as(@admin) { @admin_vote = create(:post_vote, post: @post, user: @admin) }
        @unrelated_vote = create(:post_vote)
      end

      should "render" do
        get_auth post_votes_path, @user
        assert_response :success
      end

      context "as a user" do
        setup do
          CurrentUser.user = @user
        end

        should respond_to_search({}).with { @post_vote }
      end

      context "as a moderator" do
        setup do
          CurrentUser.user = @admin
        end

        should respond_to_search({}).with { [@unrelated_vote, @admin_vote, @post_vote] }
        should respond_to_search(score: 1).with { [@unrelated_vote, @admin_vote, @post_vote].select{ |v| v.score == 1 } }

        context "using includes" do
          should respond_to_search(post_tags_match: "dragon").with { [@admin_vote, @post_vote] }
          should respond_to_search(user_name: "meiling").with { @post_vote }
          should respond_to_search(user: {level: User::Levels::ADMIN}).with { @admin_vote }
        end
      end
    end

    context "show action" do
      setup do
        @post_vote = create(:post_vote, post: @post, user: @user)
      end

      should "show the vote to the voter" do
        get_auth post_vote_path(@post_vote), @user, as: :json
        assert_response :success
      end

      should "show the vote to admins" do
        get_auth post_vote_path(@post_vote), create(:admin_user), as: :json
        assert_response :success
      end

      should "not show the vote to other users" do
        get_auth post_vote_path(@post_vote), create(:user), as: :json
        assert_response 403
      end
    end

    context "create action" do
      should "work for a JSON response" do
        post_auth post_post_votes_path(post_id: @post.id), @user, params: { score: 1, format: "json" }

        assert_response 201
        assert_equal(1, @post.reload.score)
      end

      should "not allow anonymous users to vote" do
        post post_post_votes_path(post_id: @post.id), params: { score: 1, format: "js" }

        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "not allow banned users to vote" do
        post_auth post_post_votes_path(post_id: @post.id), create(:banned_user), params: { score: 1, format: "js"}

        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "not allow members to vote" do
        post_auth post_post_votes_path(post_id: @post.id), create(:user), params: { score: 1, format: "js" }

        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "not allow invalid scores" do
        post_auth post_post_votes_path(post_id: @post.id), @user, params: { score: 3, format: "js" }

        assert_response 200
        assert_equal(0, @post.reload.score)
        assert_equal(0, @post.up_score)
        assert_equal(0, @post.votes.count)
      end

      should "increment a post's score if the score is positive" do
        post_auth post_post_votes_path(post_id: @post.id), @user, params: { score: 1, format: "js" }

        assert_response :success
        assert_equal(1, @post.reload.score)
        assert_equal(1, @post.up_score)
        assert_equal(1, @post.votes.count)
      end

      should "decrement a post's score if the score is negative" do
        post_auth post_post_votes_path(post_id: @post.id), @user, params: { score: -1, format: "js" }

        assert_response :success
        assert_equal(-1, @post.reload.score)
        assert_equal(-1, @post.down_score)
        assert_equal(1, @post.votes.count)
      end

      context "for a post that has already been voted on" do
        should "replace the vote" do
          @post.vote!(1, @user)

          assert_no_difference("@post.votes.count") do
            post_auth post_post_votes_path(post_id: @post.id), @user, params: { score: -1, format: "js" }

            assert_response :success
            assert_equal(-1, @post.reload.score)
            assert_equal(0, @post.up_score)
            assert_equal(-1, @post.down_score)
          end
        end
      end
    end

    context "destroy action" do
      should "do nothing for anonymous users" do
        delete post_post_votes_path(post_id: @post.id), xhr: true

        assert_response 200
        assert_equal(0, @post.reload.score)
      end

      should "do nothing if the post hasn't been voted on" do
        delete_auth post_post_votes_path(post_id: @post.id), @user, xhr: true

        assert_response :success
        assert_equal(0, @post.reload.score)
        assert_equal(0, @post.down_score)
        assert_equal(0, @post.votes.count)
      end

      should "remove a vote" do
        @post.vote!(1, @user)
        delete_auth post_post_votes_path(post_id: @post.id), @user, xhr: true

        assert_response :success
        assert_equal(0, @post.reload.score)
        assert_equal(0, @post.down_score)
        assert_equal(0, @post.votes.count)
      end
    end
  end
end
