require "test_helper"

class FileUploadComponentTest < ViewComponent::TestCase
  context "The FileUploadComponent" do
    should "render" do
      render_inline(FileUploadComponent.new)
      assert_text("Choose file")
    end
  end
end
