require 'test_helper'

class ArtistURLsControllerTest < ActionDispatch::IntegrationTest
  context "The artist urls controller" do
    setup do
      @user = create(:user)
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

    context "create action" do
      should "create a new artist url" do
        assert_difference("ArtistURL.count", 1) do
          assert_difference("ArtistVersion.count", 1) do
            post_auth artist_artist_urls_path(@artist), @user, params: { artist_url: { url: "http://google.com", is_active: true } }, as: :json
          end
        end
        assert_response 201
        url = ArtistURL.last
        assert_equal("http://google.com", url.url)
        assert_equal(true, url.is_active?)
      end

      should "update an existing artist url if it exists" do
        url = @artist.urls.first
        assert_no_difference("ArtistURL.count") do
          assert_difference("ArtistVersion.count", 1) do
            post_auth artist_artist_urls_path(@artist), @user, params: { artist_url: { url: url.url, is_active: !url.is_active } }, as: :json
          end
        end
        assert_response 200
        assert_equal(!url.is_active, url.reload.is_active?)
      end

      should "find existing non-normalized artist url" do
        url = create(:artist_url, artist: @artist, url: "https://www.pixiv.net/users/12345")
        assert_no_difference("ArtistURL.count") do
          assert_no_difference("ArtistVersion.count") do
            post_auth artist_artist_urls_path(@artist), @user, params: { artist_url: { url: "http://pixiv.net/en/users/12345" } }, as: :json
          end
        end
        assert_response 200
        assert_equal(url.url, url.reload.url)
      end

      should "not update an existing artist url when no explicit attributes are provided" do
        url = @artist.urls.first
        assert_no_difference("ArtistURL.count") do
          assert_no_difference("ArtistVersion.count") do
            post_auth artist_artist_urls_path(@artist), @user, params: { artist_url: { url: url.url } }, as: :json
          end
        end
        assert_response 200
      end

      should "not create a version if nothing changed" do
        url = @artist.urls.first
        assert_no_difference("ArtistURL.count") do
          assert_no_difference("ArtistVersion.count") do
            post_auth artist_artist_urls_path(@artist), @user, params: { artist_url: { url: url.url, is_active: url.is_active } }, as: :json
          end
        end
        assert_response 200
      end

      should "return correct status code on validation failure" do
        assert_no_difference("ArtistURL.count") do
          assert_no_difference("ArtistVersion.count") do
            post_auth artist_artist_urls_path(@artist), @user, params: { artist_url: { url: "not an url" } }, as: :json
          end
        end
        assert_response 422
      end
    end

    context "update action" do
      should "update the artist url" do
        url = @artist.urls.first
        assert_no_difference("ArtistURL.count") do
          assert_difference("ArtistVersion.count", 1) do
            put_auth artist_artist_url_path(@artist, url), @user, params: { artist_url: { is_active: !url.is_active } }, as: :json
          end
        end
        assert_response 204
        assert_equal(!url.is_active, url.reload.is_active?)
      end

      should "not allow updating the url field" do
        url = @artist.urls.first
        assert_no_difference("ArtistURL.count") do
          assert_no_difference("ArtistVersion.count") do
            put_auth artist_artist_url_path(@artist, url), @user, params: { artist_url: { url: "http://google.com" } }, as: :json
          end
        end
        assert_response 403
        assert_equal(url.url, url.reload.url)
      end

      should "not update an existing artist url when no explicit attributes are provided" do
        url = @artist.urls.first
        assert_no_difference("ArtistURL.count") do
          assert_no_difference("ArtistVersion.count") do
            put_auth artist_artist_url_path(@artist, url), @user, params: { artist_url: { } }, as: :json
          end
        end
        assert_response 204
        assert_equal(url.is_active?, url.reload.is_active?)
      end

      should "not create a version if nothing changed" do
        url = @artist.urls.first
        assert_no_difference("ArtistURL.count") do
          assert_no_difference("ArtistVersion.count") do
            put_auth artist_artist_url_path(@artist, url), @user, params: { artist_url: { is_active: url.is_active } }, as: :json
          end
        end
        assert_response 204
      end
    end

    context "destroy action" do
      should "destroy the artist url" do
        url = @artist.urls.first
        assert_difference("ArtistURL.count", -1) do
          assert_difference("ArtistVersion.count", 1) do
            delete_auth artist_artist_url_path(@artist, url), @user, as: :json
          end
        end
        assert_response 204
      end
    end
  end
end
