require "test_helper"

module Source::Tests::Extractor
  class NaverPostExtractorTest < ActiveSupport::TestCase
    context "A post" do
      strategy_should_work(
        "https://site.name/post",
        image_urls: [],
        media_files: [{ file_size: 123 }],
        profile_url: "",
        page_url: "",
        display_name: "",
        username: "",
        other_names: [],
        tags: [],
        artist_commentary_title: "",
        artist_commentary_desc: "",
      )
    end

    context "A deleted or non-existing post" do
      strategy_should_work(
        "https://site.name/post",
        deleted: true,
        profile_url: nil,
      )
    end
  end
end
