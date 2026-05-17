require "test_helper"

class MediaAssetGalleryComponentTest < ViewComponent::TestCase
  context "The MediaAssetGalleryComponent" do
    should "render gallery items" do
      render_inline(MediaAssetGalleryComponent.new(classes: ["custom-gallery"])) do |component|
        component.with_media_asset do
          "<div class='gallery-item'>Asset</div>".html_safe
        end
      end

      assert_css(".media-asset-gallery.custom-gallery")
      assert_css(".media-assets-container .gallery-item", text: "Asset")
    end

    should "render an empty gallery message" do
      render_inline(MediaAssetGalleryComponent.new)

      assert_css(".media-asset-gallery")
      assert_css("p", text: "No results found.")
      assert_no_css(".media-assets-container")
    end
  end
end
