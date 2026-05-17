require "test_helper"

class PreviewSizeMenuComponentTest < ViewComponent::TestCase
  context "The PreviewSizeMenuComponent" do
    should "render preview size options" do
      PreviewSizeMenuComponent.any_instance.stubs(:current_page_path).returns("/posts")

      render_inline(PreviewSizeMenuComponent.new(current_size: 180))

      assert_css(".preview-size-menu")
      assert_css("a.font-bold", text: "Medium")
      assert_css("a", text: "Absurd")
    end
  end
end
