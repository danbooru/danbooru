require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  context "The application helper" do
    context "format_text method" do
      should "not raise an exception for invalid DText" do
        dtext = "\x00"

        assert_nothing_raised { format_text(dtext) }
        assert_equal("", format_text(dtext))
      end
    end

    context "link_to_media_asset method" do
      should "render link" do
        media_asset = create(:media_asset, file_ext: "jpg")
        link = link_to_media_asset(media_asset)
        text = "#{ActiveSupport::NumberHelper.number_to_human_size(media_asset.file_size)} .#{media_asset.file_ext}, " \
               "#{media_asset.image_width}x#{media_asset.image_height}"

        assert_match(/#{Regexp.quote(media_asset_path(media_asset))}/, link)
        assert_match(/#{Regexp.quote(text)}/, link)
      end

      should "render link with duration" do
        media_asset = create(:media_asset, file_ext: "mp4", duration: 30)
        link = link_to_media_asset(media_asset)
        text = "#{ActiveSupport::NumberHelper.number_to_human_size(media_asset.file_size)} .#{media_asset.file_ext}, " \
               "#{media_asset.image_width}x#{media_asset.image_height} " \
               "(#{Danbooru::Helpers.duration_to_hhmmss(media_asset.duration)})"

        assert_match(/#{Regexp.quote(media_asset_path(media_asset))}/, link)
        assert_match(/#{Regexp.quote(text)}/, link)
      end
    end

    context "humanized_duration method" do
      should "return forever" do
        assert_equal("forever", humanized_duration(100.years))
      end

      should "return unknown" do
        assert_equal("unknown", humanized_duration(-1.day))
      end

      should "return in days for values less than a month" do
        assert_equal("1 day", humanized_duration(1.month - 29.days))
      end

      should "return in months for values greater or equal than a month and less than a year" do
        assert_equal("1 month", humanized_duration(1.year - 11.months))
      end

      should "return in months for values greater or equal than a year and less than forever" do
        assert_equal("1 year", humanized_duration(100.years - 99.years))
      end

      should "return duration as it is for 0" do
        assert_equal("0 days", humanized_duration(0.days))
      end
    end
  end
end
