require 'test_helper'

class MediaMetadataControllerTest < ActionDispatch::IntegrationTest
  context "The media metadata controller" do
    context "index action" do
      should "render" do
        create(:media_metadata)
        get media_metadata_path, as: :json

        assert_response :success
      end
    end
  end
end
