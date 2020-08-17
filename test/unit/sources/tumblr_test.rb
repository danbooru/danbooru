require 'test_helper'

module Sources
  class TumblrTest < ActiveSupport::TestCase
    def setup
      skip "Tumblr key is not configured" unless Sources::Strategies::Tumblr.enabled?
    end

    context "The source for a 'http://*.tumblr.com/post/*' photo post with a single image" do
      setup do
        @site = Sources::Strategies.find("https://noizave.tumblr.com/post/162206271767")
      end

      should "get the artist name" do
        assert_equal("noizave", @site.artist_name)
      end

      should "get the profile" do
        assert_equal("https://noizave.tumblr.com", @site.profile_url)
      end

      should "get the tags" do
        tags = ["tag", "red hair", "red-hair", "red_hair"]
        assert_equal(tags, @site.tags.map(&:first))
        assert_equal(["red_hair", "tag"], @site.normalized_tags)
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
        assert_equal("https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png", @site.image_url)
      end

      should "get the preview url" do
        assert_equal("https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_250.png", @site.preview_url)
      end

      should "get the canonical url" do
        assert_equal("https://noizave.tumblr.com/post/162206271767", @site.canonical_url)
      end

      should "get the artist" do
        CurrentUser.user = FactoryBot.create(:user)
        CurrentUser.ip_addr = "127.0.0.1"

        @artist = FactoryBot.create(:artist, name: "noizave", url_string: "https://noizave.tumblr.com/")
        assert_equal([@artist], @site.artists)
      end
    end

    context "The source for a 'http://*.tumblr.com/image/*' image page" do
      setup do
        @site = Sources::Strategies.find("https://noizave.tumblr.com/image/162206271767")
      end

      should "get the image url" do
        assert_equal("https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png", @site.image_url)
      end

      should "get the canonical url" do
        assert_equal("https://noizave.tumblr.com/post/162206271767", @site.canonical_url)
      end

      should "get the tags" do
        tags = ["tag", "red hair", "red-hair", "red_hair"]
        assert_equal(tags, @site.tags.map(&:first))
        assert_equal(["red_hair", "tag"], @site.normalized_tags)
      end
    end

    context "The source for a 'http://*.media.tumblr.com/$hash/tumblr_$id_540.jpg' image" do
      setup do
        @url = "https://78.media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_540.jpg"
        @ref = "https://noizave.tumblr.com/post/162094447052"
      end

      context "with a referer" do
        should "get all the images and metadata" do
          site = Sources::Strategies.find(@url, @ref)

          assert_equal("noizave", site.artist_name)
          assert_equal("https://noizave.tumblr.com", site.profile_url)
          assert_equal(["tag1", "tag2"], site.tags.map(&:first))
          assert_equal(@ref, site.canonical_url)
          assert_equal("https://media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_1280.jpg", site.image_url)
          assert_equal(%w[
            https://media.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_orwwptNBCE1wsfqepo1_1280.png
            https://media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_1280.jpg
            https://media.tumblr.com/d2ed224f135b0c81f812df81a0a8692d/tumblr_orwwptNBCE1wsfqepo3_640.gif
            https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_inline_os3134mABB1v11u29_1280.png
            https://media.tumblr.com/34ed9d0ff4a21625981372291cb53040/tumblr_nv3hwpsZQY1uft51jo1_1280.gif
          ], site.image_urls)
        end
      end

      context "without a referer" do
        should "get the original image" do
          site = Sources::Strategies.find(@url)

          assert_nil(site.artist_name)
          assert_nil(site.profile_url)
          assert_nil(site.canonical_url)
          assert_equal([], site.tags)
          assert_equal("https://media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_1280.jpg", site.image_url)
          assert_equal(["https://media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_1280.jpg"], site.image_urls)
        end
      end
    end

    context "The source for a 'http://*.tumblr.com/post/*' text post with inline images" do
      setup do
        @site = Sources::Strategies.find("https://noizave.tumblr.com/post/162221502947")
      end

      should "get the image urls" do
        urls = %w[
          https://media.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os2zhkfhY01v11u29_1280.png
          https://media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_inline_os2zkg02xH1v11u29_1280.jpg
        ]

        assert_equal(urls.sort, @site.image_urls.sort)
      end

      should "get the commentary" do
        desc = %r!<p>description</p><figure class="tmblr-full" data-orig-height="3000" data-orig-width="3000"><img src="https://\d+.media.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os2zhkfhY01v11u29_540.png" data-orig-height="3000" data-orig-width="3000"/></figure><figure class="tmblr-full" data-orig-height="3000" data-orig-width="3000"><img src="https://\d+.media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_inline_os2zkg02xH1v11u29_540.jpg" data-orig-height="3000" data-orig-width="3000"/></figure>!
        assert_equal("test post", @site.artist_commentary_title)
        assert_match(desc, @site.artist_commentary_desc)
      end
    end

    context "The source for a 'http://ve.media.tumblr.com/*' video post with inline images" do
      setup do
        @url = "https://va.media.tumblr.com/tumblr_os31dkexhK1wsfqep.mp4"
        @ref = "https://noizave.tumblr.com/post/162222617101"
      end

      context "with a referer" do
        should "get the video and inline images" do
          site = Sources::Strategies.find(@url, @ref)
          urls = %w[
            https://va.media.tumblr.com/tumblr_os31dkexhK1wsfqep.mp4
            https://media.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os31dclyCR1v11u29_1280.png
          ]

          assert_equal(@url, site.image_url)
          assert_equal(urls, site.image_urls)
          assert_equal(@ref, site.canonical_url)
        end
      end

      context "without a referer" do
        should "get the video" do
          site = Sources::Strategies.find(@url)

          assert_equal(@url, site.image_url)
          assert_equal([@url], site.image_urls)
          assert_nil(site.canonical_url)
        end
      end
    end

    context "The source for a 'http://*.tumblr.com/post/*' answer post with inline images" do
      setup do
        @site = Sources::Strategies.find("https://noizave.tumblr.com/post/171237880542/test-ask")
      end

      should "get the image urls" do
        urls = ["https://media.tumblr.com/cb481f031010e8ddad564b2150149c9a/tumblr_inline_p4nxoyLrSh1v11u29_1280.png"]
        assert_equal(urls, @site.image_urls)
      end

      should "get the commentary" do
        assert_equal("Anonymous asked: test ask", @site.artist_commentary_title)
        assert_match("test answer", @site.artist_commentary_desc)
      end

      should "get the canonical url" do
        assert_equal("https://noizave.tumblr.com/post/171237880542", @site.canonical_url)
      end
    end

    context "A Tumblr post with new image URLs" do
      should "return the correct image url" do
        image_url = "https://64.media.tumblr.com/3dfdab77d913ad1ea59f22407d6ac6f3/b1764aa0f9c378d0-23/s1280x1920/46f4af7ec94456f8fef380ee6311eb81178ce7e9.jpg"
        page_url = "https://make-do5.tumblr.com/post/619663949657423872"
        strategy = Sources::Strategies.find(image_url, page_url)

        assert_match(%r{/3dfdab77d913ad1ea59f22407d6ac6f3/b1764aa0f9c378d0-23/s\d+x\d+/}i, image_url)
        assert_equal(page_url, strategy.canonical_url)
        assert_downloaded(7_428_704, strategy.image_url)
      end
    end

    context "A deleted tumblr post" do
      should "extract the info from the url" do
        site = Sources::Strategies.find("http://shimetsukage.tumblr.com/post/176805588268/20180809-ssb-coolboy")

        assert_nothing_raised { site.to_h }
        assert_equal("shimetsukage", site.artist_name)
        assert_equal("https://shimetsukage.tumblr.com", site.profile_url)
        assert_equal("https://shimetsukage.tumblr.com/post/176805588268", site.page_url)
        assert_equal("https://shimetsukage.tumblr.com/post/176805588268", site.canonical_url)
        assert_nil(site.image_url)
        assert_equal([], site.image_urls)
        assert_equal([], site.tags)
      end
    end

    context "A download for a 'http://*.media.tumblr.com/$hash/tumblr_$id_$size.png' image" do
      should "find the largest image" do
        %w[100 250 400 500 500h 540 640 1280].each do |size|
          page = "https://natsuki-teru.tumblr.com/post/178728919271"
          image = "https://66.media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_#{size}.png"
          full = "https://media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_1280.png"
          site = Sources::Strategies.find(image, page)

          assert_equal(full, site.image_url)
          assert_equal(full, site.image_urls.second)
        end
      end
    end

    context "normalizing for source" do
      should "normalize correctly" do
        source1 = "https://octrain1020.tumblr.com/post/190713122589"
        source2 = "https://octrain1020.tumblr.com/image/190713122589"
        source3 = "https://octrain1020.tumblr.com/image/190713122589#asd"
        source4 = "https://superboin.tumblr.com/post/141169066579/photoset_iframe/superboin/tumblr_o45miiAOts1u6rxu8/500/false"

        assert_equal(source1, Sources::Strategies.normalize_source(source1))
        assert_equal(source1, Sources::Strategies.normalize_source(source2))
        assert_equal(source1, Sources::Strategies.normalize_source(source3))
        assert_equal("https://superboin.tumblr.com/post/141169066579", Sources::Strategies.normalize_source(source4))
      end

      should "avoid normalizing unnormalizable urls" do
        bad_source = "https://octrain1020.tumblr.com/"
        assert_equal(bad_source, Sources::Strategies.normalize_source(bad_source))
      end
    end
  end
end
