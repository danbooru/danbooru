require "test_helper"

class SourceDataComponentTest < ViewComponent::TestCase
  context "The SourceDataComponent" do
    should "render with a nil source" do
      render_inline(SourceDataComponent.new(source: nil))

      assert_css(".source-data")
      assert_css(".source-data-fetch")
    end

    should "render with a real source" do
      artist = create(:artist, name: "test_artist")
      create(:artist_url, artist: artist, url: "https://www.pixiv.net/users/12345")
      source = Source::Extractor.find("https://www.pixiv.net/users/12345")

      render_inline(SourceDataComponent.new(source: source))

      assert_css(".source-data")
      assert_css(".source-data-content")
      assert_css("td a", text: "test_artist")
    end
  end
end
