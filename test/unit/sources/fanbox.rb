require 'test_helper'

module Sources
  class FanboxTest < ActiveSupport::TestCase
    context "A free Pixiv Fanbox post" do
      setup do
        @post1 = Sources::Strategies.find("https://yanmi0308.fanbox.cc/posts/1141325")
        @post2 = Sources::Strategies.find("https://www.fanbox.cc/@tsukiori/posts/1080657")
        @post3 = Sources::Strategies.find("https://downloads.fanbox.cc/images/post/1080657/SaakPC251KafLL6jIo1WPPmr.png")

        assert_nothing_raised { @post1.to_h }
        assert_nothing_raised { @post2.to_h }
        assert_nothing_raised { @post3.to_h }
      end

      should "get the image urls" do
        # "images" in api response
        images1 = %w[
          https://downloads.fanbox.cc/images/post/1141325/q7GaJ0A9J5Uz8kvEAUizHJoN.png
          https://downloads.fanbox.cc/images/post/1141325/LMJz0sAig5h9D3rPZGCEGniZ.png
          https://downloads.fanbox.cc/images/post/1141325/dRSz380Uf3N8s4pT2ADEXBco.png
          https://downloads.fanbox.cc/images/post/1141325/h48L2mbm39qqNUB1abLAvzvg.png
        ]
        assert_equal(images1, @post1.image_urls)

        # "imageMapi" in api response (embedded pics)
        images2 = %w[
          https://downloads.fanbox.cc/images/post/1080657/fMD4FYzodzcNrEamag7oSpUt.png
          https://downloads.fanbox.cc/images/post/1080657/IHhfqr4jjos6XWLBOD7QP4BJ.png
          https://downloads.fanbox.cc/images/post/1080657/mIUSuwQsGiStRrLQMZ6oKMAl.png
          https://downloads.fanbox.cc/images/post/1080657/s0UHQTY6zqN3LYoeS4OoB184.png
          https://downloads.fanbox.cc/images/post/1080657/SaakPC251KafLL6jIo1WPPmr.png
          https://downloads.fanbox.cc/images/post/1080657/z6iw3dewfzAiZEOrG10a8ALa.png
        ]
        assert_equal(images2, @post2.image_urls)
        assert_equal([@post3.url], @post3.image_urls)
      end

      should "get the commentary" do
        # Normal commentary
        assert_equal("栗山やんみ（デザイン）", @post1.artist_commentary_title)

        body1 = "˗ˋˏ Special Thanks ˎˊ˗   (敬称略)\n\n🎨キャラクターデザイン\n特急みかん  https://twitter.com/tokkyuumikan\n\n🤖3Dモデリング\n（仮）  https://twitter.com/Admiral_TMP\n\n⚙プログラミング\n神無月ユズカ  https://twitter.com/Kannaduki_Yzk\n\n🎧OP・EDミュージック\n卓球少年  https://twitter.com/takkyuu_s\n\n📻BGM\nC  https://twitter.com/nica2c\n\n🖌ロゴデザイン\nてづかもり  https://twitter.com/tezkamori\n\n🎨SDキャラクター\nAZU。  https://twitter.com/tokitou_aaa"
        assert_equal(body1, @post1.artist_commentary_desc)

        # With embedded pics
        assert_equal("はじめまして　＃１", @post2.artist_commentary_title)
        assert_equal("はじめまして　＃１", @post3.artist_commentary_title)

        body2 = "\nhttps://downloads.fanbox.cc/images/post/1080657/z6iw3dewfzAiZEOrG10a8ALa.png\nいらっしゃいませ……\nあら？あらあら、もしかして……初めてのお客さま！？\n\nhttps://downloads.fanbox.cc/images/post/1080657/SaakPC251KafLL6jIo1WPPmr.png\n調ノ宮喫茶店へようこそっ！\n\nhttps://downloads.fanbox.cc/images/post/1080657/mIUSuwQsGiStRrLQMZ6oKMAl.png\nあ、すみません。ひとりで盛り上がってしまって。\nなにせこんな辺鄙(へんぴ)なところに来て下さるお客さまは少ないものですから。\n\n藍ちゃん、藍ちゃーん。\n初めてのお客様だよ。\n\nhttps://downloads.fanbox.cc/images/post/1080657/IHhfqr4jjos6XWLBOD7QP4BJ.png\nえ。なに？\n今日はちゃんと化粧してない？　はずかしい？\n大丈夫だよいつもと変わんないから……あ！ちょっと！\n\nhttps://downloads.fanbox.cc/images/post/1080657/s0UHQTY6zqN3LYoeS4OoB184.png\n…………\nえっと……すみません。\nなんかちょっと照れてるみたいで。\n\nなにはともあれ、せっかく来られたんですからゆっくりしていってください。\n\nhttps://downloads.fanbox.cc/images/post/1080657/fMD4FYzodzcNrEamag7oSpUt.png\nあ、そっちの陽が差している窓際の席がオススメですよ。\n向かいの島がよく見渡せるんです。\n\nではご注文が決まりましたら伺いますので……\n藍ちゃん……じゃなくて、店主の焼くパンケーキはふわふわでバターの香りがして、\nナッツとシロップがたっぷり乗っててとってもおいしいですよ。\nぜひ食べてみてくださいね。\n"
        assert_equal(body2, @post2.artist_commentary_desc)
        assert_equal(body2, @post3.artist_commentary_desc)
      end

      should "get the right page url" do
        assert_equal("https://yanmi0308.fanbox.cc/posts/1141325", @post1.page_url)
        assert_equal("https://tsukiori.fanbox.cc/posts/1080657", @post2.page_url)
        assert_equal("https://tsukiori.fanbox.cc/posts/1080657", @post3.page_url)
      end

      should "correctly download the right image" do
        assert_downloaded(431_225, @post1.image_url)
        assert_downloaded(76_012, @post2.image_url)
        assert_downloaded(78_751, @post3.image_url)
      end

      should "get the tags" do
        tags = [
          ["栗山やんみ", "https://fanbox.cc/tags/栗山やんみ"], ["VTuber", "https://fanbox.cc/tags/VTuber"], ["三面図", "https://fanbox.cc/tags/三面図"],
          ["イラスト", "https://fanbox.cc/tags/イラスト"], ["ロゴデザイン", "https://fanbox.cc/tags/ロゴデザイン"], ["モデリング", "https://fanbox.cc/tags/モデリング"]
        ]
        assert_equal(tags, @post1.tags)
      end

      should "find the correct artist" do
        @artist1 = FactoryBot.create(:artist, name: "yanmi", url_string: @post1.url)
        @artist2 = FactoryBot.create(:artist, name: "tsukiori", url_string: @post2.url)
        assert_equal([@artist1], @post1.artists)
        assert_equal([@artist2], @post2.artists)
        assert_equal([@artist2], @post3.artists)
      end

      should "find the right artist names" do
        assert_equal("yanmi0308", @post1.artist_name)
        assert_equal("栗山やんみ", @post1.display_name)
        assert_equal("tsukiori", @post2.artist_name)
        assert_equal("調ノ宮喫茶店", @post2.display_name)
        assert_equal(@post2.artist_name, @post3.artist_name)
        assert_equal(@post2.display_name, @post3.display_name)
      end
    end

    context "an age-restricted fanbox post" do
      should "not raise an error" do
        @source = Sources::Strategies.find("https://mfr.fanbox.cc/posts/1306390")

        assert_nothing_raised { @source.to_h }
        assert_equal("mfr", @source.artist_name)
      end
    end

    context "A link in the old format" do
      should "still work" do
        post = Sources::Strategies.find("https://www.pixiv.net/fanbox/creator/1566167/post/39714")
        assert_nothing_raised { post.to_h }
        assert_equal("https://omu001.fanbox.cc", post.profile_url)
        assert_equal("https://omu001.fanbox.cc/posts/39714", post.page_url)
        artist = FactoryBot.create(:artist, name: "omu", url_string: "https://omu001.fanbox.cc")
        assert_equal([artist], post.artists)
      end
    end

    context "A cover image" do
      should "still work" do
        post = Sources::Strategies.find("https://pixiv.pximg.net/c/1620x580_90_a2_g5/fanbox/public/images/creator/1566167/cover/WPqKsvKVGRq4qUjKFAMi23Z5.jpeg")
        assert_nothing_raised { post.to_h }
        assert_downloaded(276_301, post.image_url)
        assert_equal("https://omu001.fanbox.cc", post.profile_url)
        assert_equal(post.profile_url, post.canonical_url)
        artist = FactoryBot.create(:artist, name: "omu", url_string: "https://omu001.fanbox.cc")
        assert_equal([artist], post.artists)
      end
    end

    context "A dead profile picture from the old domain" do
      should "still find the artist" do
        post = Sources::Strategies.find("https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg")
        assert_equal("https://omu001.fanbox.cc", post.profile_url)
        artist = FactoryBot.create(:artist, name: "omu", url_string: "https://omu001.fanbox.cc")
        assert_equal([artist], post.artists)
      end
    end

    context "normalizing for source" do
      should "normalize cover images to the profile link" do
        cover = "https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg"
        assert_equal("https://www.pixiv.net/fanbox/creator/1566167", Sources::Strategies.normalize_source(cover))
      end

      should "avoid normalizing unnormalizable urls" do
        bad_source1 = "https://pixiv.pximg.net/c/936x600_90_a2_g5/fanbox/public/images/plan/4635/cover/L6AZNneFuHW6r25CHHlkpHg4.jpeg"
        bad_source2 = "https://downloads.fanbox.cc/images/post/39714/JvjJal8v1yLgc5DPyEI05YpT.png"
        assert_equal(bad_source1, Sources::Strategies.normalize_source(bad_source1))
        assert_equal(bad_source2, Sources::Strategies.normalize_source(bad_source2))
      end
    end
  end
end
