require "test_helper"

module Source::Tests::Extractor
  class NullExtractorTest < ActiveSupport::ExtractorTestCase
    context "An image from an unknown site" do
      strategy_should_work(
        "https://www.marv.jp/uploads/title/10787/6722f3b818ad4.jpg",
        image_urls: %w[https://www.marv.jp/uploads/title/10787/6722f3b818ad4.jpg],
        media_files: [{ file_size: 410_739 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A IP-based source" do
      strategy_should_work(
        # "http://nghttp2.org/httpbin/image/jpeg",
        "http://139.162.123.134/httpbin/image/jpeg",
        image_urls: %w[http://139.162.123.134/httpbin/image/jpeg],
        media_files: [{ file_size: 35_588 }],
        page_url: nil,
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A null source with a referer" do
      strategy_should_work(
        # "http://nghttp2.org/httpbin/image/jpeg",
        "http://139.162.123.134/httpbin/image/jpeg",
        referer: "https://discord.com/channels/1234567890/1234567890/1234567890",
        image_urls: %w[http://139.162.123.134/httpbin/image/jpeg],
        media_files: [{ file_size: 35_588 }],
        page_url: "https://discord.com/channels/1234567890/1234567890/1234567890",
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A file:// source" do
      strategy_should_work(
        "file://image.jpg",
        image_urls: [],
        page_url: nil,
        profile_url: nil,
        tags: [],
        tag_name: nil,
        artist_name: nil,
        artist_commentary_title: nil,
        artist_commentary_desc: nil,
      )
    end
  end
end
