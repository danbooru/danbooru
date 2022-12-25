require "test_helper"

module Sources
  class SkebTest < ActiveSupport::TestCase
    context "The source for a skeb picture" do
      setup do
        @site = Source::Extractor.find("https://skeb.jp/@kokuzou593/works/45")
      end

      should "get the artist name" do
        assert_equal("kokuzou593", @site.artist_name)
      end

      should "get profile url" do
        assert_equal("https://skeb.jp/@kokuzou593", @site.profile_url)
      end

      should "get the image url" do
        assert_equal(["https://skeb.imgix.net/uploads/origins/307941e9-dbe0-4e4b-93d4-94accdaff9a0?bg=%23fff&auto=format&fm=webp&w=800&s=0c4bc4f0e5c231b39a81c2647988caa2"], @site.image_urls)
      end

      should "get the page url" do
        assert_equal("https://skeb.jp/@kokuzou593/works/45", @site.page_url)
      end

      should "find the correct artist" do
        artist = create(:artist, name: "kokuzou593", url_string: @site.url)
        assert_equal([artist], @site.artists)
      end

      should "not fail" do
        assert_nothing_raised { @site.to_h }
      end
    end

    context "A private or non-existent skeb url" do
      setup do
        @site = Source::Extractor.find("https://skeb.jp/@kai_chiisame/works/2")
      end

      should "not raise anything" do
        assert_nothing_raised { @site.to_h }
      end

      should "still find the right artist" do
        artist = FactoryBot.create(:artist, name: "kai_chiisame", url_string: @site.url)
        assert_equal([artist], @site.artists)
      end
    end

    context "A post with a smaller unwatermarked version" do
      should "get the smaller but clean picture" do
        site = Source::Extractor.find("https://skeb.jp/@2gi0gi_/works/13")
        assert_equal(["https://skeb.imgix.net/requests/191942_0?bg=%23fff&fm=jpg&q=45&w=696&s=5783ee951cc55d183713395926389453"], site.image_urls)
      end
    end

    context "An animated post with a smaller static unwatermarked version" do
      should "still get the watermarked gif" do
        site = Source::Extractor.find("https://skeb.jp/@tontaro_/works/316")
        assert_equal(%w[
          https://skeb.imgix.net/uploads/origins/5097b1e1-18ce-418e-82f0-e7e2cdab1cea?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=mp4&w=800&s=fcff06871e114b3dbf505c04f27b5ed1
          https://skeb.imgix.net/uploads/origins/23123cfd-9b03-40f6-a8ae-7d74f9118c6f?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=mp4&w=800&s=984626d69b45c040d295e357a67f281e
          https://skeb.imgix.net/uploads/origins/38a00949-a726-45c8-82b3-9aec4e8255ba?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=mp4&w=800&s=29689f451cd70fa97c806b4c2145bf6b
        ], site.image_urls)
      end
    end

    context "A post with both the small and large version clean" do
      should "just get the bigger image" do
        site = Source::Extractor.find("https://skeb.jp/@goma_feet/works/1")
        assert_equal(["https://skeb.imgix.net/uploads/origins/78ca23dc-a053-4ebe-894f-d5a06e228af8?bg=%23fff&auto=format&fm=webp&w=800&s=3a458a1e443dee3d73d45e88f0794f85"], site.image_urls)
      end
    end

    context "A post with two images" do
      should "get both correctly and in the right order" do
        site = Source::Extractor.find("https://skeb.jp/@LambOic029/works/146")
        image_urls = %w[
          https://skeb.imgix.net/uploads/origins/3fc062c5-231d-400f-921f-22d77cde54df?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=webp&w=800&s=7dbecbeb7b05394537b60c881a081776
          https://skeb.imgix.net/uploads/origins/e888bb27-e1a6-48ec-a317-7615252ff818?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=webp&w=800&s=64713510bc4a36b3422dff4b93e4ae87
        ]

        assert_equal(image_urls, site.image_urls)
      end
    end

    context "A post with a video" do
      should "get it correctly" do
        site = Source::Extractor.find("https://skeb.jp/@kaisouafuro/works/112")
        assert_match(%r{\Ahttps://cdn\.skeb\.jp/uploads/outputs/20f9d68f-50ec-44ae-8630-173fc38a2d6a\?response-content-disposition=inline&Expires=\d+&Signature=.*&Key-Pair-Id=.*}, site.image_urls.sole)
      end
    end

    context "A post with both original and autotranslated commentary" do
      should "get the original commentary" do
        site = Source::Extractor.find("https://skeb.jp/@kaisouafuro/works/112")
        assert_match(/I would like to request an animation screen for my Twitch channel. My character is a catgirl/, site.dtext_artist_commentary_desc)
      end
    end

    context "A watermarked sample URL" do
      # Test that we don't alter the percent encoding of the URL, otherwise the signature will be wrong
      # page: https://skeb.jp/@LambOic029/works/146
      strategy_should_work(
        "https://skeb.imgix.net/uploads/origins/3fc062c5-231d-400f-921f-22d77cde54df?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=webp&w=800&s=7dbecbeb7b05394537b60c881a081776",
        download_size: 126_690,
      )
    end

    should "Parse Skeb URLs correctly" do
      assert(Source::URL.image_url?("https://skeb.imgix.net/requests/229088_2?bg=%23fff&auto=format&w=800&s=9cac8b76c0838f2df4f19ebc41c1ae0a"))
      assert(Source::URL.image_url?("https://skeb.imgix.net/uploads/origins/04d62c2f-e396-46f9-903a-3ca8bd69fc7c?bg=%23fff&auto=format&w=800&s=966c5d0389c3b94dc36ac970f812bef4"))
      assert(Source::URL.image_url?("https://skeb-production.s3.ap-northeast-1.amazonaws.com/uploads/outputs/20f9d68f-50ec-44ae-8630-173fc38a2d6a?response-content-disposition=attachment%3B%20filename%3D%22458093-1.output.mp4%22%3B%20filename%2A%3DUTF-8%27%27458093-1.output.mp4&response-content-type=video%2Fmp4&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIVPUTFQBBL7UDSUA%2F20220221%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220221T200057Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7f028cfd9a56344cf1d42410063fad3ef30a1e47b83cef047247e0c37df01df0"))
      assert(Source::URL.page_url?("https://skeb.jp/@OrvMZ/works/3 "))
      assert(Source::URL.profile_url?("https://skeb.jp/@asanagi"))
      assert(Source::URL.profile_url?("https://www.skeb.jp/@asanagi"))
      assert(Source::URL.profile_url?("https://skeb.jp/asanagi"))
    end
  end
end
