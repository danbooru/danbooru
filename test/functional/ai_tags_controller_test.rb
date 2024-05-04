require 'test_helper'

class AITagsControllerTest < ActionDispatch::IntegrationTest
  context "The AI tags controller" do
    context "index action" do
      setup do
        @tag1 = create(:tag, name: "solo")
        @tag2 = build(:tag, name: "rating:g").save!(validate: false)

        @posted_asset1 = create(:media_asset)
        @posted_asset2 = create(:media_asset)
        @unposted_asset1 = create(:media_asset)
        @unposted_asset2 = create(:media_asset)

        @post1 = create(:post, media_asset: @posted_asset1, tag_string: "solo", rating: "e")
        @post2 = create(:post, media_asset: @posted_asset2, tag_string: "tagme", rating: "g")

        @user = create(:user)

        MediaAsset.all.to_a.product(Tag.all.to_a).each do |asset, tag|
          create(:ai_tag, tag: tag, media_asset: asset)
        end
      end

      should "render the gallery view for anonymous users" do
        get ai_tags_path
        assert_response :success
      end

      should "render the gallery view for Members" do
        get_auth ai_tags_path, @user
        assert_response :success
      end

      should "render the table view" do
        get_auth ai_tags_path(mode: "table"), @user
        assert_response :success
      end

      should "render for search[is_posted]=true" do
        get_auth ai_tags_path(search: { is_posted: true }), @user
        assert_response :success
      end

      should "render for search[is_posted]=false" do
        get_auth ai_tags_path(search: { is_posted: false }), @user
        assert_response :success
      end
    end

    context "tag action" do
      setup do
        @post = create(:post, rating: "g")
        @tag = create(:tag, name: "touhou")
        @ai_tag = create(:ai_tag, media_asset: @post.media_asset, tag: @tag)
        @user = create(:user)
      end

      should "work for removing an AI tag" do
        @post.update!(tag_string: "touhou")
        put_auth tag_ai_tag_path(media_asset_id: @ai_tag.media_asset, tag_id: @ai_tag.tag), @user, params: { mode: "remove" }, xhr: true

        assert_response :success
        assert_equal(false, @post.reload.has_tag?("touhou"))
      end

      should "work for adding an AI tag" do
        put_auth tag_ai_tag_path(media_asset_id: @ai_tag.media_asset, tag_id: @ai_tag.tag), @user, params: { mode: "add" }, xhr: true

        assert_response :success
        assert_equal(true, @post.reload.has_tag?("touhou"))
      end

      should "work for adding a custom tag" do
        put_auth tag_ai_tag_path(media_asset_id: @ai_tag.media_asset, tag_id: @ai_tag.tag), @user, params: { tag: "rating:e" }, xhr: true

        assert_response :success
        assert_equal("e", @post.reload.rating)
      end

      should "not allow unauthorized users to edit tags" do
        put tag_ai_tag_path(media_asset_id: @ai_tag.media_asset, tag_id: @ai_tag.tag), params: { mode: "add" }, xhr: true

        assert_response 403
        assert_equal(false, @post.reload.has_tag?("touhou"))
      end
    end
  end
end
