require 'test_helper'

class PostVotesControllerTest < ActionDispatch::IntegrationTest
  context "The post vote controller" do
    setup do
      @user = create(:gold_user)
      @user.as_current do
        @post = create(:post)
      end
    end

    context "create action" do
      should "not allow anonymous users to vote" do
        post post_votes_path(post_id: @post.id), params: {:score => "up", :format => "js"}
        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "not allow banned users to vote" do
        @banned = create(:banned_user)
        post_auth post_votes_path(post_id: @post.id), @banned, params: {:score => "up", :format => "js"}
        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "not allow members to vote" do
        @member = create(:member_user)
        post_auth post_votes_path(post_id: @post.id), @member, params: {:score => "up", :format => "js"}
        assert_response 403
        assert_equal(0, @post.reload.score)
      end

      should "increment a post's score if the score is positive" do
        post_auth post_votes_path(post_id: @post.id), @user, params: {:score => "up", :format => "js"}
        assert_response :success
        @post.reload
        assert_equal(1, @post.score)
      end

      context "for a post that has already been voted on" do
        setup do
          @user.as_current do
            @post.vote!("up")
          end
        end

        should "fail silently on an error" do
          assert_nothing_raised do
            post_auth post_votes_path(post_id: @post.id), @user, params: {:score => "up", :format => "js"}
          end
        end
      end
    end
  end
end
