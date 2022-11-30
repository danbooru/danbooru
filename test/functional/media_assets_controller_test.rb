require 'test_helper'

class MediaAssetsControllerTest < ActionDispatch::IntegrationTest
  context "The media assets controller" do
    context "index action" do
      setup do
        @media_asset = create(:media_asset)
      end

      should "render" do
        get media_assets_path, as: :json

        assert_response :success
      end

      should respond_to_search({}).with { @media_asset }
      should respond_to_search(metadata: { "File:ColorComponents" => 3 }).with { @media_asset }
      should respond_to_search(metadata: { "File:ColorComponents" => 4 }).with { [] }
    end

    context "show action" do
      should "render" do
        @media_asset = create(:media_asset)
        @ai_tags = create_list(:ai_tag, 10, media_asset: @media_asset)

        get media_asset_path(@media_asset)

        assert_response :success
      end

      should "not show the md5 for assets belonging to posts not visible to the current user" do
        @media_asset = create(:media_asset)
        @post = create(:post, md5: @media_asset.md5, is_banned: true)
        get media_asset_path(@media_asset), as: :json

        assert_response :success
        assert_nil(response.parsed_body[:md5])
      end

      should "work for a deleted asset" do
        @media_asset = create(:media_asset, status: "deleted", media_metadata: nil)
        get media_asset_path(@media_asset)

        assert_response :success
      end
    end

    context "destroy action" do
      should "delete the asset's files" do
        @admin = create(:admin_user)
        @media_asset = MediaAsset.upload!("test/files/test.jpg")
        delete_auth media_asset_path(@media_asset), @admin

        assert_redirected_to @media_asset

        assert_equal("deleted", @media_asset.reload.status)
        @media_asset.variants.each do |variant|
          assert_nil(variant.open_file)
        end

        assert_equal(1, ModAction.count)
        assert_equal("media_asset_delete", ModAction.last.category)
        assert_equal(@media_asset, ModAction.last.subject)
        assert_equal(@admin, ModAction.last.creator)
      end

      should "fail for non-admins" do
        @media_asset = create(:media_asset)
        delete_auth media_asset_path(@media_asset), create(:user)

        assert_response 403
      end
    end
  end
end
