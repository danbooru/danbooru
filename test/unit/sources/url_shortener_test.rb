# frozen_string_literal: true

require "test_helper"

module Sources
  class URLShortenerTest < ActiveSupport::TestCase
    def self.assert_redirects_to(source_url, destination_url)
      context "redirecting #{source_url} to #{destination_url}" do
        strategy_should_work(source_url, redirect_url: Source::URL.parse(destination_url))
      end
    end

    context "URL Shortener:" do
      context "A fully extracted shortened URL" do
        strategy_should_work(
          "https://bit.ly/4aAVa4y",
          image_urls: %w[https://c.fantia.jp/uploads/post/file/2679869/9e73556f-22fa-47d5-a0a5-f4c158718883.png],
          media_files: [{ file_size: 784_717 }],
          page_url: "https://fantia.jp/posts/2679869",
          profile_url: "https://fantia.jp/fanclubs/63436",
          profile_urls: %w[https://fantia.jp/fanclubs/63436],
          artist_name: "師走ほりお",
          tag_name: nil,
          other_names: ["師走ほりお"],
          tags: [
            ["オリジナル", "https://fantia.jp/posts?tag=オリジナル"],
            ["無料公開", "https://fantia.jp/posts?tag=無料公開"],
          ],
          dtext_artist_commentary_title: "【無料/R18】兄妹の仲直りの方法",
          dtext_artist_commentary_desc: <<~EOS.chomp
            今回の無用公開は前回のラフ絵の完成絵です！
            R18差分とPSD差分も用意してあります！

            ⭐️を押してお気に入りしていただけると大変嬉しいです！

            人気投稿シリーズ
            ⬇︎後輩ちゃんシリーズ

            ⬇︎下スクロールでR18イラスト⬇︎
          EOS
        )
      end

      context "A valid shortened URL" do
        assert_redirects_to("https://amzn.to/4afHvyL", "https://www.amazon.com/Portable-Shortwave-Operated-Reception-Earphone/dp/B0BPKJ1XP1")
        assert_redirects_to("http://bit.ly/4aAVa4y", "https://fantia.jp/posts/2679869?utm_source=pixiv&utm_medium=referral")
        assert_redirects_to("http://j.mp/cKV0uf", "http://blog-imgs-32-origin.fc2.com/c/o/n/connyac/20100314032806e94.jpg")
        assert_redirects_to("http://cutt.ly/GfQ2szk", "https://www.youtube.com/channel/UCTeu1oeRYy8Kz_tpv0mASYg?view_as=subscriber")
        assert_redirects_to("http://goo.gl/wVjj5", "http://seiga.nicovideo.jp/clip/864621")
        assert_redirects_to("http://goo.gl/forms/mxcIFGtbmrVVxheW2", "https://docs.google.com/forms/d/e/1FAIpQLScyOgVE2yTG_vSpPebT7qRUwY_a2qoNzwO56IY3tOcn0g8mDg/viewform?c=0&w=1&usp=send_form")
        assert_redirects_to("http://images.app.goo.gl/5uBga7TuPKHxyyR1A", "https://www.google.com/imgres?imgurl=https://pbs.twimg.com/media/D7VjgrTUcAEdvFf.png&imgrefurl=https://twitter.com/nejimaki_neji&docid=IXigeWQkHlv6fM&tbnid=-DQ5gjY1vFJK0M:&vet=1&w=900&h=810&hl=en-us&source=sh/x/im")
        assert_redirects_to("http://photos.app.goo.gl/eHfTwV866X4Vf7Zt5", "https://photos.google.com/share/AF1QipPMW7tBlPkOmK86r7Gwq_sJVXN3RLecedSgeUKX4mGv98naklY16X4e-cY1O5V_4g?key=aEcyMno2VmFSZGMxYkRZb0x0aWllUXB6b3RMS3pn")
        assert_redirects_to("http://is.gd/UeUnvf", "https://www.pixiv.net/artworks/62476859")
        assert_redirects_to("http://ow.ly/WmrYu", "https://twitter.com/dankanemitsu/status/680792282887409664")
        assert_redirects_to("http://pin.it/4A1N0Rd5W", "https://www.pinterest.com/pin/580612576989556785/sent/?invite_code=9e94baa7faae405d84a7787593fa46fd&sender=580612714368486682&sfo=1")
        assert_redirects_to("http://t.ly/x8f4j", "https://docs.google.com/document/d/166zHw2WwtJufey71cDjfhL_1Vvga9AWbL4BtHMcJu9I/edit")
        assert_redirects_to("http://tiny.cc/6ut5vz", "https://drive.google.com/drive/folders/1SMBFYwAOq3h6rhWS5rLQdxDqLGq5OwY2")
        assert_redirects_to("http://tinyurl.com/3avx9w4r", "https://spell-breakers.blogspot.com/2023/07/schools-out-for-summer.html")
        assert_redirects_to("http://t.co/Dxn7CuVErW", "https://twitter.com/Kekeflipnote/status/1496555599718498319/video/1")
        assert_redirects_to("http://pic.twitter.com/Dxn7CuVErW", "https://twitter.com/Kekeflipnote/status/1496555599718498319/video/1")
        assert_redirects_to("http://wp.me/p32Sjo-oJ", "http://xn--t8jf3evasg9m.com/?p=1533")
      end

      context "A deleted or nonexistent shortened URL" do
        assert_redirects_to("https://amzn.to/bad", nil)
        assert_redirects_to("https://bit.ly/qwo9iqwe9ogqerg", nil)
        assert_redirects_to("https://cutt.ly/qwoifjqwio", nil)
        assert_redirects_to("https://goo.gl/bad", nil)
        assert_redirects_to("https://goo.gl/forms/bad", nil)
        assert_redirects_to("https://photos.app.goo.gl/bad", nil)
        assert_redirects_to("https://is.gd/qwoifjqwio", nil)
        assert_redirects_to("https://ow.ly/qwoifjqwio", nil)
        assert_redirects_to("https://pin.it/bad", nil)
        assert_redirects_to("https://t.ly/bad", nil)
        assert_redirects_to("https://tiny.cc/qwoifjqwio", nil)
        assert_redirects_to("https://tinyurl.com/qwoifjqwio", nil)
        assert_redirects_to("https://t.co/bad", nil)
        assert_redirects_to("https://wp.me/qwoifjqwio", nil)
      end

      should "parse URLs correctly" do
        assert(Source::URL.bad_source?("https://bit.ly/4aAVa4y"))
        assert(Source::URL.bad_source?("http://j.mp/cKV0uf"))
        assert(Source::URL.bad_source?("https://t.co/Dxn7CuVErW"))
        assert(Source::URL.bad_source?("https://pic.twitter.com/Dxn7CuVErW"))
      end
    end
  end
end
