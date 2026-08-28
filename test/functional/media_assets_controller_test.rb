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

      context "searching for a media asset the user can't see" do
        setup do
          @post = create(:post, is_banned: true)
          @hidden_asset = @post.media_asset
          @user = create(:user)
        end

        should "not allow partial searches by non-moderators" do
          %i[md5 pixel_hash file_key].product(%w[like regex]).each do |attr, op|
            right, wrong = [@hidden_asset[attr].first(4), "!!!!"].map { |prefix| (op == "like") ? "#{prefix}*" : "^#{prefix}" }

            get_auth media_assets_path(search: { "#{attr}_#{op}": right }), @user, as: :json
            right_ids = response.parsed_body.pluck("id")
            get_auth media_assets_path(search: { "#{attr}_#{op}": wrong }), @user, as: :json

            assert_equal(right_ids, response.parsed_body.pluck("id"), "#{attr}_#{op}")
          end
        end

        should "allow exact searches by non-moderators" do
          get_auth media_assets_path(search: { md5: @hidden_asset.md5 }), @user, as: :json

          assert_equal([@hidden_asset.id], response.parsed_body.pluck("id"))
        end

        should "allow partial searches by moderators" do
          get_auth media_assets_path(search: { md5_like: "#{@hidden_asset.md5.first(4)}*" }), create(:moderator_user), as: :json

          assert_equal([@hidden_asset.id], response.parsed_body.pluck("id"))
        end

        should "not allow range searches in ai_tags_match by non-moderators" do
          %w[md5 pixelhash].each do |metatag|
            get_auth media_assets_path(search: { id: @hidden_asset.id, ai_tags_match: "#{metatag}:>=#{"0" * 32}" }), @user, as: :json

            assert_equal([], response.parsed_body.pluck("id"), metatag)
          end
        end

        should "allow range searches in ai_tags_match by moderators" do
          get_auth media_assets_path(search: { id: @hidden_asset.id, ai_tags_match: "md5:>=#{"0" * 32}" }), create(:moderator_user), as: :json

          assert_equal([@hidden_asset.id], response.parsed_body.pluck("id"))
        end
      end

      context "the limit param" do
        setup do
          create_list(:media_asset, 2)
          @user = create(:user, per_page: 2)
        end

        should "use the user's per page setting by default" do
          get_auth media_assets_path, @user, as: :json
          assert_equal(2, response.parsed_body.size)
        end

        should "use the limit param" do
          get_auth media_assets_path(limit: 1), @user, as: :json
          assert_equal(1, response.parsed_body.size)
        end

        should "use the user's per page setting for a blank limit param" do
          get_auth media_assets_path(limit: ""), @user, as: :json
          assert_equal(2, response.parsed_body.size)
        end
      end

      should "use the default size" do
        get media_assets_path

        assert_response :success
        assert_select ".media-asset-preview-180"
      end

      should "use the size URL param" do
        get media_assets_path(size: 225)

        assert_response :success
        assert_select ".media-asset-preview-225"
      end

      should "use the size cookie" do
        cookies[:post_preview_size] = "225"
        get media_assets_path

        assert_response :success
        assert_select ".media-asset-preview-225"
      end

      should respond_to_search.with { @media_asset }
      should respond_to_search(metadata: { "File:ColorComponents" => 3 }).with { @media_asset }
      should respond_to_search(metadata: { "File:ColorComponents" => 4 }).with { [] }

      should "follow the show page's prev/next pagination links" do
        @asset1, @asset2, @asset3, @asset4, @asset5 = create_list(:media_asset, 5).sort_by(&:id)

        # left arrow (data-shortcut="a"): jumps to the next higher id.
        get media_assets_path(search: { id: ">#{@asset3.id}", order: "id_asc" }, limit: 1, redirect: true)
        assert_redirected_to media_asset_path(@asset4)

        follow_redirect!
        assert_response :success

        # right arrow (data-shortcut="d"): jumps to the next lower id.
        get media_assets_path(search: { id: "<#{@asset3.id}", order: "id_desc" }, limit: 1, redirect: true)
        assert_redirected_to media_asset_path(@asset2)

        follow_redirect!
        assert_response :success
      end
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

      should "embed Flash files in a sandboxed iframe" do
        @media_asset = create(:media_asset, file_ext: "swf")
        get media_asset_path(@media_asset)

        assert_response :success
        assert_select "iframe.flash-player[sandbox=allow-scripts][srcdoc*=?]", @media_asset.variant(:original).file_url
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

      should "show all upload IDs to a mod" do
        get_auth media_asset_path(@upload1.media_assets.first), create(:moderator_user)
        assert_select "a[href='/uploads/#{@upload1.id}']", count: 1, text: "##{@upload1.id}"
        assert_select "a[href='/uploads/#{@upload2.id}']", count: 1, text: "##{@upload2.id}"
      end

      should "let superadmins resize and reencode the image" do
        @media_asset = MediaAsset.upload!("test/files/jpg/test.jpg")
        get_auth media_asset_path(@media_asset, format: :webp, width: 100, height: 67), create(:superadmin_user)

        assert_response :success
        assert_equal("image/webp", response.media_type)
      end

      should "not let admins resize and reencode the image" do
        @media_asset = MediaAsset.upload!("test/files/jpg/test.jpg")
        get_auth media_asset_path(@media_asset, format: :webp, width: 100, height: 67), create(:admin_user)

        assert_not_equal("image/webp", response.media_type)
      end
    end

    context "destroy action" do
      should "delete the asset's files" do
        @admin = create(:admin_user)
        @media_asset = MediaAsset.upload!("test/files/jpg/test.jpg")
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
