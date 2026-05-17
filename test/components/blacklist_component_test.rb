require "test_helper"

class BlacklistComponentTest < ViewComponent::TestCase
  context "The BlacklistComponent" do
    should "render the user's blacklist rules" do
      user = create(:user, blacklisted_tags: "blue_hair\nrating:explicit")

      render_inline(BlacklistComponent.new(user: user))

      assert_css("#blacklist-box")
      assert_css("a[href*='blue_hair']", text: "blue_hair")
      assert_css("a[href*='rating%3Ae']", text: "rating:e")
    end
  end
end
