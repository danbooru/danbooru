require 'test_helper'

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

    context "normalizing for source" do
      should "avoid normalizing unnormalizable urls" do
        bad_source = "https://skeb.imgix.net/requests/229088_2?bg=%23fff&auto=format&w=800&s=9cac8b76c0838f2df4f19ebc41c1ae0a"
        assert_equal(bad_source, Sources::Strategies.normalize_source(bad_source))
      end
    end
  end
end
