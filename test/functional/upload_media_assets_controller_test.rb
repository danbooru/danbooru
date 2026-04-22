require "test_helper"

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

    context "update action" do
      should "allow the uploader to hide their own upload" do
        @upload_media_asset = create(:upload_media_asset)
        put_auth upload_media_asset_path(@upload_media_asset), @upload_media_asset.upload.uploader, params: { upload_media_asset: { is_hidden: true } }

        assert_response :success
        assert_equal(true, @upload_media_asset.reload.is_hidden)
      end

      should "allow the uploader to unhide their own upload" do
        @upload_media_asset = create(:upload_media_asset, is_hidden: true)
        put_auth upload_media_asset_path(@upload_media_asset), @upload_media_asset.upload.uploader, params: { upload_media_asset: { is_hidden: false } }

        assert_response :success
        assert_equal(false, @upload_media_asset.reload.is_hidden)
      end

      should "not allow other users to hide someone else's upload" do
        @upload_media_asset = create(:upload_media_asset)
        put_auth upload_media_asset_path(@upload_media_asset), create(:user), params: { upload_media_asset: { is_hidden: true } }

        assert_response 403
        assert_equal(false, @upload_media_asset.reload.is_hidden)
      end
    end
  end
end
