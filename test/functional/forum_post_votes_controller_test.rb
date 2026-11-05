require "test_helper"

class ForumPostVotesControllerTest < ActionDispatch::IntegrationTest
  context "The forum post votes controller" do
    setup do
      @user = create(:user)
      @other_user = create(:user)

      as(@user) do
        @forum_post = create(:forum_post, body: "blah", creator: @user)
        @bulk_update_request = create(:bulk_update_request, forum_post: @forum_post)
      end
    end

    context "index action" do
      setup do
        @vote = create(:forum_post_vote, forum_post: @forum_post, creator: build(:user), score: 1)
        @negative_vote = create(:forum_post_vote, forum_post: @forum_post, score: -1)
        @unrelated_vote = as(@user) { create(:forum_post_vote, score: 0) }
      end

      should "render" do
        get forum_post_votes_path
        assert_response :success
      end

      should respond_to_search.with { [@unrelated_vote, @negative_vote, @vote] }
      should respond_to_search(score: -1).with { @negative_vote }

      should respond_to_search(creator_name: -> { @vote.creator.name }).with { @vote }
      should respond_to_search(forum_post: { creator_name: -> { @user.name }}).with { [@negative_vote, @vote] }
      should respond_to_search(forum_post: { body_matches: "blah" }).with { [@negative_vote, @vote] }

      should "not show votes on forum posts the user can't see" do
        hidden_vote = create(:forum_post_vote, forum_post: create(:forum_post, topic: create(:mod_up_forum_topic)))

        get_auth forum_post_votes_path, @user, as: :json
        assert_response :success
        assert_not_includes(response.parsed_body.pluck("id"), hidden_vote.id)

        get_auth forum_post_votes_path, create(:moderator_user), as: :json
        assert_response :success
        assert_includes(response.parsed_body.pluck("id"), hidden_vote.id)
      end

      should "not run extra queries for each included forum post" do
        count_queries = lambda do
          get_auth forum_post_votes_path(only: "id,forum_post[body]"), @user, as: :json # warm up caches
          count = 0
          ActiveSupport::Notifications.subscribed(->(*, payload) { count += 1 if payload[:sql].match?(/\ASELECT/) }, "sql.active_record") do
            get_auth forum_post_votes_path(only: "id,forum_post[body]"), @user, as: :json
          end
          count
        end

        queries = count_queries.call
        create_list(:forum_post_vote, 5)
        assert_equal(queries, count_queries.call)
      end
    end

    context "show action" do
      should "show the vote to all users" do
        @forum_post_vote = create(:forum_post_vote, forum_post: @forum_post)
        get forum_post_vote_path(@forum_post_vote), as: :json
        assert_response :success
      end

      should "not show votes on forum posts the user can't see" do
        hidden_vote = create(:forum_post_vote, forum_post: create(:forum_post, topic: create(:mod_up_forum_topic)))

        get_auth forum_post_vote_path(hidden_vote), @user, as: :json
        assert_response 404
      end
    end

    context "create action" do
      should "work for a JSON response" do
        post_auth forum_post_votes_path, @user, params: { forum_post_id: @forum_post.id, forum_post_vote: { score: 1 }}, as: :json

        assert_response 201
        assert_equal(1, @forum_post.votes.count)
      end

      should "allow members to vote" do
        assert_difference("ForumPostVote.count", 1) do
          post_auth forum_post_votes_path(format: :js), @user, params: { forum_post_id: @forum_post.id, forum_post_vote: { score: 1 }}
          assert_response :success
        end
      end

      should "escape HTML in the error message" do
        ForumPostVote.any_instance.stubs(:invalid?).returns(true)
        ActiveModel::Errors.any_instance.stubs(:full_messages).returns(["<b>bad</b>"])
        post_auth forum_post_votes_path(format: :js), @user, params: { forum_post_id: @forum_post.id, forum_post_vote: { score: 1 }}

        assert_response :success
        assert_no_match(/<b>|\\u003cb/, response.body)
      end

      should "not allow privileged users to vote on private forum posts" do
        as(@user) { @forum_post.topic.update!(min_level: User::Levels::ADMIN) }
        assert_difference("ForumPostVote.count", 0) do
          post_auth forum_post_votes_path(format: :js), @user, params: { forum_post_id: @forum_post.id, forum_post_vote: { score: 1 }}
          assert_response 403
        end
      end

      should "allow creators to vote on their own BURs" do
        assert_difference("ForumPostVote.count", 1) do
          post_auth forum_post_votes_path(format: :js), @bulk_update_request.user, params: { forum_post_id: @forum_post.id, forum_post_vote: { score: 1 }}
          assert_response :success
        end
      end
    end

    context "destroy action" do
      setup do
        @forum_post_vote = create(:forum_post_vote, creator: @user, forum_post: @forum_post)
      end

      should "allow members to destroy their own votes" do
        assert_difference("ForumPostVote.count", -1) do
          delete_auth forum_post_vote_path(@forum_post_vote.id, format: :js), @user
          assert_response :success
        end
      end

      should "not allow members to destroy other people's votes" do
        assert_difference("ForumPostVote.count", 0) do
          delete_auth forum_post_vote_path(@forum_post_vote.id, format: :js), @other_user
          assert_response 403
        end
      end

      should "not allow members to destroy their votes on approved BURs" do
        as(@user) { @bulk_update_request.update!(status: :approved) }
        assert_difference("ForumPostVote.count", 0) do
          delete_auth forum_post_vote_path(@forum_post_vote.id, format: :js), @user
          assert_response 403
        end
      end
    end
  end
end
