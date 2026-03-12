require "test_helper"

class TabPanelComponentTest < ViewComponent::TestCase
  context "The TabPanelComponent" do
    should "render tabs and panels" do
      render_inline(TabPanelComponent.new do |tabs|
        tabs.panel("First", active: true) { "First panel" }
        tabs.panel("Second") { "Second panel" }
      end)

      assert_css(".tab-panel-component")
      assert_css(".tab-list .tab", count: 2)
      assert_css(".tab-panels .tab-panel.active-tab", text: "First panel")
    end
  end
end
