require "test_helper"

class FavoritesTooltipComponentTest < ViewComponent::TestCase
  context "The FavoritesTooltipComponent" do
    should "render favoriters visible to the current user" do
      post = create(:post)
      user = create(:user)
      create(:favorite, post: post, user: user)

      render_inline(FavoritesTooltipComponent.new(post: post, current_user: user))

      assert_css(".favorites-tooltip")
      assert_css(".post-favoriter", text: user.name)
    end

    should "hide private favoriters from other users" do
      post = create(:post)
      private_user = create(:gold_user, enable_private_favorites: true)
      other_user = create(:user)
      create(:favorite, post: post, user: private_user)

      render_inline(FavoritesTooltipComponent.new(post: post, current_user: other_user))

      assert_css(".favorites-tooltip")
      assert_css(".post-favoriter", text: "hidden")
      assert_no_css(".post-favoriter a")
    end

    should "render empty state when post has no favorites" do
      render_inline(FavoritesTooltipComponent.new(post: create(:post), current_user: create(:user)))

      assert_css(".favorites-tooltip")
      assert_css("i", text: "No favorites yet")
    end
  end
end
