require 'test_helper'

class ArtistCommentaryVersionsControllerTest < ActionDispatch::IntegrationTest
  context "The artist commentary versions controller" do
  	setup do
      @user = FactoryBot.create(:user)

      as_user do
        @commentary1 = FactoryBot.create(:artist_commentary)
        @commentary2 = FactoryBot.create(:artist_commentary)
      end
  	end

    context "index action" do
      should "render" do
        get artist_commentary_versions_path
        assert_response :success
      end
    end
  end
end
