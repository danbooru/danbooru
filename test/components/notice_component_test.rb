require "test_helper"

class NoticeComponentTest < ViewComponent::TestCase
  context "The NoticeComponent" do
    should "render the notice message" do
      render_inline(NoticeComponent.new("hello world"))

      assert_css("#notice")
      assert_css("#notice .prose", text: "hello world")
    end
  end
end
