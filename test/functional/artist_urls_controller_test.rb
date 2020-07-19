require 'test_helper'

class ArtistUrlsControllerTest < ActionDispatch::IntegrationTest
  context "The artist urls controller" do
    setup do
      @artist = create(:artist, name: "bkub", url_string: "-http://bkub.com")
      @banned = create(:artist, name: "danbo", is_banned: true, url_string: "https://danbooru.donmai.us")
    end

    context "index page" do
      should "render" do
        get artist_urls_path
        assert_response :success
      end

      should respond_to_search({}).with { @banned.urls + @artist.urls }
      should respond_to_search(url_matches: "*bkub*").with { @artist.urls }
      should respond_to_search(is_active: "false").with { @artist.urls }

      context "using includes" do
        should respond_to_search(artist: {name: "bkub"}).with { @artist.urls }
        should respond_to_search(artist: {is_banned: "true"}).with { @banned.urls }
      end
    end
  end
end
