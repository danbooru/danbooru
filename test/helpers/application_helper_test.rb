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

    context "diff_body_html method" do
      should "treat HTML tags as single tokens" do
        assert_equal("<del>&lt;i&gt;</del><ins>&lt;b&gt;</ins>foo<del>&lt;/i&gt;</del><ins>&lt;/b&gt;</ins> bar", diff_body_html({ body: "<b>foo</b> bar" }, { body: "<i>foo</i> bar" }, :body))
        assert_equal("a <del>&lt; b or c &gt;</del><ins>&lt; b and c &gt;</ins> d", diff_body_html({ body: "a < b and c > d" }, { body: "a < b or c > d" }, :body))
        assert_equal('x &lt;y<span class="paragraph-mark">¶</span><br>z&gt; <del>v</del><ins>w</ins>', diff_body_html({ body: "x <y\nz> w" }, { body: "x <y\nz> v" }, :body))
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
  end
end
