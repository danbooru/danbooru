require 'test_helper'

class UploadsMediaAssetsControllerTest < ActionDispatch::IntegrationTest
  context "The uploads media assets controller" do
    context "index action" do
      should "work" do
        create(:upload)
        get upload_media_assets_path

        assert_response :success
      end
    end

    context "show action" do
      should "show the uploader their own upload" do
        @upload_media_asset = create(:upload_media_asset)
        get_auth upload_media_asset_path(@upload_media_asset), @upload_media_asset.upload.uploader

        assert_response :success
      end

      should "not show someone else's uploads" do
        @upload_media_asset = create(:upload_media_asset)
        get upload_media_asset_path(@upload_media_asset)

        assert_response 403
      end
    end
  end
end
