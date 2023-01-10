require 'test_helper'

class MediaAssetTest < ActiveSupport::TestCase
  def assert_tag_match(assets, query)
    assert_equal(assets.map(&:id), MediaAsset.ai_tags_match(query).order(id: :desc).pluck("id"))
  end

  context "MediaAsset" do
    context "searching" do
      setup do
        @asset1 = create(:media_asset, image_width: 720, image_height: 1280, file_size: 1.megabyte, file_ext: "jpg", created_at: Time.zone.now, media_metadata: build(:media_metadata, metadata: { "File:FileType" => "JPEG" }))
        @asset2 = create(:media_asset, image_width: 1920, image_height: 1080, file_size: 2.megabytes, file_ext: "png", duration: 3.0, created_at: Time.zone.parse("2022-01-01"), media_metadata: build(:media_metadata, metadata: { "File:FileType" => "PNG" }))
        @tag = build(:tag, name: "rating:g")
        @tag.save(validate: false)
        @ai_tag = create(:ai_tag, media_asset: @asset1, tag: @tag, score: 100)
      end

      should "return assets for the id: metatag" do
        assert_tag_match([@asset1], "id:#{@asset1.id}")
      end

      should "return assets for the md5: metatag" do
        assert_tag_match([@asset1], "md5:#{@asset1.md5}")
      end

      should "return assets for the width: metatag" do
        assert_tag_match([@asset1], "width:#{@asset1.image_width}")
      end

      should "return assets for the height: metatag" do
        assert_tag_match([@asset1], "height:#{@asset1.image_height}")
      end

      should "return assets for the duration: metatag" do
        assert_tag_match([@asset2], "duration:3")
      end

      should "return assets for the mpixels: metatag" do
        assert_tag_match([@asset1], "mpixels:#{(@asset1.image_width * @asset1.image_height) / 1_000_000.0}")
      end

      should "return assets for the ratio: metatag" do
        assert_tag_match([@asset1], "ratio:#{@asset1.image_width.to_f / @asset1.image_height}")
      end

      should "return assets for the filesize: metatag" do
        assert_tag_match([@asset1], "filesize:1mb")
      end

      should "return assets for the filetype: metatag" do
        assert_tag_match([@asset1], "filetype:jpg")
      end

      should "return assets for the date: tag" do
        assert_tag_match([@asset2], "date:2022-01-01")
      end

      should "return assets for the age: tag" do
        assert_tag_match([@asset1], "age:<1minute")
      end

      should "return assets for the status: tag" do
        assert_tag_match([@asset2, @asset1], "status:active")
      end

      should "return assets for the is: tag" do
        assert_tag_match([@asset1], "is:jpg")
        assert_tag_match([@asset2, @asset1], "is:active")
      end

      should "return assets for the exif: tag" do
        assert_tag_match([@asset2, @asset1], "exif:File:FileType")
        assert_tag_match([@asset1], "exif:File:FileType=JPEG")
      end

      should "treat unsupported metatags as regular tags" do
        assert_tag_match([@asset1], "rating:g")
        assert_tag_match([], "pool:none")
        assert_tag_match([], "parent:none")
        assert_tag_match([], "user:bkub")
        assert_tag_match([], "fav:bkub")
      end
    end
  end
end
