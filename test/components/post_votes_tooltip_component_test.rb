require "test_helper"

class PostVotesTooltipComponentTest < ViewComponent::TestCase
  context "The PostVotesTooltipComponent" do
    should "render vote totals and voters" do
      post = create(:post)

      create(:post_vote, post: post, score: 1)
      create(:post_vote, post: post, score: -1)

      render_inline(PostVotesTooltipComponent.new(post: post.reload, current_user: create(:admin_user)))

      assert_css(".post-votes-tooltip")
      assert_css(".post-voters .post-voter", count: 2)
      assert_text("+1 / -1")
    end

    should "hide private positive voter names from non-admins" do
      post = create(:post)
      private_voter = create(:gold_user, enable_private_favorites: true)

      create(:post_vote, post: post, user: private_voter, score: 1)

      render_inline(PostVotesTooltipComponent.new(post: post.reload, current_user: create(:user)))

      assert_css(".post-votes-tooltip")
      assert_text("+1 / -0")
      assert_css(".post-voter i.align-middle", text: "hidden")
      assert_no_css(".post-voter a.user-#{private_voter.level}")
    end

    should "hide downvoter names from other non-admin users" do
      post = create(:post)
      downvoter = create(:gold_user)

      create(:post_vote, post: post, user: downvoter, score: -1)

      render_inline(PostVotesTooltipComponent.new(post: post.reload, current_user: create(:user)))

      assert_css(".post-votes-tooltip")
      assert_text("+0 / -1")
      assert_css(".post-voter i.align-middle", text: "hidden")
      assert_no_css(".post-voter a.user-#{downvoter.level}")
    end
  end
end
