require 'test_helper'

class MediaAssetsControllerTest < ActionDispatch::IntegrationTest
  context "The media assets controller" do
    context "index action" do
      should "render" do
        create(:media_asset)
        get media_assets_path, as: :json

        assert_response :success
      end
    end
  end
end
