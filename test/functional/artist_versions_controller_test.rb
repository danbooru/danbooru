require 'test_helper'

class ArtistVersionsControllerTest < ActionDispatch::IntegrationTest
  context "An artist versions controller" do
    setup do
      @user = create(:gold_user)
      @artist = as(@user) { create(:artist) }
    end

    should "get the index page" do
      get_auth artist_versions_path, @user
      assert_response :success
    end

    should "get the index page when searching for something" do
      get_auth artist_versions_path(search: {name: @artist.name}), @user
      assert_response :success
    end

    context "show action" do
      should "work" do
        get artist_version_path(@artist.versions.first)
        assert_redirected_to artist_versions_path(search: { artist_id: @artist.id })

        get artist_version_path(@artist.versions.first), as: :json
        assert_response :success
      end
    end
  end
end
