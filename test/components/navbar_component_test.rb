require "test_helper"

class NavbarComponentTest < ViewComponent::TestCase
  context "The NavbarComponent" do
    should "render the main navigation" do
      render_inline(NavbarComponent.new(current_user: User.anonymous))

      assert_css("header#top")
      assert_css("nav#nav")
      assert_text("Posts")
    end

    should "render moderator alerts for pending reports and unread dmails" do
      moderator = create(:moderator_user, unread_dmail_count: 2)
      create(:moderation_report, status: :pending)

      render_inline(NavbarComponent.new(current_user: moderator))

      assert_css("#nav")
      assert_css("#main-menu a", text: "My Account (2)")
      assert_css("#nav-reports .badge-blue", text: "1")
    end
  end
end
