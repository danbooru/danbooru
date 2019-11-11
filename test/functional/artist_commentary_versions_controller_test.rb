require 'test_helper'

class ArtistCommentaryVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The artist commentary versions controller" do
    setup do
      @user = create(:user)
      @commentary1 = as(@user) { create(:artist_commentary) }
      @commentary2 = as(@user) { create(:artist_commentary) }
    end

    context "index action" do
      should "render" do
        get artist_commentary_versions_path
        assert_response :success
      end
    end

    context "show action" do
      should "work" do
        get artist_commentary_version_path(@commentary1.versions.first)
        assert_redirected_to artist_commentary_versions_path(search: { post_id: @commentary1.post_id })

        get artist_commentary_version_path(@commentary1.versions.first), as: :json
        assert_response :success
      end
    end
  end
end
