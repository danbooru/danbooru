require 'test_helper'

module Sources
  class DeviantArtTest < ActiveSupport::TestCase
    context "The source for an DeviantArt artwork page" do
      setup do
        @site = Sources::Site.new("http://noizave.deviantart.com/art/test-post-please-ignore-685436408")
        @site.get
      end

      should "get the image url" do
        assert_equal("http://orig02.deviantart.net/7b5b/f/2017/160/c/5/test_post_please_ignore_by_noizave-dbc3a48.png", @site.image_url)
      end

      should "get the profile" do
        assert_equal("http://noizave.deviantart.com/", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("noizave", @site.artist_name)
      end

      should "get the tags" do
        assert_equal(%w[bar baz foo], @site.tags.map(&:first))
      end

      should "get the artist commentary" do
        title = "test post please ignore"
        desc = "<div align=\"center\"><span>blah blah<br><div align=\"left\">\n<a class=\"external\" href=\"http://www.deviantart.com/users/outgoing?http://www.google.com\">test link</a><br>\n</div></span></div>\n<br><h1>lol</h1>\n<br><br><b>blah</b> <i>blah</i> <u>blah</u> <strike>blah</strike><br>herp derp<br><br><blockquote>this is a quote</blockquote>\n<ol>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ol>\n<ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>\n<img src=\"http://e.deviantart.net/emoticons/h/heart.gif\" alt=\"Heart\" style=\"width: 15px; height: 13px;\" data-embed-type=\"emoticon\" data-embed-id=\"357\">  "

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
          
          Heart  
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
        assert_equal("http://orig14.deviantart.net/cb25/f/2017/160/1/9/hidden_work_by_noizave-dbc3r29.png", @site.image_url)
      end
    end
  end
end
