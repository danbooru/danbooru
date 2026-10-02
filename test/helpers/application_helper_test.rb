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

    context "diff helpers" do
      should "pass names and body fields in old-to-new order" do
        assert_equal("foo_<del>old</del><ins>new</ins>", diff_name_html("foo_new", "foo_old"))
        assert_equal(
          "<del>old</del><ins>new</ins> body",
          diff_body_html({ body: "new body" }, { body: "old body" }, :body),
        )
      end

      should "render a missing comparison record without change tags" do
        html = diff_body_html({ body: %{<b>&"'\n}.html_safe }, nil, :body)

        assert_equal("&lt;b&gt;&amp;&quot;&#39;<span class=\"paragraph-mark\">¶</span><br>", html)
        assert_predicate(html, :html_safe?)
        assert_equal("old body", diff_body_html(nil, { body: "old body" }, :body))
        assert_equal("", diff_body_html(nil, nil, :body))
      end
    end
  end
end
