require "test_helper"

class CommentVotesTooltipComponentTest < ViewComponent::TestCase
  context "The CommentVotesTooltipComponent" do
    should "render vote totals and voters for moderators" do
      comment = create(:comment)
      upvoter = create(:user)
      downvoter = create(:user)
      moderator = create(:moderator_user)

      create(:comment_vote, comment: comment, user: upvoter, score: 1)
      create(:comment_vote, comment: comment, user: downvoter, score: -1)

      render_inline(CommentVotesTooltipComponent.new(comment: comment, current_user: moderator))

      assert_css(".comment-votes-tooltip")
      assert_css(".comment-voters .comment-voter", count: 2)
      assert_text("+1 / -1")
    end

    should "render vote totals but not voters for non-moderators" do
      comment = create(:comment)
      upvoter = create(:user)
      user = create(:user)

      create(:comment_vote, comment: comment, user: upvoter, score: 1)

      render_inline(CommentVotesTooltipComponent.new(comment: comment, current_user: user))

      assert_css(".comment-votes-tooltip")
      assert_text("+1 / -0")
      assert_no_css(".comment-voters")
    end
  end
end
