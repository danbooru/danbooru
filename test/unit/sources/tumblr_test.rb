require 'test_helper'

module Sources
  class TumblrTest < ActiveSupport::TestCase
    context "The source for a 'http://*.tumblr.com/post/*' photo post with a single image" do
      setup do
        @site = Sources::Site.new("https://noizave.tumblr.com/post/162206271767")
        @site.get
      end

      should "get the artist name" do
        assert_equal("noizave", @site.artist_name)
      end

      should "get the profile" do
        assert_equal("https://noizave.tumblr.com/", @site.profile_url)
      end

      should "get the tags" do
        tags = [["tag", "https://tumblr.com/tagged/tag"], ["red_hair", "https://tumblr.com/tagged/red-hair"]]
        assert_equal(tags, @site.tags)
      end

      should "get the commentary" do
        desc = <<~EOS.chomp
          <h2>header</h2>

          <hr><p>plain <b>bold</b> <i>italics</i> <strike>strike</strike></p>

          <!-- more -->

          <ol><li>one</li>
          <li>two</li>
          </ol><ul><li>one</li>
          <ul><li>two</li>
          </ul></ul><blockquote><p>quote</p></blockquote>

          <p><a href=\"http://www.google.com\">link</a></p>
        EOS

        assert_nil(@site.artist_commentary_title)
        assert_equal(desc, @site.artist_commentary_desc)
      end

      should "get the dtext-ified commentary" do
        desc = <<~EOS.chomp
          h2. header

          plain [b]bold[/b] [i]italics[/i] [s]strike[/s]

          * one
          * two

          * one
          * two

          [quote]quote[/quote]

          "link":[http://www.google.com]
        EOS

        assert_equal(desc, @site.dtext_artist_commentary_desc)
      end

      should "get the image url" do
        assert_equal("http://data.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_raw.png", @site.image_url)
      end

      should "get the artist" do
        CurrentUser.user = FactoryGirl.create(:user)
        CurrentUser.ip_addr = "127.0.0.1"

        @artist = FactoryGirl.create(:artist, name: "noizave", url_string: "https://noizave.tumblr.com/")
        assert_equal([@artist], @site.artists)
      end
    end

    context "The source for a 'http://*.tumblr.com/image/*' image page" do
      setup do
        @site = Sources::Site.new("https://noizave.tumblr.com/image/162206271767")
        @site.get
      end

      should "get the image url" do
        assert_equal("http://data.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_raw.png", @site.image_url)
      end

      should "get the tags" do
        tags = [["tag", "https://tumblr.com/tagged/tag"], ["red_hair", "https://tumblr.com/tagged/red-hair"]]
        assert_equal(tags, @site.tags)
      end
    end

    context "The source for a 'http://*.media.tumblr.com/$hash/tumblr_$id_1280.jpg' image with a referer" do
      setup do
        @url = "https://78.media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_1280.jpg"
        @ref = "https://noizave.tumblr.com/post/162094447052"
        @site = Sources::Site.new(@url, referer_url: @ref)
        @site.get
      end

      should "get the image urls" do
        urls = %w[
          http://data.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_orwwptNBCE1wsfqepo1_raw.png
          http://data.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_raw.jpg
          http://data.tumblr.com/d2ed224f135b0c81f812df81a0a8692d/tumblr_orwwptNBCE1wsfqepo3_raw.gif
          http://data.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_inline_os3134mABB1v11u29_raw.png
          http://data.tumblr.com/34ed9d0ff4a21625981372291cb53040/tumblr_nv3hwpsZQY1uft51jo1_raw.gif
        ]

        assert_equal(urls, @site.image_urls)
      end

      should "get the tags" do
        tags = [["tag1", "https://tumblr.com/tagged/tag1"], ["tag2", "https://tumblr.com/tagged/tag2"]]
        assert_equal(tags, @site.tags)
      end

      should "get the commentary" do
        desc = %r!<p>description</p><figure data-orig-width="1152" data-orig-height="648" class="tmblr-full"><img src="https://\d+.media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_inline_os3134mABB1v11u29_540.png" data-orig-width="1152" data-orig-height="648"/></figure><figure class="tmblr-full" data-orig-height="273" data-orig-width="300" data-tumblr-attribution="skeleton-war-draft:nYQhsQFR8-n3brTTGanKzA:Ze6nYj1umLk8W"><img src="https://\d+.media.tumblr.com/34ed9d0ff4a21625981372291cb53040/tumblr_nv3hwpsZQY1uft51jo1_400.gif" data-orig-height="273" data-orig-width="300"/></figure>!
        assert_match(desc, @site.artist_commentary_desc)
      end
    end

    context "The source for a 'http://*.tumblr.com/post/*' text post with inline images" do
      setup do
        @site = Sources::Site.new("https://noizave.tumblr.com/post/162221502947")
        @site.get
      end

      should "get the image urls" do
        urls = %w[
          http://data.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os2zhkfhY01v11u29_raw.png
          http://data.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_inline_os2zkg02xH1v11u29_raw.jpg
        ]

        assert_equal(urls, @site.image_urls)
      end

      should "get the commentary" do
        desc = %r!<p>description</p><figure class="tmblr-full" data-orig-height="3000" data-orig-width="3000"><img src="https://\d+.media.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os2zhkfhY01v11u29_540.png" data-orig-height="3000" data-orig-width="3000"/></figure><figure class="tmblr-full" data-orig-height="3000" data-orig-width="3000"><img src="https://\d+.media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_inline_os2zkg02xH1v11u29_540.jpg" data-orig-height="3000" data-orig-width="3000"/></figure>!
        assert_equal("test post", @site.artist_commentary_title)
        assert_match(desc, @site.artist_commentary_desc)
      end
    end

    context "The source for a 'http://*.tumblr.com/post/*' video post with inline images" do
      setup do
        @site = Sources::Site.new("https://noizave.tumblr.com/post/162222617101")
        @site.get
      end

      should "get the image urls" do
        urls = %w[
          https://vtt.tumblr.com/tumblr_os31dkexhK1wsfqep.mp4
          http://data.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os31dclyCR1v11u29_raw.png
        ]

        assert_equal(urls, @site.image_urls)
      end
    end

    context "The source for a 'http://*.tumblr.com/post/*' answer post with inline images" do
      setup do
        @site = Sources::Site.new("https://noizave.tumblr.com/post/171237880542/test-ask")
        @site.get
      end

      should "get the image urls" do
        urls = ["http://data.tumblr.com/cb481f031010e8ddad564b2150149c9a/tumblr_inline_p4nxoyLrSh1v11u29_raw.png"]
        assert_equal(urls, @site.image_urls)
      end

      should "get the commentary" do
        assert_equal("test ask", @site.artist_commentary_title)
        assert_match("test answer", @site.artist_commentary_desc)
      end
    end
  end
end
