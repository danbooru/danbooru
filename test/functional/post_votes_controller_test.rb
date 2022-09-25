require 'test_helper'

class PostVotesControllerTest < ActionDispatch::IntegrationTest
  context "The post vote controller" do
    setup do
      @user = create(:gold_user, name: "meiling")
      @post = create(:post, tag_string: "dragon")
    end

    context "index action" do
      setup do
        @user = create(:user, enable_private_favorites: true)
        @upvote = create(:post_vote, user: @user, score: 1)
        @downvote = create(:post_vote, user: @user, score: -1)
      end

      should "render" do
        get post_votes_path
        assert_response :success
      end

      should "render for a compact view" do
        get post_votes_path(variant: "compact")
        assert_response :success
      end

      should "render for a tooltip" do
        get post_votes_path(search: { post_id: @upvote.post_id }, variant: "tooltip")
        assert_response :success
      end

      context "as a user" do
        should "show the user all their own votes" do
          get_auth post_votes_path, @user
          assert_response :success
          assert_select "tbody tr", 2

          get_auth post_votes_path(search: { user_id: @user.id }), @user
          assert_response :success
          assert_select "tbody tr", 2

          get_auth post_votes_path(search: { user_name: @user.name }), @user
          assert_response :success
          assert_select "tbody tr", 2
        end

        should "not show private upvotes to other users" do
          get_auth post_votes_path, create(:user)
          assert_response :success
          assert_select "tbody tr", 0

          get_auth post_votes_path(search: { user_id: @user.id }), create(:user)
          assert_response :success
          assert_select "tbody tr", 0

          get_auth post_votes_path(search: { user_name: @user.name }), create(:user)
          assert_response :success
          assert_select "tbody tr", 0
        end

        should "not show downvotes to other users" do
          @user.update!(enable_private_favorites: false)

          get_auth post_votes_path, create(:user)
          assert_response :success
          assert_select "tbody tr[data-score=1]", 1
          assert_select "tbody tr[data-score=-1]", 0

          get_auth post_votes_path(search: { user_id: @user.id }), create(:user)
          assert_response :success
          assert_select "tbody tr[data-score=1]", 1
          assert_select "tbody tr[data-score=-1]", 0

          get_auth post_votes_path(search: { user_name: @user.name }), create(:user)
          assert_response :success
          assert_select "tbody tr[data-score=1]", 1
          assert_select "tbody tr[data-score=-1]", 0
        end
      end

      context "as an admin" do
        should "show all votes by other users" do
          @admin = create(:admin_user)

          get_auth post_votes_path, @admin
          assert_response :success
          assert_select "tbody tr", 2

          get_auth post_votes_path(search: { user_id: @user.id }), @admin
          assert_response :success
          assert_select "tbody tr", 2

          get_auth post_votes_path(search: { user_name: @user.name }), @admin
          assert_response :success
          assert_select "tbody tr", 2

          get_auth post_votes_path(search: { user: { level: @user.level }}), @admin
          assert_response :success
          assert_select "tbody tr", 2
        end
      end
    end

    context "show action" do
      context "for a public upvote" do
        setup do
          @user = create(:user, enable_private_favorites: false)
          @post_vote = create(:post_vote, user: @user, score: 1)
        end

        should "show the voter to everyone" do
          get post_vote_path(@post_vote), as: :json

          assert_response :success
          assert_equal(@user.id, response.parsed_body["user_id"])
        end
      end

      context "for a private upvote" do
        setup do
          @user = create(:user, enable_private_favorites: true)
          @post_vote = create(:post_vote, user: @user, score: 1)
        end

        should "show the voter to themselves" do
          get_auth post_vote_path(@post_vote), @user, as: :json

          assert_response :success
          assert_equal(@user.id, response.parsed_body["user_id"])
        end

        should "show the voter to admins" do
          get_auth post_vote_path(@post_vote), create(:admin_user), as: :json

          assert_response :success
          assert_equal(@user.id, response.parsed_body["user_id"])
        end

        should "not show the voter to other users" do
          get post_vote_path(@post_vote), as: :json

          assert_response 403
          assert_nil(response.parsed_body["user_id"])
        end
      end

      context "for a downvote" do
        setup do
          @user = create(:user, enable_private_favorites: false)
          @post_vote = create(:post_vote, user: @user, score: -1)
        end

        should "show the voter to themselves" do
          get_auth post_vote_path(@post_vote), @user, as: :json

          assert_response :success
          assert_equal(@user.id, response.parsed_body["user_id"])
        end

        should "show the voter to admins" do
          get_auth post_vote_path(@post_vote), create(:admin_user), as: :json

          assert_response :success
          assert_equal(@user.id, response.parsed_body["user_id"])
        end

        should "not show the voter to other users" do
          get post_vote_path(@post_vote), as: :json

          assert_response 403
          assert_nil(response.parsed_body["user_id"])
        end
      end
    end

    context "create action" do
      should "work for a JSON response" do
        post_auth post_post_votes_path(post_id: @post.id, score: 1), @user, as: :json

        assert_response 201
        assert_equal(1, @post.reload.score)
      end

      should "not allow anonymous users to vote" do
        post post_post_votes_path(post_id: @post.id, score: 1), xhr: true

        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "not allow banned users to vote" do
        post_auth post_post_votes_path(post_id: @post.id, score: 1), create(:banned_user), xhr: true

        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "not allow restricted users to vote" do
        post_auth post_post_votes_path(post_id: @post.id, score: 1), create(:restricted_user), xhr: true

        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "allow members to vote" do
        post_auth post_post_votes_path(post_id: @post.id, score: 1), create(:user), xhr: true

        assert_response :success
        assert_equal(1, @post.reload.score)
      end

      should "not allow invalid scores" do
        post_auth post_post_votes_path(post_id: @post.id, score: 3), @user, xhr: true

        assert_response :success
        assert_equal(0, @post.reload.score)
        assert_equal(0, @post.up_score)
        assert_equal(0, @post.votes.count)
      end

      should "increment a post's score if the score is positive" do
        post_auth post_post_votes_path(post_id: @post.id, score: 1), @user, xhr: true

        assert_response :success
        assert_equal(1, @post.reload.score)
        assert_equal(1, @post.up_score)
        assert_equal(1, @post.votes.count)
      end

      should "decrement a post's score if the score is negative" do
        post_auth post_post_votes_path(post_id: @post.id, score: -1), @user, xhr: true

        assert_response :success
        assert_equal(-1, @post.reload.score)
        assert_equal(-1, @post.down_score)
        assert_equal(1, @post.votes.count)
      end

      context "for a post that has already been voted on" do
        should "replace the vote" do
          vote = create(:post_vote, post: @post, user: @user, score: 1)
          post_auth post_post_votes_path(post_id: @post.id, score: -1), @user, xhr: true

          assert_response :success
          assert_equal(-1, @post.reload.score)
          assert_equal(0, @post.up_score)
          assert_equal(-1, @post.down_score)
          assert_equal(1, @post.votes.negative.active.count)
          assert_equal(1, @post.votes.positive.deleted.count)
          assert_equal(true, vote.reload.is_deleted?)
        end
      end
    end

    context "destroy action" do
      setup do
        @vote = create(:post_vote, post: @post, user: @user, score: 1)
      end

      should "allow users to remove their own votes" do
        delete_auth post_post_votes_path(post_id: @vote.post_id), @user, xhr: true

        assert_response :success
        assert_equal(0, @post.reload.score)
        assert_equal(0, @post.up_score)
        assert_equal(0, @post.votes.active.count)
        assert_equal(true, @vote.reload.is_deleted?)
      end

      should "not allow regular users to remove votes by other users" do
        delete_auth post_vote_path(@vote), create(:user), xhr: true

        assert_response 403
        assert_equal(1, @post.reload.score)
        assert_equal(1, @post.up_score)
        assert_equal(1, @post.votes.active.count)
        assert_equal(false, @vote.reload.is_deleted?)
      end

      should "allow admins to remove votes by other users" do
        admin = create(:admin_user)
        delete_auth post_vote_path(@vote), admin, xhr: true

        assert_response :success
        assert_equal(0, @post.reload.score)
        assert_equal(0, @post.up_score)
        assert_equal(0, @post.votes.active.count)
        assert_equal(true, @vote.reload.is_deleted?)
        assert_match(/deleted post vote #\d+ on post #\d+/, ModAction.post_vote_delete.last.description)
        assert_equal(@vote, ModAction.last.subject)
        assert_equal(admin, ModAction.last.creator)
      end

      should "not fail when attempting to remove an already removed vote" do
        @vote.soft_delete!
        delete_auth post_post_votes_path(post_id: @vote.post_id), @user, xhr: true

        assert_response :success
        assert_equal(0, @post.reload.score)
        assert_equal(0, @post.up_score)
        assert_equal(0, @post.votes.active.count)
        assert_equal(true, @vote.reload.is_deleted?)
      end
    end
  end
end
