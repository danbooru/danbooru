require 'test_helper'

module Sources
  class CiEnTest < ActiveSupport::TestCase
    def setup
      super
      skip "ci_en_session cookie not set" unless Danbooru.config.ci_en_session_cookie.present?
    end

    context "An all-ages article url" do
      strategy_should_work(
        "https://ci-en.net/creator/492/article/1004190",
        page_url: "https://ci-en.net/creator/492/article/1004190",
        media_files: [
          { file_size: 463_147 },
        ],
        profile_urls: [
          "https://ci-en.net/creator/492",
        ],
        artist_name: "ミックス ステーション",
        tag_name: "cien_492",
        tags: ["キック", "バトルメイド", "リクエスト"],
        dtext_artist_commentary_title: "戦うバトルメイド！",
        dtext_artist_commentary_desc: <<~EOS.chomp
          カラーラフリクエストで描いたキックするバトルメイドです。関連のあるキャラ退魔シスターをメインにしたCG集もあります。
          退魔シスターAuxesia(アウクセシアー)
          <https://www.dlsite.com/home/work/=/product_id/RJ322647.html>
          Twitterです。
          <https://twitter.com/YadogenMix>
          フォローしていただけたら幸いです。
        EOS
      )
    end

    context "An R18 article url" do
      strategy_should_work(
        "https://ci-en.dlsite.com/creator/4565/article/1004364",
        page_url: "https://ci-en.net/creator/4565/article/1004364",
        media_files: [
          { file_size: 908_311 },
        ],
        profile_urls: [
          "https://ci-en.net/creator/4565",
        ],
        artist_name: "おおいぬのふぐり",
        tag_name: "cien_4565",
        tags: ["skeb", "いぬのふぐり", "イラスト", "オリジナル", "制服", "学校"],
        dtext_artist_commentary_title: "[R-15絵] 廊下でぶつかってパンモロ",
        dtext_artist_commentary_desc: <<~EOS.chomp
          [u]"Skeb":[https://skeb.jp/@inu_no_huguri][/u]でリクエストをいただきました！
          お題は [b]ぶつかってパンツが丸見えになっちゃった女の子[/b] です。ラッキースケベ。
          パンツの描き込みをいつもより力入れました！
          たまたま"[u]前記事[/u]":[https://ci-en.dlsite.com/creator/4565/article/999219]とパンツネタが被りました。
          
          h6. おおいぬのふぐりプランで高解像度のパンツ差分など
          高解像度版のサイズは 1500×2000 pixel です。
          パンツ差分もあります。
          ※裸差分なし
          * 水色の水玉パンツ（上記と同じ）
          * 無地の白パンツ
          * ピンクの縞パンツ
        EOS
      )
    end

    should "Parse Ci-En URLs correctly" do
      assert(Source::URL.image_url?("https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/image-800.jpg?px-time=1700517240&px-hash=eb626eafb7e5733c96fb0891188848dac10cb84c"))
      assert(Source::URL.image_url?("https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/upload/%E3%81%B0%E3%81%AB%E3%81%A3%E3%81%A1A.jpg?px-time=1700517240&px-hash=eb626eafb7e5733c96fb0891188848dac10cb84c"))

      assert(Source::URL.page_url?("https://ci-en.net/creator/11019/article/921762"))
      assert(Source::URL.page_url?("https://ci-en.dlsite.com/creator/5290/article/998146"))
      assert_equal("https://ci-en.net/creator/5290/article/998146", Source::URL.page_url("https://ci-en.dlsite.com/creator/5290/article/998146"))

      assert(Source::URL.profile_url?("https://ci-en.net/creator/11019"))
      assert(Source::URL.profile_url?("https://ci-en.dlsite.com/creator/5290"))
      assert_equal("https://ci-en.net/creator/5290", Source::URL.profile_url("https://ci-en.dlsite.com/creator/5290"))

      assert_not(Source::URL.page_url?("https://ci-en.net/creator/11019/article/"))
      assert_not(Source::URL.profile_url?("https://ci-en.net/creator"))

      assert_equal("11019", Source::URL.parse("https://ci-en.net/creator/11019/article/921762").creator_id)
      assert_equal("921762", Source::URL.parse("https://ci-en.net/creator/11019/article/921762").article_id)

      assert_equal("11019", Source::URL.parse("https://ci-en.net/creator/11019").creator_id)
      assert_nil(Source::URL.parse("https://ci-en.net/creator/11019").article_id)
    end
  end
end
