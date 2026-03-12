require "test_helper"

class HelpTooltipComponentTest < ViewComponent::TestCase
  context "The HelpTooltipComponent" do
    should "render the tooltip icon and content" do
      render_inline(HelpTooltipComponent.new("?", "Helpful text", link_class: "custom-help"))

      assert_css(".help-tooltip-link.custom-help", text: "?")
      assert_css(".help-tooltip-content", text: "Helpful text", visible: :all)
    end
  end
end
