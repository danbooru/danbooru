require "test_helper"

module Source::Tests::Extractor
  class AppleMusicExtractorTest < ActiveSupport::ExtractorTestCase
    context "An Apple Music album page" do
      strategy_should_work(
        "https://music.apple.com/jp/album/mágico-catástrofe-digital-edition/1503302894",
        image_urls: %w[https://a1.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg],
        page_url: "https://music.apple.com/jp/album/mágico-catástrofe-digital-edition/1503302894",
        tags: [],
        dtext_artist_commentary_title: "マジコカタストロフィ - Digital Edition",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A direct mzstatic image thumb URL with a referer" do
      strategy_should_work(
        "https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg/296x296bb.webp",
        referer: "https://music.apple.com/jp/album/mágico-catástrofe-digital-edition/1503302894",
        image_urls: %w[https://a1.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg],
        page_url: "https://music.apple.com/jp/album/mágico-catástrofe-digital-edition/1503302894",
        tags: [],
        dtext_artist_commentary_title: "マジコカタストロフィ - Digital Edition",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A direct mzstatic image thumb URL without a referer" do
      strategy_should_work(
        "https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg/296x296bb.webp",
        image_urls: %w[https://a1.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg],
        page_url: nil,
        profile_urls: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A direct mzstatic image URL without a referer" do
      strategy_should_work(
        "https://a1.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg",
        image_urls: %w[https://a1.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg],
        page_url: nil,
        profile_urls: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
