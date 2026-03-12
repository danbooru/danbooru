require "test_helper"

class PopupMenuComponentTest < ViewComponent::TestCase
  context "The PopupMenuComponent" do
    should "render the button and menu items" do
      render_inline(PopupMenuComponent.new(classes: "custom-menu")) do |menu|
        menu.with_button { "Open" }
        menu.with_item { "Item 1" }
      end

      assert_css(".popup-menu.custom-menu")
      assert_css(".popup-menu-content li", text: "Item 1")
      assert_css(".popup-menu-button", text: "Open")
    end
  end
end
