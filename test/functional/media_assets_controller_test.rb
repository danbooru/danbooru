require "test_helper"

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
      setup do
        @user1 = create(:user)
        @user2 = create(:user)
        @upload1 = create(:completed_source_upload, uploader: @user1)
        @upload2 = create(:completed_source_upload, uploader: @user2, upload_media_assets: [build(:upload_media_asset, media_asset: @upload1.media_assets.first)])
      end

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

      should "show a user their own upload ID" do
        get_auth media_asset_path(@upload1.media_assets.first), @user1
        assert_select "a[href='/uploads/#{@upload1.id}']", count: 1, text: "##{@upload1.id}"

        get_auth media_asset_path(@upload2.media_assets.first), @user2
        assert_select "a[href='/uploads/#{@upload2.id}']", count: 1, text: "##{@upload2.id}"
      end

      should "not show a user's upload ID to another user" do
        get_auth media_asset_path(@upload2.media_assets.first), @user1
        assert_select "a[href='/uploads/#{@upload2.id}']", count: 0

        get_auth media_asset_path(@upload1.media_assets.first), @user2
        assert_select "a[href='/uploads/#{@upload1.id}']", count: 0
      end

      should "show all upload IDs to an admin" do
        get_auth media_asset_path(@upload1.media_assets.first), create(:admin_user)
        assert_select "a[href='/uploads/#{@upload1.id}']", count: 1, text: "##{@upload1.id}"
        assert_select "a[href='/uploads/#{@upload2.id}']", count: 1, text: "##{@upload2.id}"
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
