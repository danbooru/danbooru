require "test_helper"

module Sources
  class SkebTest < ActiveSupport::TestCase
    context "The source for a skeb picture" do
      setup do
        @site = Sources::Strategies.find("https://skeb.jp/@kai_chiisame/works/6")
      end

      should "get the artist name" do
        assert_equal("kai_chiisame", @site.artist_name)
      end

      should "get the artist commentary" do
        commentary = <<~COMM.chomp
          初めまして、先日アピールを頂きましたのでリクエストさせて頂きます。

          〇キャラ
          　東方の東風谷早苗さん

          〇内容
          　・水着や薄着などの若干セクシーめ・肌色多めな方向性で、細部は絵師さんにお任せ
          　・念のためNSFW指定にしましたがエロでなくていいです

          ご検討お願いします。
        COMM

        assert_equal(commentary, @site.artist_commentary_desc)
      end

      should "get profile url" do
        assert_equal("https://skeb.jp/@kai_chiisame", @site.profile_url)
      end

      should "get the image url" do
        assert_equal("https://skeb.imgix.net/requests/229088_2?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&w=800&s=32a275893cf5362d51e5744ff5d8f88b", @site.image_url)
      end

      should "get the canonical url" do
        assert_equal("https://skeb.jp/@kai_chiisame/works/6", @site.canonical_url)
      end

      should "find the correct artist" do
        artist = FactoryBot.create(:artist, name: "kai_chiisame", url_string: @site.url)
        assert_equal([artist], @site.artists)
      end

      should "not fail" do
        assert_nothing_raised { @site.to_h }
      end
    end

    context "A private or non-existent skeb url" do
      setup do
        @site = Sources::Strategies.find("https://skeb.jp/@kai_chiisame/works/2")
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
        site = Sources::Strategies.find("https://skeb.jp/@2gi0gi_/works/13")
        assert_equal(["https://skeb.imgix.net/requests/191942_0?bg=%23fff&fm=jpg&q=45&w=696&s=5783ee951cc55d183713395926389453"], site.image_urls)
      end
    end

    context "A post with both the small and large version clean" do
      should "just get the bigger image" do
        site = Sources::Strategies.find("https://skeb.jp/@LambOic029/works/149")
        assert_equal(["https://skeb.imgix.net/uploads/origins/ebe94108-7ca7-4b3d-b80c-b37759ffd695?bg=%23fff&fm=jpg&q=45&w=696&s=9c4e093a440fe4030ac1596813ce7e17"], site.image_urls)
      end
    end

    context "A post with two images" do
      should "get both correctly" do
        site = Sources::Strategies.find("https://skeb.jp/@LambOic029/works/146")
        image_urls = %w[
          https://skeb.imgix.net/uploads/origins/e888bb27-e1a6-48ec-a317-7615252ff818?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&w=800&s=9df9b46bbfad404d3a65c7c56b0cbf40
          https://skeb.imgix.net/uploads/origins/3fc062c5-231d-400f-921f-22d77cde54df?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&w=800&s=80a1373b3f8e9bf0108d201fba34de71
        ]

        assert_equal(image_urls, site.image_urls)
      end
    end

    context "normalizing for source" do
      should "avoid normalizing unnormalizable urls" do
        bad_source = "https://skeb.imgix.net/requests/229088_2?bg=%23fff&auto=format&w=800&s=9cac8b76c0838f2df4f19ebc41c1ae0a"
        assert_equal(bad_source, Sources::Strategies.normalize_source(bad_source))
      end
    end
  end
end
