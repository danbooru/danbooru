require "test_helper"

class SidebarComponentTest < ViewComponent::TestCase
  context "The SidebarComponent" do
    should "default to unpinned for a missing cookie" do
      render_inline(SidebarComponent.new) { "sidebar content" }

      assert_css("aside#sidebar[data-dock='default']")
      assert_css("a.font-bold", text: "Default")
    end

    should "respect a valid dock cookie" do
      render_inline(SidebarComponent.new(sidebar_dock: "left".to_json)) { "sidebar content" }

      assert_css("aside#sidebar[data-dock='left']")
      assert_css("a.font-bold", text: "Pin to Left")
    end

    should "ignore an invalid dock cookie" do
      render_inline(SidebarComponent.new(sidebar_dock: "not-json")) { "sidebar content" }

      assert_css("aside#sidebar[data-dock='default']")
    end

    should "render the given block as its content" do
      render_inline(SidebarComponent.new) { "sidebar content" }

      assert_text("sidebar content")
    end
  end
end
