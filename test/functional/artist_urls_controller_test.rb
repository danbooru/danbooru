require 'test_helper'

class ArtistUrlsControllerTest < ActionDispatch::IntegrationTest
  context "The artist urls controller" do
    context "index page" do
      should "render" do
        get artist_urls_path
        assert_response :success
      end

      should "render for a complex search" do
        @artist = FactoryBot.create(:artist, name: "bkub", url_string: "-http://bkub.com")

        get artist_urls_path(search: {
          artist: { name: "bkub" },
          url_matches: "*bkub*",
          is_active: "false",
          order: "created_at"
        })

        assert_response :success
      end
    end
  end
end
