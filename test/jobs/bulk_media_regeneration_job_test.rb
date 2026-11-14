require "test_helper"

class BulkMediaRegenerationJobTest < ActiveSupport::TestCase
  context "BulkMediaRegenerationJob" do
    should "regenerate the metadata, files, and post tags for matching assets" do
      @post = create(:post_with_file, filename: "png/test-rotation-good-chunk.png")
      @media_asset = @post.media_asset
      assert_includes(@post.tag_array, "exif_rotation")

      # Simulate a bug where the pre-rotation width, height, and metadata were stored instead of the rotated ones.
      @media_asset.media_metadata.update_column(:metadata, {}) # rubocop:disable Rails/SkipsModelValidations
      @media_asset.update_columns(image_width: 128, image_height: 64) # rubocop:disable Rails/SkipsModelValidations
      CurrentUser.scoped(User.system) do
        @post.update!(image_width: 128, image_height: 64, tag_string: @post.tag_string.gsub("exif_rotation", ""))
      end
      assert_not_includes(@post.reload.tag_array, "exif_rotation")

      BulkMediaRegenerationJob.perform_now(query: "id:#{@media_asset.id}")
      @media_asset.reload
      @post.reload

      assert_equal(64, @media_asset.image_width)
      assert_equal(128, @media_asset.image_height)
      assert_equal(64, @post.image_width)
      assert_equal(128, @post.image_height)
      assert_includes(@post.tag_array, "exif_rotation")
    end

    should "not regenerate assets that don't match the query" do
      @post = create(:post_with_file, filename: "png/test-rotation-good-chunk.png")
      @media_asset = @post.media_asset
      @media_asset.update_columns(image_width: 128, image_height: 64) # rubocop:disable Rails/SkipsModelValidations

      BulkMediaRegenerationJob.perform_now(query: "id:#{@media_asset.id + 1}")

      assert_equal(128, @media_asset.reload.image_width)
    end

    should "not abort the whole batch if one asset fails to regenerate" do
      create(:media_asset, file_ext: "png")
      create(:media_asset, file_ext: "png")

      MediaAsset.any_instance.stubs(:regenerate!).raises(StandardError, "boom")

      assert_nothing_raised do
        BulkMediaRegenerationJob.perform_now(query: "filetype:png")
      end
    end
  end
end
