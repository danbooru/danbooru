require 'test_helper'

module Sources
  class DeviantArtTest < ActiveSupport::TestCase
    context "The source for a private DeviantArt image URL" do
      setup do
        @site = Sources::Site.new("https://pre00.deviantart.net/423b/th/pre/i/2017/281/e/0/mindflayer_girl01_by_nickbeja-dbpxdt8.png")
        @site.get
      end

      should "work" do
        assert_equal(["https://pre00.deviantart.net/423b/th/pre/i/2017/281/e/0/mindflayer_girl01_by_nickbeja-dbpxdt8.png"], @site.image_urls)
      end
    end

    context "The source for a download-disabled DeviantArt artwork page" do
      should "get the image url" do
        @site = Sources::Site.new("https://noizave.deviantart.com/art/test-no-download-697415967")
        assert_equal(["https://img00.deviantart.net/56ee/i/2017/219/2/3/test__no_download_by_noizave-dbj81lr.jpg"], @site.image_urls)
      end
    end

    context "The source for a DeviantArt image url" do
      should "fetch the source data" do
        @site = Sources::Site.new("https://pre00.deviantart.net/b5e6/th/pre/f/2016/265/3/5/legend_of_galactic_heroes_by_hideyoshi-daihpha.jpg")

        assert_equal("hideyoshi", @site.artist_name)
        assert_equal("https://hideyoshi.deviantart.com", @site.profile_url)
        assert_equal("https://orig00.deviantart.net/9e1f/f/2016/265/3/5/legend_of_galactic_heroes_by_hideyoshi-daihpha.jpg", @site.image_url)
      end
    end

    context "The source for an DeviantArt artwork page" do
      setup do
        @site = Sources::Site.new("http://noizave.deviantart.com/art/test-post-please-ignore-685436408")
        @site.get
      end

      should "get the image url" do
        assert_match(%r!https?://origin-orig.deviantart.net/7b5b/f/2017/160/c/5/test_post_please_ignore_by_noizave-dbc3a48.png!, @site.image_url)
      end

      should "get the profile" do
        assert_equal("https://noizave.deviantart.com", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("noizave", @site.artist_name)
      end

      should "get the tags" do
        assert_equal(%w[bar baz foo], @site.tags.map(&:first))
      end

      should "get the artist commentary" do
        title = "test post please ignore"
        desc = "<div align=\"center\"><span>blah blah<br /><div align=\"left\"><a class=\"external\" href=\"https://www.deviantart.com/users/outgoing?http://www.google.com\">test link</a><br /></div></span></div><br /><h1>lol</h1><br /><br /><b>blah</b>&nbsp;<i>blah</i>&nbsp;<u>blah</u>&nbsp;<strike>blah</strike><br />herp derp<br /><br /><blockquote>this is a quote</blockquote><ol><li>one</li><li>two</li><li>three</li></ol><ul><li>one</li><li>two</li><li>three</li></ul><img src=\"https://e.deviantart.net/emoticons/h/heart.gif\" alt=\"Heart\" style=\"width: 15px; height: 13px;\" data-embed-type=\"emoticon\" data-embed-id=\"357\">&nbsp;&nbsp;"

        assert_equal(title, @site.artist_commentary_title)
        assert_equal(desc, @site.artist_commentary_desc)
      end

      should "get the dtext-ified commentary" do
        desc = <<-EOS.strip_heredoc.chomp
          blah blah
          "test link":[http://www.google.com]

          h1. lol



          [b]blah[/b] [i]blah[/i] [u]blah[/u] [s]blah[/s]
          herp derp
          
          [quote]this is a quote[/quote]
          
          * one
          * two
          * three
          
          * one
          * two
          * three
          
          "Heart":[https://e.deviantart.net/emoticons/h/heart.gif]
        EOS

        assert_equal(desc, @site.dtext_artist_commentary_desc)
      end
    end

    context "The source for a login-only DeviantArt artwork page" do
      setup do
        @site = Sources::Site.new("http://noizave.deviantart.com/art/hidden-work-685458369")
        @site.get
      end

      should "get the image url" do
        assert_match(%r!https?://origin-orig\.deviantart\.net/cb25/f/2017/160/1/9/hidden_work_by_noizave-dbc3r29\.png!, @site.image_url)
      end
    end

    context "A source with malformed links in the artist commentary" do
      should "fix the links" do
        @site = Sources::Site.new("https://teemutaiga.deviantart.com/art/Kisu-620666655")
        @site.get

        assert_match(%r!"Print available at Inprnt":\[http://www.inprnt.com/gallery/teemutaiga/kisu\]!, @site.dtext_artist_commentary_desc)
      end
    end
  end
end
