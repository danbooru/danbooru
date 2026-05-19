require "test_helper"

module Source::Tests::URL
  class AppleMusicUrlTest < ActiveSupport::TestCase
    context "Apple Music URLs" do
      should be_image_url(
        "https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg/296x296bb.webp",
        "https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg/10000x10000.png",
        "https://a1.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg",
      )

      should be_page_url(
        "https://music.apple.com/jp/album/mágico-catástrofe-digital-edition/1503302894",
        "https://music.apple.com/jp/album/track-name/1503302894?i=1503302895",
        "https://music.apple.com/album/mágico-catástrofe-digital-edition/1503302894",
      )

      should be_profile_url(
        "https://music.apple.com/us/artist/mori-calliope/1536368549",
        "https://itunes.apple.com/us/artist/mori-calliope/id153636854",
      )

      should parse_url("https://music.apple.com/jp/album/mágico-catástrofe-digital-edition/1503302894").into(
        site_name: "Apple Music",
        album_id: "1503302894",
        album_name: "mágico-catástrofe-digital-edition",
        country_code: "jp",
        page_url: "https://music.apple.com/jp/album/mágico-catástrofe-digital-edition/1503302894",
      )

      should parse_url("https://itunes.apple.com/jp/album/mágico-catástrofe-digital-edition/id1503302894").into(
        page_url: "https://music.apple.com/jp/album/mágico-catástrofe-digital-edition/1503302894",
      )

      should parse_url("https://music.apple.com/jp/album/track-name/1503302894?i=1503302895").into(
        album_id: "1503302894",
        page_url: "https://music.apple.com/jp/album/track-name/1503302894",
      )

      should parse_url("https://itunes.apple.com/us/artist/mori-calliope/id153636854").into(
        profile_url: "https://music.apple.com/us/artist/mori-calliope/153636854",
      )

      should parse_url("https://is2-ssl.mzstatic.com/image/thumb/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg/296x296bb.webp").into(
        full_image_url: "https://a2.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg",
      )

      should parse_url("https://a1.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg").into(
        full_image_url: "https://a1.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg",
      )

      should be_bad_link(
        "https://is2-ssl.mzstatic.com/image/thumb/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg/296x296bb.webp",
        "https://a1.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg",
      )

      should be_bad_source(
        "https://music.apple.com/invalid",
        "https://music.apple.com/us/playlist/a-list-pop/pl.5ee8333dbe944d9f9151e97d92d1ead9",
        "https://music.apple.com/us/song/orpheus/1870255338",
      )
    end
  end
end
