require "test_helper"

module Sources
  class TumblrTest < ActiveSupport::TestCase
    def setup
      skip "Tumblr key is not configured" unless Source::Extractor::Tumblr.enabled?
    end

    context "The source for a 'http://*.tumblr.com/post/*' photo post with a single image" do
      commentary_desc = <<~EOS.chomp
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

      commentary_desc_dtext = <<~EOS.chomp
        h2. header

        plain [b]bold[/b] [i]italics[/i] [s]strike[/s]

        * one
        * two

        * one
        * two

        [quote]quote[/quote]

        "link":[http://www.google.com]
      EOS

      strategy_should_work(
        "https://noizave.tumblr.com/post/162206271767",
        image_urls: ["https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png"],
        page_url: "https://noizave.tumblr.com/post/162206271767",
        artist_name: "noizave",
        profile_url: "https://noizave.tumblr.com",
        tags: ["tag", "red hair", "red-hair", "red_hair"],
        normalized_tags: ["red_hair", "tag"],
        artist_commentary_title: nil,
        artist_commentary_desc: commentary_desc,
        dtext_artist_commentary_desc: commentary_desc_dtext
      )
    end

    context "The source for a 'http://*.tumblr.com/image/*' image page" do
      strategy_should_work(
        "https://noizave.tumblr.com/image/162206271767",
        image_urls: ["https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png"],
        page_url: "https://noizave.tumblr.com/post/162206271767",
        tags: ["tag", "red hair", "red-hair", "red_hair"],
        normalized_tags: ["red_hair", "tag"]
      )
    end

    context "The source for a 'http://*.media.tumblr.com/$hash/tumblr_$id_540.jpg' image" do
      strategy_should_work(
        "https://78.media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_540.jpg",
        image_urls: ["https://media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_1280.jpg"],
        page_url: "https://noizave.tumblr.com/post/162094447052",
        artist_name: "noizave",
        profile_url: "https://noizave.tumblr.com",
        tags: ["tag1", "tag2"]
      )
    end

    context "The source for a 'http://*.tumblr.com/post/*' text post with inline images" do
      strategy_should_work(
        "https://noizave.tumblr.com/post/162221502947",
        image_urls: %w[
          https://media.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os2zhkfhY01v11u29_1280.png
          https://media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_inline_os2zkg02xH1v11u29_1280.jpg
        ],
        dtext_artist_commentary_title: "test post",
        artist_commentary_desc: %r{<p>description</p><figure class="tmblr-full" data-orig-height="3000" data-orig-width="3000"><img src="https://\d+.media.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os2zhkfhY01v11u29_540.png" data-orig-height="3000" data-orig-width="3000"/></figure><figure class="tmblr-full" data-orig-height="3000" data-orig-width="3000"><img src="https://\d+.media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_inline_os2zkg02xH1v11u29_540.jpg" data-orig-height="3000" data-orig-width="3000"/></figure>}
      )
    end

    context "A video post with inline images" do
      strategy_should_work(
        "https://noizave.tumblr.com/post/162222617101",
        image_urls: %w[
          https://va.media.tumblr.com/tumblr_os31dkexhK1wsfqep.mp4
          https://media.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os31dclyCR1v11u29_1280.png
        ]
      )
    end

    context "The source for a 'http://*.tumblr.com/post/*' answer post with inline images" do
      strategy_should_work(
        "https://noizave.tumblr.com/post/171237880542/test-ask",
        image_urls: ["https://media.tumblr.com/cb481f031010e8ddad564b2150149c9a/tumblr_inline_p4nxoyLrSh1v11u29_1280.png"],
        artist_commentary_title: "Anonymous asked: test ask",
        dtext_artist_commentary_desc: "test answer",
        page_url: "https://noizave.tumblr.com/post/171237880542"
      )
    end

    context "A Tumblr post with new image URLs" do
      strategy_should_work(
        "https://64.media.tumblr.com/3dfdab77d913ad1ea59f22407d6ac6f3/b1764aa0f9c378d0-23/s1280x1920/46f4af7ec94456f8fef380ee6311eb81178ce7e9.jpg",
        referer: "https://make-do5.tumblr.com/post/619663949657423872",
        page_url: "https://make-do5.tumblr.com/post/619663949657423872",
        image_urls: [%r{/3dfdab77d913ad1ea59f22407d6ac6f3/b1764aa0f9c378d0-23/s\d+x\d+/}i],
        download_size: 7_428_704
      )
    end

    context "A deleted tumblr post" do
      strategy_should_work(
        "http://shimetsukage.tumblr.com/post/176805588268/20180809-ssb-coolboy",
        deleted: true,
        artist_name: "shimetsukage",
        profile_url: "https://shimetsukage.tumblr.com",
        page_url: "https://shimetsukage.tumblr.com/post/176805588268",
        image_urls: [],
        tags: []
      )
    end

    %w[100 250 400 500 500h 540 640 1280].each do |size|
      context "A download for a 'http://*.media.tumblr.com/$hash/tumblr_$id_#{size}.png' image" do
        strategy_should_work(
          "https://66.media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_#{size}.png",
          referer: "https://natsuki-teru.tumblr.com/post/178728919271",
          image_urls: ["https://media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_1280.png"]
        )
      end
    end

    context "A *.media.tumblr.com/$hash/tumblr_$id_$size.png URL with a referer" do
      strategy_should_work(
        "https://64.media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_400.png",
        referer: "https://noizave.tumblr.com/post/162206271767",
        image_urls: ["https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png"],
        download_size: 3655
      )
    end

    context "A *.media.tumblr.com/tumblr_$id_$size.jpg URL with a referer" do
      strategy_should_work(
        "http://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_250.jpg",
        referer: "https://noizave.tumblr.com/post/162206271767",
        image_urls: ["https://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg"],
        download_size: 105_963
      )
    end

    context "A *.media.tumblr.com/tumblr_$id_$size.pnj URL" do
      strategy_should_work(
        "https://media.tumblr.com/701a535af224f89684d2cfcc097575ef/tumblr_pjsx70RakC1y0gqjko1_1280.pnj",
        image_urls: ["https://media.tumblr.com/701a535af224f89684d2cfcc097575ef/tumblr_pjsx70RakC1y0gqjko1_1280.pnj"],
        page_url: nil,
        artist_name: nil,
        download_size: 296_595
      )
    end

    context "A va.media.tumblr.com/tumblr_$id.mp4 URL" do
      strategy_should_work(
        "https://va.media.tumblr.com/tumblr_pgohk0TjhS1u7mrsl.mp4",
        image_urls: ["https://va.media.tumblr.com/tumblr_pgohk0TjhS1u7mrsl.mp4"],
        page_url: nil,
        artist_name: nil,
        download_size: 7_960_082
      )
    end

    context "A tumblr.com/$blog_name/$work_id URL" do
      strategy_should_work(
        "https://tumblr.com/munespice/683613396085719040",
        image_urls: ["https://64.media.tumblr.com/fd6b4692f6e902af861fbc242736ae61/010fd31ffbc70e84-a8/s21000x21000/e0587516e05bae4cec244921f220b45bed08335c.jpg"],
        artist_name: "munespice",
        page_url: "https://munespice.tumblr.com/post/683613396085719040",
        profile_url: "https://munespice.tumblr.com"
      )
    end

    context "generating page urls" do
      should "work" do
        source1 = "https://octrain1020.tumblr.com/post/190713122589"
        source2 = "https://octrain1020.tumblr.com/image/190713122589"
        source3 = "https://octrain1020.tumblr.com/image/190713122589#asd"
        source4 = "https://superboin.tumblr.com/post/141169066579/photoset_iframe/superboin/tumblr_o45miiAOts1u6rxu8/500/false"

        assert_equal(source1, Source::URL.page_url(source1))
        assert_equal(source1, Source::URL.page_url(source2))
        assert_equal(source1, Source::URL.page_url(source3))
        assert_equal("https://superboin.tumblr.com/post/141169066579", Source::URL.page_url(source4))
        assert_nil(Source::URL.page_url("https://octrain1020.tumblr.com/"))
      end
    end

    should "parse Tumblr URLs correctly" do
      assert_not(Source::URL.image_url?("https://tumblr.com"))
      assert_not(Source::URL.image_url?("https://www.tumblr.com"))
      assert_not(Source::URL.image_url?("https://yogurtmedia.tumblr.com/post/45732863347"))

      assert(Source::URL.image_url?("http://data.tumblr.com/07e7bba538046b2b586433976290ee1f/tumblr_o3gg44HcOg1r9pi29o1_raw.jpg"))
      assert(Source::URL.image_url?("https://40.media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_1280.jpg"))
      assert(Source::URL.image_url?("https://media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_raw.jpg"))
      assert(Source::URL.image_url?("https://66.media.tumblr.com/2c6f55531618b4335c67e29157f5c1fc/tumblr_pz4a44xdVj1ssucdno1_1280.png"))
      assert(Source::URL.image_url?("https://68.media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_250.gif"))
      assert(Source::URL.image_url?("https://media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_500.gif"))
      assert(Source::URL.image_url?("https://66.media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_500h.png"))
      assert(Source::URL.image_url?("https://media.tumblr.com/701a535af224f89684d2cfcc097575ef/tumblr_pjsx70RakC1y0gqjko1_1280.pnj"))

      assert(Source::URL.image_url?("https://25.media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png"))
      assert(Source::URL.image_url?("https://media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_1280.png"))
      assert(Source::URL.image_url?("https://media.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_500.jpg"))
      assert(Source::URL.image_url?("https://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg"))
      assert(Source::URL.image_url?("https://va.media.tumblr.com/tumblr_pgohk0TjhS1u7mrsl.mp4"))

      assert(Source::URL.image_url?("https://66.media.tumblr.com/168dabd09d5ad69eb5fedcf94c45c31a/3dbfaec9b9e0c2e3-72/s640x960/bf33a1324f3f36d2dc64f011bfeab4867da62bc8.png"))
      assert(Source::URL.image_url?("https://66.media.tumblr.com/5a2c3fe25c977e2281392752ab971c90/3dbfaec9b9e0c2e3-92/s500x750/4f92bbaaf95c0b4e7970e62b1d2e1415859dd659.png"))

      assert(Source::URL.image_url?("https://25.media.tumblr.com/91719d337b218681abc48cdc24e"))
      assert_not(Source::URL.page_url?("https://25.media.tumblr.com/91719d337b218681abc48cdc24e"))
      assert_not(Source::URL.profile_url?("https://25.media.tumblr.com/91719d337b218681abc48cdc24e"))
    end
  end
end
