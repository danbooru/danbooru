require "test_helper"

module Sources
  class TinamiTest < ActiveSupport::TestCase
    context "Tinami:" do
      context "A 'http://www.tinami.com/view/:id' post with one image" do
        strategy_should_work(
          "http://www.tinami.com/view/1087268",
          image_urls: %w[https://img.tinami.com/illust2/img/49/6234fe552348b.jpg],
          media_files: [{ file_size: 85_353 }],
          page_url: "https://www.tinami.com/view/1087268",
          profile_url: "https://www.tinami.com/creator/profile/66493",
          profile_urls: %w[https://www.tinami.com/creator/profile/66493],
          display_name: "みぐめ",
          other_names: ["みぐめ"],
          tag_name: "tinami_66493",
          tags: [
            ["横顔", "https://www.tinami.com/search/list?keyword=横顔"],
            ["アナログ", "https://www.tinami.com/search/list?keyword=アナログ"],
            ["ボールペン", "https://www.tinami.com/search/list?keyword=ボールペン"],
            ["SP", "https://www.tinami.com/search/list?keyword=SP"],
          ],
          dtext_artist_commentary_title: "横顔",
          dtext_artist_commentary_desc: "横顔"
        )
      end

      context "A 'http://www.tinami.com/view/:id' post with multiple images (type one)" do
        strategy_should_work(
          "http://www.tinami.com/view/1087271",
          image_urls: %w[
            https://img.tinami.com/illust2/img/458/62351d05dc2d1.jpg
            https://img.tinami.com/illust2/img/658/62351d0645c67.jpg
            https://img.tinami.com/illust2/img/977/62351d06ab068.jpg
          ],
          media_files: [
            { file_size: 208_562 },
            { file_size: 215_274 },
            { file_size: 211_999 },
          ],
          page_url: "https://www.tinami.com/view/1087271",
          profile_url: "https://www.tinami.com/creator/profile/27790",
          profile_urls: %w[https://www.tinami.com/creator/profile/27790],
          display_name: "Shimaken",
          other_names: ["Shimaken"],
          tag_name: "tinami_27790",
          tags: [
            ["オリジナル", "https://www.tinami.com/search/list?keyword=オリジナル"],
            ["女の子", "https://www.tinami.com/search/list?keyword=女の子"],
            ["創作", "https://www.tinami.com/search/list?keyword=創作"],
            ["漫画", "https://www.tinami.com/search/list?keyword=漫画"],
            ["マンガ", "https://www.tinami.com/search/list?keyword=マンガ"],
            ["ひとしずく", "https://www.tinami.com/search/list?keyword=ひとしずく"],
            ["学園", "https://www.tinami.com/search/list?keyword=学園"],
            ["体操服", "https://www.tinami.com/search/list?keyword=体操服"],
            ["ブルマ", "https://www.tinami.com/search/list?keyword=ブルマ"],
            ["バドミントン", "https://www.tinami.com/search/list?keyword=バドミントン"],
          ],
          dtext_artist_commentary_title: "「ひとしずく」15話",
          dtext_artist_commentary_desc: <<~EOS.chomp
            学園百合漫画「ひとしずく」の15話目です。
          EOS
        )
      end

      context "A 'http://www.tinami.com/view/:id' post with multiple images (type two)" do
        strategy_should_work(
          "http://www.tinami.com/view/1087270",
          image_urls: %w[
            https://img.tinami.com/illust2/img/399/623503bb2c686.jpg
            https://img.tinami.com/illust2/img/505/623503bdd064e.jpg
            https://img.tinami.com/illust2/img/140/623503bf50d20.jpg
            https://img.tinami.com/illust2/img/986/623503c0940f5.jpg
            https://img.tinami.com/illust2/img/954/623503c219ee9.jpg
            https://img.tinami.com/illust2/img/655/623503c3646c0.jpg
            https://img.tinami.com/illust2/img/401/623503c4b8171.jpg
          ],
          media_files: [
            { file_size: 246_375 },
            { file_size: 264_535 },
            { file_size: 215_525 },
            { file_size: 220_019 },
            { file_size: 272_428 },
            { file_size: 241_127 },
            { file_size: 324_091 },
          ],
          page_url: "https://www.tinami.com/view/1087270",
          profile_url: "https://www.tinami.com/creator/profile/38168",
          profile_urls: %w[https://www.tinami.com/creator/profile/38168],
          display_name: "セラ箱",
          other_names: ["セラ箱"],
          tag_name: "tinami_38168",
          tags: [
            ["Re:ゼロから始める異世界生活", "https://www.tinami.com/search/list?keyword=Re:ゼロから始める異世界生活"],
            ["レム", "https://www.tinami.com/search/list?keyword=レム"],
            ["リゼロ", "https://www.tinami.com/search/list?keyword=リゼロ"],
            ["セラ箱", "https://www.tinami.com/search/list?keyword=セラ箱"],
            ["rizero", "https://www.tinami.com/search/list?keyword=rizero"],
            ["フィギュア", "https://www.tinami.com/search/list?keyword=フィギュア"],
            ["リペイント", "https://www.tinami.com/search/list?keyword=リペイント"],
          ],
          dtext_artist_commentary_title: "レムのクリアドレス：リゼロ",
          dtext_artist_commentary_desc: <<~EOS.chomp
            リゼロのレムのプライズをクリアドレス仕様にリペイント。透け透けキラキラな感じに改装してみたものです。
            ><https://youtu.be/nkjZkEALg94>
            製作日記的な動画です( ´∀｀ )
            需要ありましたらご笑覧を
          EOS
        )
      end

      context "A Tinami image URL without a referer" do
        strategy_should_work(
          "https://img.tinami.com/illust2/img/647/6234fe5588e97.jpg",
          image_urls: %w[https://img.tinami.com/illust2/img/647/6234fe5588e97.jpg],
          media_files: [{ file_size: 73_344 }],
          page_url: nil,
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          other_names: [],
          tag_name: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A Tinami image URL with a referer" do
        strategy_should_work(
          "https://img.tinami.com/illust2/img/647/6234fe5588e97.jpg",
          referer: "http://www.tinami.com/view/1087268",
          image_urls: %w[https://img.tinami.com/illust2/img/647/6234fe5588e97.jpg],
          media_files: [{ file_size: 73_344 }],
          page_url: "https://www.tinami.com/view/1087268",
          profile_url: "https://www.tinami.com/creator/profile/66493",
          profile_urls: %w[https://www.tinami.com/creator/profile/66493],
          display_name: "みぐめ",
          other_names: ["みぐめ"],
          tag_name: "tinami_66493",
          tags: [
            ["横顔", "https://www.tinami.com/search/list?keyword=横顔"],
            ["アナログ", "https://www.tinami.com/search/list?keyword=アナログ"],
            ["ボールペン", "https://www.tinami.com/search/list?keyword=ボールペン"],
            ["SP", "https://www.tinami.com/search/list?keyword=SP"],
          ],
          dtext_artist_commentary_title: "横顔",
          dtext_artist_commentary_desc: "横顔"
        )
      end

      context "A deleted Tinami post" do
        strategy_should_work(
          "http://www.tinami.com/view/774077",
          image_urls: [],
          page_url: "https://www.tinami.com/view/774077",
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          other_names: [],
          tag_name: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
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
