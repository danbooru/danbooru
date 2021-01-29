require "test_helper"

class PostVotesComponentTest < ViewComponent::TestCase
  def render_post_votes(post, current_user:)
    render_inline(PostVotesComponent.new(post: post, current_user: current_user))
  end

  context "The PostVotesComponent" do
    setup do
      @post = as(create(:user)) { create(:post) }
    end

    context "for a user who can't vote" do
      should "not show the vote buttons" do
        render_post_votes(@post, current_user: User.anonymous)

        assert_css(".post-score")
        assert_no_css(".post-upvote-link")
        assert_no_css(".post-downvote-link")
      end
    end

    context "for a user who can vote" do
      setup do
        @user = create(:gold_user)
      end

      should "show the vote buttons" do
        render_post_votes(@post, current_user: @user)

        assert_css(".post-upvote-link.inactive-link")
        assert_css(".post-downvote-link.inactive-link")
      end

      context "for a downvoted post" do
        should "highlight the downvote button as active" do
          @post.vote!(-1, @user)
          render_post_votes(@post, current_user: @user)

          assert_css(".post-upvote-link.inactive-link")
          assert_css(".post-downvote-link.active-link")
        end
      end

      context "for an upvoted post" do
        should "highlight the upvote button as active" do
          @post.vote!(1, @user)
          render_post_votes(@post, current_user: @user)

          assert_css(".post-upvote-link.active-link")
          assert_css(".post-downvote-link.inactive-link")
        end
      end
    end
  end
end
