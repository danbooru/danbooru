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

    context "diff_name_html method" do
      should "render pure addition when previous name is blank" do
        assert_equal("<ins>foo</ins>", diff_name_html("foo", ""))
        assert_equal("<ins>foo</ins>", diff_name_html("foo", nil))
      end

      should "render pure removal when current name is blank" do
        assert_equal("<del>foo</del>", diff_name_html("", "foo"))
        assert_equal("<del>foo</del>", diff_name_html(nil, "foo"))
      end

      should "return identical names unchanged" do
        assert_equal("foo", diff_name_html("foo", "foo"))
      end

      should "preserve common prefix and suffix around the changed middle" do
        # "foo_bar_baz" vs "foo_qux_baz": only the middle differs
        html = diff_name_html("foo_bar_baz", "foo_qux_baz")
        assert_match(/\Afoo_/, html)
        assert_match(/_baz\z/, html)
        assert_includes(html, "<ins>")
        assert_includes(html, "<del>")
      end

      should "wholesale-replace very dissimilar names" do
        assert_equal("<del>xyz</del><ins>abc</ins>", diff_name_html("abc", "xyz"))
      end

      should "html-escape names so raw markup cannot leak through" do
        html = diff_name_html("<x>", "<y>")
        refute_includes(html, "<x>")
        refute_includes(html, "<y>")
        assert_includes(html, "&lt;")
        assert_includes(html, "&gt;")
      end
    end

    context "diff_body_html method" do
      should "format the present side when one record is blank" do
        html = diff_body_html({ body: "hello\nworld" }, {}, :body)
        assert_includes(html, "paragraph-mark")
        assert_includes(html, "hello")
        assert_includes(html, "world")
      end

      should "wholesale-replace short, very dissimilar bodies" do
        html = diff_body_html({ body: "totally different content here" }, { body: "x" * 30 }, :body)
        assert_includes(html, "<del>")
        assert_includes(html, "<ins>")
      end

      should "skip the levenshtein shortcut for bodies above the size cap" do
        # Regression guard: pre-fix this would run an O(n*m) pure-Ruby Levenshtein on
        # full wiki bodies (up to MAX_WIKI_LENGTH = 80_000), hanging the worker.
        ::DidYouMean::Levenshtein.expects(:distance).never

        new_rec = { body: "a" * 6_000 }
        old_rec = { body: "b" * 6_000 }
        assert_nothing_raised { diff_body_html(new_rec, old_rec, :body) }
      end
    end
  end
end
