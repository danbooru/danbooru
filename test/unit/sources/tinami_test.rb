require "test_helper"

module Sources
  class TinamiTest < ActiveSupport::TestCase
    context "Tinami:" do
      context "A 'http://www.tinami.com/view/:id' post with one image" do
        should "work" do
          source = Source::Extractor.find("http://www.tinami.com/view/1087268")

          assert_equal("みぐめ", source.artist_name)
          assert_equal("https://www.tinami.com/view/1087268", source.page_url)
          assert_equal(["https://img.tinami.com/illust2/img/49/6234fe552348b.jpg"], source.image_urls)
          assert_equal("https://www.tinami.com/creator/profile/66493", source.profile_url)
          assert_equal(%w[横顔 アナログ ボールペン SP], source.tags.map(&:first))
          assert_equal("横顔", source.artist_commentary_title)
          assert_equal("横顔", source.artist_commentary_desc)
        end
      end

      context "A 'http://www.tinami.com/view/:id' post with multiple images (type one)" do
        should "work" do
          source = Source::Extractor.find("http://www.tinami.com/view/1087271")

          assert_equal("Shimaken", source.artist_name)
          assert_equal("https://www.tinami.com/view/1087271", source.page_url)
          assert_equal(%w[
            https://img.tinami.com/illust2/img/458/62351d05dc2d1.jpg
            https://img.tinami.com/illust2/img/658/62351d0645c67.jpg
            https://img.tinami.com/illust2/img/977/62351d06ab068.jpg
          ], source.image_urls)
          assert_equal("https://www.tinami.com/creator/profile/27790", source.profile_url)
          assert_equal(%w[オリジナル 女の子 創作 漫画 マンガ ひとしずく 学園 体操服 ブルマ バドミントン], source.tags.map(&:first))
          assert_equal("「ひとしずく」15話", source.artist_commentary_title)
          assert_equal("学園百合漫画「ひとしずく」の15話目です。", source.artist_commentary_desc)
        end
      end

      context "A 'http://www.tinami.com/view/:id' post with multiple images (type two)" do
        should "work" do
          source = Source::Extractor.find("http://www.tinami.com/view/1087270")

          assert_equal("セラ箱", source.artist_name)
          assert_equal("https://www.tinami.com/view/1087270", source.page_url)
          assert_equal(%w[
            https://img.tinami.com/illust2/img/399/623503bb2c686.jpg
            https://img.tinami.com/illust2/img/505/623503bdd064e.jpg
            https://img.tinami.com/illust2/img/140/623503bf50d20.jpg
            https://img.tinami.com/illust2/img/986/623503c0940f5.jpg
            https://img.tinami.com/illust2/img/954/623503c219ee9.jpg
            https://img.tinami.com/illust2/img/655/623503c3646c0.jpg
            https://img.tinami.com/illust2/img/401/623503c4b8171.jpg
          ], source.image_urls)
          assert_equal("https://www.tinami.com/creator/profile/38168", source.profile_url)
          assert_equal(%w[Re:ゼロから始める異世界生活 レム リゼロ セラ箱 rizero フィギュア リペイント], source.tags.map(&:first))
          assert_equal("レムのクリアドレス：リゼロ", source.artist_commentary_title)
          assert_equal(<<~EOS.chomp, source.artist_commentary_desc)
            リゼロのレムのプライズをクリアドレス仕様にリペイント。透け透けキラキラな感じに改装してみたものです。

            >https://youtu.be/nkjZkEALg94 

            製作日記的な動画です( ´∀｀ )

            需要ありましたらご笑覧を
          EOS
        end
      end

      context "A Tinami image URL without a referer" do
        should "work" do
          source = Source::Extractor.find("https://img.tinami.com/illust2/img/647/6234fe5588e97.jpg")

          assert_nil(source.artist_name)
          assert_nil(source.page_url)
          assert_equal(["https://img.tinami.com/illust2/img/647/6234fe5588e97.jpg"], source.image_urls)
          assert_nil(source.profile_url)
          assert_equal(%w[], source.tags.map(&:first))
          assert_equal("", source.artist_commentary_title)
          assert_equal("", source.artist_commentary_desc)
        end
      end

      context "A Tinami image URL with a referer" do
        should "work" do
          source = Source::Extractor.find("https://img.tinami.com/illust2/img/647/6234fe5588e97.jpg", "http://www.tinami.com/view/1087268")

          assert_equal("みぐめ", source.artist_name)
          assert_equal("https://www.tinami.com/view/1087268", source.page_url)
          assert_equal(["https://img.tinami.com/illust2/img/647/6234fe5588e97.jpg"], source.image_urls)
          assert_equal("https://www.tinami.com/creator/profile/66493", source.profile_url)
          assert_equal(%w[横顔 アナログ ボールペン SP], source.tags.map(&:first))
          assert_equal("横顔", source.artist_commentary_title)
          assert_equal("横顔", source.artist_commentary_desc)
        end
      end

      context "A deleted Tinami post" do
        should "work" do
          source = Source::Extractor.find("http://www.tinami.com/view/774077")

          assert_nil(source.artist_name)
          assert_equal("https://www.tinami.com/view/774077", source.page_url)
          assert_equal([], source.image_urls)
          assert_nil(source.profile_url)
          assert_equal(%w[], source.tags.map(&:first))
          assert_equal("", source.artist_commentary_title)
          assert_equal("", source.artist_commentary_desc)
        end
      end

      should "Parse Tinami URLs correctly" do
        assert(Source::URL.image_url?("https://img.tinami.com/illust/img/287/497c8a9dc60e6.jpg"))
        assert(Source::URL.image_url?("https://img.tinami.com/comic/naomao/naomao_001_01.jpg"))
        assert(Source::URL.image_url?("https://www.tinami.com/view/tweet/card/461459"))

        assert(Source::URL.page_url?("https://www.tinami.com/view/461459"))

        assert(Source::URL.profile_url?("http://www.tinami.com/creator/profile/1624"))
        assert(Source::URL.profile_url?("https://www.tinami.com/search/list?prof_id=1624"))

        refute(Source::URL.profile_url?("http://www.tinami.com/profile/1182"))
      end
    end
  end
end
