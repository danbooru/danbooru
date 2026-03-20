require "test_helper"

class UploadPostComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  def render_upload_post_component(upload_media_asset, post: nil, current_user: upload_media_asset.user)
    post ||= build(:post, media_asset: upload_media_asset.media_asset, artist_commentary: build(:artist_commentary))

    render_inline(UploadPostComponent.new(upload_media_asset:, post:, current_user:))
  end

  context "The UploadPostComponent" do
    should "render the loading state" do
      upload_media_asset = create(:upload_media_asset, status: "processing")

      render_upload_post_component(upload_media_asset)

      assert_text("Processing")
    end

    should "render the failed state" do
      upload_media_asset = create(:upload_media_asset, status: "failed", error: "Not an image")

      render_upload_post_component(upload_media_asset)

      assert_text("Error: Not an image.")
    end

    should "show a non-web source warning for file uploads" do
      upload = create(:completed_file_upload)

      render_upload_post_component(upload.upload_media_assets.first)

      assert_css(".upload-warning-badges .upload-no-source-warning")
      assert_css(".upload-warning-details .upload-no-source-warning")
    end

    should "show an image sample warning for image samples" do
      upload = create(:completed_source_upload, upload_media_assets: [build(:upload_media_asset, source_url: "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg", status: "active")])

      render_upload_post_component(upload.upload_media_assets.first)

      assert_css(".upload-warning-badges .upload-sample-warning")
      assert_css(".upload-warning-details .upload-sample-warning")
      assert_css(".upload-warning-details .upload-sample-warning a[href='#{wiki_page_path("help:pixiv")}']")
    end

    should "show a bad source warning for bad source uploads" do
      upload = create(:completed_source_upload, upload_media_assets: [build(:upload_media_asset, source_url: "https://pbs.twimg.com/media/FQjQA1mVgAMcHLv.jpg:orig", status: "active")])

      render_upload_post_component(upload.upload_media_assets.first)

      assert_css(".upload-warning-badges .upload-bad-source-warning")
      assert_css(".upload-warning-details .upload-bad-source-warning")
      assert_css(".upload-warning-details .upload-bad-source-warning a[href='#{wiki_page_path("help:twitter")}']")
    end

    should "show an ai-generated warning for ai-generated files" do
      media_asset = build(:media_asset, file_ext: "png", media_metadata: build(:media_metadata, metadata: { "PNG:Software" => "NovelAI" }))
      upload = create(:completed_file_upload, upload_media_assets: [build(:upload_media_asset, media_asset: media_asset, status: "active")])

      render_upload_post_component(upload.upload_media_assets.first)

      assert_css(".upload-warning-badges .upload-ai-warning")
      assert_css(".upload-warning-details .upload-ai-warning")
    end

    should "show a duplicate warning for a single pixel-perfect duplicate" do
      upload = create(:completed_source_upload)
      create(:post, media_asset: build(:media_asset, pixel_hash: upload.media_assets.first.pixel_hash))

      render_upload_post_component(upload.upload_media_assets.first)

      assert_css(".upload-warning-badges .upload-pixel-perfect-duplicate-warning")
      assert_css(".upload-warning-details .upload-pixel-perfect-duplicate-warning")
    end

    should "show a duplicate warning for multiple pixel-perfect duplicates" do
      upload = create(:completed_source_upload)
      create(:post, media_asset: build(:media_asset, pixel_hash: upload.media_assets.first.pixel_hash))
      create(:post, media_asset: build(:media_asset, pixel_hash: upload.media_assets.first.pixel_hash))

      render_upload_post_component(upload.upload_media_assets.first)

      assert_css(".upload-warning-badges .upload-pixel-perfect-duplicate-warning")
      assert_css(".upload-warning-details .upload-pixel-perfect-duplicate-warning")
    end
  end
end
