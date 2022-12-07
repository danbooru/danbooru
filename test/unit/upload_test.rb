require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  def assert_tag_match(uploads, query)
    assert_equal(uploads.map(&:id), Upload.ai_tags_match(query).order(id: :desc).pluck("id"))
  end

  context "Upload" do
    context "searching" do
      setup do
        @asset1 = create(:media_asset, image_width: 720, image_height: 1280, file_size: 1.megabyte, file_ext: "jpg", media_metadata: build(:media_metadata, metadata: { "File:FileType" => "JPEG" }))
        @asset2 = create(:media_asset, image_width: 1920, image_height: 1080, file_size: 2.megabytes, file_ext: "png", duration: 3.0, media_metadata: build(:media_metadata, metadata: { "File:FileType" => "PNG" }))

        @uma1 = build(:upload_media_asset, media_asset: @asset1, status: "active", created_at: Time.zone.now)
        @uma2 = build(:upload_media_asset, media_asset: @asset2, status: "active", created_at: Time.parse("2022-01-01"))

        @upload1 = create(:upload, created_at: Time.zone.now, upload_media_assets: [@uma1])
        @upload2 = create(:upload, created_at: Time.parse("2022-01-01"), upload_media_assets: [@uma2])
      end

      should "return assets for the id: metatag" do
        assert_tag_match([@upload1], "id:#{@upload1.upload_media_assets.sole.id}")
      end

      should "return assets for the md5: metatag" do
        assert_tag_match([@upload1], "md5:#{@asset1.md5}")
      end

      should "return assets for the width: metatag" do
        assert_tag_match([@upload1], "width:#{@asset1.image_width}")
      end

      should "return assets for the height: metatag" do
        assert_tag_match([@upload1], "height:#{@asset1.image_height}")
      end

      should "return assets for the duration: metatag" do
        assert_tag_match([@upload2], "duration:3")
      end

      should "return assets for the mpixels: metatag" do
        assert_tag_match([@upload1], "mpixels:#{(@asset1.image_width * @asset1.image_height) / 1_000_000.0}")
      end

      should "return assets for the ratio: metatag" do
        assert_tag_match([@upload1], "ratio:#{@asset1.image_width.to_f / @asset1.image_height}")
      end

      should "return assets for the filesize: metatag" do
        assert_tag_match([@upload1], "filesize:1mb")
      end

      should "return assets for the filetype: metatag" do
        assert_tag_match([@upload1], "filetype:jpg")
      end

      should "return assets for the date: tag" do
        assert_tag_match([@upload2], "date:2022-01-01")
      end

      should "return assets for the age: tag" do
        assert_tag_match([@upload1], "age:<1minute")
      end

      should "return assets for the status: tag" do
        assert_tag_match([@upload2, @upload1], "status:active")
      end

      should "return assets for the is: tag" do
        assert_tag_match([@upload1], "is:jpg")
        assert_tag_match([@upload2, @upload1], "is:active")
      end

      should "return assets for the exif: tag" do
        assert_tag_match([@upload2, @upload1], "exif:File:FileType")
        assert_tag_match([@upload1], "exif:File:FileType=JPEG")
      end
    end
  end
end
