require "test_helper"

module Sources
  class FantiaTest < ActiveSupport::TestCase
    def setup
      skip "session_id cookie not set" unless Danbooru.config.fantia_session_id.present?
    end

    context "A c.fantia.jp/uploads/post/file/ url" do
      strategy_should_work(
        "https://c.fantia.jp/uploads/post/file/1070093/16faf0b1-58d8-4aac-9e86-b243063eaaf1.jpeg",
        image_urls: ["https://c.fantia.jp/uploads/post/file/1070093/16faf0b1-58d8-4aac-9e86-b243063eaaf1.jpeg"],
        media_files: [{ file_size: 3_694_873 }],
        page_url: "https://fantia.jp/posts/1070093",
        profile_url: "https://fantia.jp/fanclubs/27264",
        artist_name: "豆ラッコ",
        tags: [],
        dtext_artist_commentary_title: "大きく育った心春ちゃん1",
        dtext_artist_commentary_desc: "色々やります"
      )
    end

    context "A c.fantia.jp/uploads/post_content_photo/ url" do
      strategy_should_work(
        "https://cc.fantia.jp/uploads/post_content_photo/file/7087182/main_7f04ff3c-1f08-450f-bd98-796c290fc2d1.jpg?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnRfcGhvdG8vZmlsZS83MDg3MTgyL21haW5fN2YwNGZmM2MtMWYwOC00NTBmLWJkOTgtNzk2YzI5MGZjMmQxLmpwZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTY0NjkyODAzN319fV19&Signature=wl2Nr9i1O5R5dDc7FB-8CKtRvyZPS6ZEFXn7Q74rBh9R2PZkpKuQUDDsJubgkYaHrqHEapcOdZczzZaM5kbRLXGPOnVFUE7vHKnXZTO~Z1-Z8Cqt823NKCR-AXBjYPhQoGP0pITLYkjhofy0FXg6RYJ0oNJPdKkdjcnwzr-nZfyaFgkrrQ5~LRDhW5HOgSNfvhJleMRLRgLtXbbgNnVwHmpFWNkFSwwmDcUTXTh4hrhQrOJ~xJmiQesSP1wPAE5ZZSBGsbUstOa5Y1nVu540wItR4VWLm-jjuMk9OIr-Nvxg0ocoP9WU13WrRbeMeL5X0xhxBYSxgVIKXko2BqMf5w__",
        referer: "https://fantia.jp/posts/1132267",
        page_url: "https://fantia.jp/posts/1132267",
        profile_url: "https://fantia.jp/fanclubs/1096",
        artist_name: "稲光伸二",
        tags: %w[オリジナル 漫画],
        dtext_artist_commentary_title: "黒い歴史(5)",
        dtext_artist_commentary_desc: <<~EOS.chomp
          この回から絵はほとんど今と変わらなくなってきます。が、やはり目が小さすぎました。アップの顔はほぼ全部修正してしまったのでわからないと思いますが、なぜ当時こんなので可愛い女の子を描いてると思ってたのか謎です。
          制服部分とセリフだけ修正して普通の高校だと言い張るという場合の最大の難所がこの回で、体育の授業でいきなり上級生と柔道をやるというのがおかしすぎるので後半は使えなくなりますね。
          あとエロシーンを成年仕様にするということで、ちんこもしっかり描きたいですが、今は公開優先であとからアップデートしていきます。
        EOS
      )
    end

    context "A c.fantia.jp/uploads/post_content_photo/ url with full size page referer" do
      strategy_should_work(
        "https://cc.fantia.jp/uploads/post_content_photo/file/14978435/86ec43ba-8121-43ac-9d3c-aec86f5238a2.jpg?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnRfcGhvdG8vZmlsZS8xNDk3ODQzNS84NmVjNDNiYS04MTIxLTQzYWMtOWQzYy1hZWM4NmY1MjM4YTIuanBnIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNjk1MTM4MDI1fX19XX0_&Signature=ypwGfl0VivNcjmsfC5Cu6qNXhnXpuKTHnukMwBEgdWlENuAbVBi0napKC~39NN0e~FBNpgoOW2OqY0BX5zgeMdbz2RAGI1eFsfYpRRNfHDpEvh6dOVgBrHopZvXZzMf1G12yiBnKmXAvNyzwD1cDhnCW0mvcy9RbCJro1ELQ4qWt4BuBUzOtYX5h6OV-WvGnOdys25p~t4n8h15MhaWyIVx32W0wIsbs~cHnaScwgOIJAinBkgp4Mp1AwqYtvmgw28PjJrzohhFDrLGZeM6yjlvLQKnYqjQn5D8CR9l0TLADtMYc65hL92ywG0BXf1zGnGJ86gmqSiZjZ077rl9FVw__",
        referer: "https://fantia.jp/posts/2245222/post_content_photo/14978435",
        image_urls: ["https://cc.fantia.jp/uploads/post_content_photo/file/14978435/86ec43ba-8121-43ac-9d3c-aec86f5238a2.jpg?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnRfcGhvdG8vZmlsZS8xNDk3ODQzNS84NmVjNDNiYS04MTIxLTQzYWMtOWQzYy1hZWM4NmY1MjM4YTIuanBnIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNjk1MTM4MDI1fX19XX0_&Signature=ypwGfl0VivNcjmsfC5Cu6qNXhnXpuKTHnukMwBEgdWlENuAbVBi0napKC~39NN0e~FBNpgoOW2OqY0BX5zgeMdbz2RAGI1eFsfYpRRNfHDpEvh6dOVgBrHopZvXZzMf1G12yiBnKmXAvNyzwD1cDhnCW0mvcy9RbCJro1ELQ4qWt4BuBUzOtYX5h6OV-WvGnOdys25p~t4n8h15MhaWyIVx32W0wIsbs~cHnaScwgOIJAinBkgp4Mp1AwqYtvmgw28PjJrzohhFDrLGZeM6yjlvLQKnYqjQn5D8CR9l0TLADtMYc65hL92ywG0BXf1zGnGJ86gmqSiZjZ077rl9FVw__"],
        page_url: "https://fantia.jp/posts/2245222",
        profile_url: "https://fantia.jp/fanclubs/476367",
        artist_name: "4040(4059)",
        tags: %w[アイドルマスターシンデレラガールズ U149 橘ありす 櫻井桃華 赤城みりあ 佐々木千枝 龍崎薫 チアガール スパッツ アンスコ 放尿 R-18],
        dtext_artist_commentary_title: "チアコス感謝祭（高解像度版+アンスコ生🍞🍋☕差分α 計13枚）",
        dtext_artist_commentary_desc: <<~EOS.chomp
          U149のアクリルスタンドで描き下ろしされてた新規チアコス。
          色々加えていたら時間がかかりました💦
          この後上部カットインや🍋☕差分を描いていたら地獄を見ることに。

          上部にお尻カットインを追加したセリフありバージョン。
          ありす達にボトラーさせる絵を追加したら5人分手を描かなきゃいけなくなり、Pが5人いるのは変だろうと事務所の汚偉いさん相手の🍋☕感謝祭な話になりました。
        EOS
      )
    end

    context "A c.fantia.jp/uploads/product/image/ url" do
      strategy_should_work(
        "https://c.fantia.jp/uploads/product/image/249638/fd5aef8f-c217-49d0-83e8-289efb33dfc4.jpg",
        image_urls: ["https://c.fantia.jp/uploads/product/image/249638/fd5aef8f-c217-49d0-83e8-289efb33dfc4.jpg"],
        media_files: [{ file_size: 289_918 }],
        page_url: "https://fantia.jp/products/249638",
        profile_url: "https://fantia.jp/fanclubs/7",
        artist_name: "弱電波@JackDempa",
        tags: %w[イラスト集 CG集 PNG オリジナル 宮前詩帆 春川朱璃愛 夏川黒羽 ASMR 音声 原神 シニョーラ],
        dtext_artist_commentary_title: "2021年9月更新分[PNG] - September 2021",
        dtext_artist_commentary_desc: <<~EOS.chomp
          商品について2021年9月に更新した分の画像データと同じものとなります。
          バックナンバー購入用としてご利用ください。

          内容は下記の作品です。
          ・【きせかえ】肉便器 https://fantia.jp/posts/879616
          ・放課後パンツ乗せ部 https://fantia.jp/posts/888100
          ・お嬢とあそぼう https://fantia.jp/posts/901611
          ・【ASMR】チャプター6：拘束二穴責め〇〇 https://fantia.jp/posts/908473 ※音声ファイルです
          ・シニョーラさん https://fantia.jp/posts/911526

          有料プランをご利用でない方でも購入できますのでよければ是非！

          (有料プランのご加入者向け) 通常のバックナンバーはこちらです。
          https://fantia.jp/fanclubs/7/backnumbers?month=202109&plan=3309

          -----

          This is the same as the image data updated in September 2021.
          Please use it for purchasing back numbers.

          The content is in the following posts.

          ・[changing clothes] cum dumpster https://fantia.jp/posts/879616
          ・after-school underwear club https://fantia.jp/posts/888100
          ・Let's play with the lady https://fantia.jp/posts/901611
          ・[ASMR] Chapter 6: Restraint and Two-Hole 〇〇〇〇〇〇〇 https://fantia.jp/posts/908473 *Audio file.
          ・La Signora https://fantia.jp/posts/911526

          Even those who do not use the paid plan can purchase it, so please come!

          (For paid plan subscribers) Click here for regular back numbers.
          https://fantia.jp/fanclubs/7/backnumbers?month=202109&plan=3309

          * For those of you overseas who can't pay on Fantia, I've started selling it on Gumroad as well.
          https://jackdempa.gumroad.com/

          -----

          这也是2021年9月更新的图像数据。请利用这项服务购买过去的期刊。

          内容是以下作品。

          ・[换衣服] 垃圾箱 https://fantia.jp/posts/879616
          ・放学后的内衣俱乐部 https://fantia.jp/posts/888100
          ・玩弄女士 https://fantia.jp/posts/901611
          ・[ASMR]第六章：束缚与双孔折磨 https://fantia.jp/posts/908473 *音频文件
          ・La Signora https://fantia.jp/posts/911526

          即使你没有付费计划，如果你喜欢，你仍然可以购买这些东西!

          (对于付费计划的用户)点击这里查看常规的过去的期刊。
          https://fantia.jp/fanclubs/7/backnumbers?month=202109&plan=3309

          * 对于那些不能用Fantia支付的海外人士，我也开始在Gumroad上销售。
          https://jackdempa.gumroad.com/
        EOS
      )
    end

    context "A c.fantia.jp/uploads/product_image/file sample url" do
      strategy_should_work(
        "https://c.fantia.jp/uploads/product_image/file/219407/main_bd7419c2-2450-4c53-a28a-90101fa466ab.jpg",
        referer: "https://fantia.jp/products/249638",
        image_urls: ["https://c.fantia.jp/uploads/product_image/file/219407/bd7419c2-2450-4c53-a28a-90101fa466ab.jpg"],
        media_files: [{ file_size: 613_103 }],
        page_url: "https://fantia.jp/products/249638"
      )
    end

    context "A fantia.jp/posts/$id/download url" do
      strategy_should_work(
        "https://fantia.jp/posts/1143951/download/1830956",
        image_urls: [%r{https://cc.fantia.jp/uploads/post_content/file/1830956/cbcdfcbe_20220224_120_040_100.png}],
        media_files: [{ file_size: 14_371_816 }],
        artist_name: "松永紅葉",
        profile_url: "https://fantia.jp/fanclubs/322",
        page_url: "https://fantia.jp/posts/1143951",
        tags: [],
        dtext_artist_commentary_title: "今日の一枚3186 (1:20+0:40+1:00)",
        dtext_artist_commentary_desc: "今日の一枚3186 (1:20+0:40+1:00)"
      )
    end

    context "A www.fantia.jp/posts/$id/download url" do
      strategy_should_work(
        "https://www.fantia.jp/posts/1143951/download/1830956",
        image_urls: [%r{https://cc.fantia.jp/uploads/post_content/file/1830956/cbcdfcbe_20220224_120_040_100.png}],
        media_files: [{ file_size: 14_371_816 }],
        page_url: "https://fantia.jp/posts/1143951"
      )
    end

    context "A fantia.jp/posts/$id url" do
      strategy_should_work(
        "https://fantia.jp/posts/1143951",
        image_urls: [
          "https://c.fantia.jp/uploads/post/file/1143951/47491020-a6c6-47db-b09e-815b0530c0bc.png",
          %r{https://cc.fantia.jp/uploads/post_content/file/1830956/cbcdfcbe_20220224_120_040_100.png},
        ],
        media_files: [
          { file_size: 1_157_953 },
          { file_size: 14_371_816 },
        ],
        page_url: "https://fantia.jp/posts/1143951",
        profile_url: "https://fantia.jp/fanclubs/322",
        artist_name: "松永紅葉",
        tags: [],
        dtext_artist_commentary_title: "今日の一枚3186 (1:20+0:40+1:00)",
        dtext_artist_commentary_desc: "今日の一枚3186 (1:20+0:40+1:00)"
      )
    end

    context "A fantia.jp/posts/$id blog type url" do
      strategy_should_work(
        "https://fantia.jp/posts/1734300",
        page_url: "https://fantia.jp/posts/1734300",
        image_urls: %w[
          https://c.fantia.jp/uploads/post/file/1734300/ed85ffde-0e85-47f5-ac37-864984550216.gif
          https://c.fantia.jp/uploads/post/file/1649664/83e30463-3ed7-48e9-af21-d9a022bb1e95.png
          https://c.fantia.jp/uploads/post/file/1679805/dc4ad3d8-e0ce-4388-aafc-64046e285de9.png
          https://c.fantia.jp/uploads/post/file/1679848/f5ee8427-eea6-4a51-8eba-5a89fdf2ee48.png
        ],
        profile_url: "https://fantia.jp/fanclubs/7",
        profile_urls: %w[https://fantia.jp/fanclubs/7],
        artist_name: "弱電波@JackDempa",
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp
          つば広お帽子すきです。
          ⭐️お気に入りボタンを押していただけると次の投稿の励みになります。いつも応援ありがとうございます！

          うんうん差分作りました。うんうんの民の救済になれば……。
          zipファイル内にフォルダを分けて入れてあります！

          ▼前回のオリジナルシリーズ：モーターショーのえっちなお姉さん

          ▼過去のオリジナルイラスト一覧

          ▼Fantia5年間の総集編まとめ本委託中です：🐯とらのあな / 🍈メロンブックス

          I like wide-brimmed hats. This time I made a scatology diff, which is in a separate folder in the zip file.
          Please press the ⭐️star (favorite) button to cheer me on! Thank you for your support!
          ⇩🔞下スクロールでエロ差分🔞⇩
        EOS
      )
    end

    context "A fantia.jp/posts/$id blog/album type url" do
      strategy_should_work(
        "https://fantia.jp/posts/2533616",
        page_url: "https://fantia.jp/posts/2533616",
        image_urls: [
          "https://c.fantia.jp/uploads/post/file/2533616/83e6c07c-c28b-4cb0-9d3c-0e30ae54cd6e.jpg",
          %r{https://cc.fantia.jp/uploads/album_image/file/326995/00abd740-74d5-4289-be85-782cb8cdd382.png},
          %r{https://cc.fantia.jp/uploads/album_image/file/326996/12ba15a3-293e-40c8-a872-845bd1277256.jpg},
        ],
        media_files: [
          { file_size: 657_812 },
          { file_size: 3_086_271 },
          { file_size: 444_283 },
        ],
        profile_url: "https://fantia.jp/fanclubs/6088",
        profile_urls: %w[https://fantia.jp/fanclubs/6088],
        artist_name: "すづめ",
        tags: [],
        dtext_artist_commentary_title: "リバーシにまけました",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A fantia.jp/posts/$id blog type url with cloudinary images" do
      strategy_should_work(
        "https://fantia.jp/posts/2702869",
        image_urls: %w[
          https://c.fantia.jp/uploads/post/file/2702869/b4ae077d-b630-42c8-859e-59ab42c3009d.gif
          https://res.cloudinary.com/dwtbde1cn/image/upload/v1713199481/202403_nmaswi.gif
          https://res.cloudinary.com/dwtbde1cn/image/upload/v1713199481/202402_ddevft.gif
          https://res.cloudinary.com/dwtbde1cn/image/upload/v1713199481/202401_olz4f7.gif
          https://res.cloudinary.com/dwtbde1cn/image/upload/v1713199481/202312_xgh7vg.gif
          https://res.cloudinary.com/dwtbde1cn/image/upload/v1675146855/CG%E9%9B%86%E3%83%90%E3%83%8A%E3%83%BC_nabisc.jpg
        ],
        media_files: [
          { file_size: 930_471 },
          { file_size: 1_425_844 },
          { file_size: 1_596_901 },
          { file_size: 1_490_525 },
          { file_size: 1_382_098 },
          { file_size: 183_419 },
        ],
        page_url: "https://fantia.jp/posts/2702869",
        profile_url: "https://fantia.jp/fanclubs/20795",
        profile_urls: %w[https://fantia.jp/fanclubs/20795],
        artist_name: "ぐらんで",
        tag_name: nil,
        other_names: ["ぐらんで"],
        tags: [
          ["オリジナル", "https://fantia.jp/posts?tag=オリジナル"],
          ["フェチ", "https://fantia.jp/posts?tag=フェチ"],
          ["タイツ", "https://fantia.jp/posts?tag=タイツ"],
          ["R18", "https://fantia.jp/posts?tag=R18"],
          ["おっぱい", "https://fantia.jp/posts?tag=おっぱい"],
          ["セックス", "https://fantia.jp/posts?tag=セックス"],
          ["2024年4月", "https://fantia.jp/posts?tag=2024年4月"],
          ["かかかの", "https://fantia.jp/posts?tag=かかかの"],
          ["可愛川美遊", "https://fantia.jp/posts?tag=可愛川美遊"],
        ],
        dtext_artist_commentary_title: "ムラムラしてセッ◯スしちゃう嫁💖",
        dtext_artist_commentary_desc: <<~EOS.chomp
          あそんでつくろ💖
          ※無料プランでも全体図を閲覧可能です！
          右上の【⭐】を押していただければ嬉しいです👌
          ▼３月のおすすめ人気記事：子種を注がれる妻💖

          🔽🔞下スクロールでR18イラスト🔞🔽
        EOS
      )
    end

    context "A fantia.jp/products/$id url" do
      strategy_should_work(
        "https://fantia.jp/products/249638",
        image_urls: %w[
          https://c.fantia.jp/uploads/product/image/249638/fd5aef8f-c217-49d0-83e8-289efb33dfc4.jpg
          https://c.fantia.jp/uploads/product_image/file/219406/c73bd7f9-a13a-48f7-9ac7-35309faa88c3.jpg
          https://c.fantia.jp/uploads/product_image/file/219407/bd7419c2-2450-4c53-a28a-90101fa466ab.jpg
          https://c.fantia.jp/uploads/product_image/file/219408/50aae3fd-11c5-4679-a584-e4276617d4b9.jpg
          https://c.fantia.jp/uploads/product_image/file/219409/1e777b93-2672-4a5d-8076-91b3766d3664.jpg
        ],
        media_files: [
          { file_size: 289_918 },
          { file_size: 515_598 },
          { file_size: 613_103 },
          { file_size: 146_837 },
          { file_size: 78_316 },
        ],
        page_url: "https://fantia.jp/products/249638",
        profile_url: "https://fantia.jp/fanclubs/7"
      )
    end

    context "A fantia.jp .webp sample image url" do
      strategy_should_work(
        "https://c.fantia.jp/uploads/post/file/1132267/main_webp_2a265470-e551-409c-b7cb-04437fd6ab2c.webp",
        image_urls: ["https://c.fantia.jp/uploads/post/file/1132267/2a265470-e551-409c-b7cb-04437fd6ab2c.jpg"],
        media_files: [{ file_size: 240_919 }],
        page_url: "https://fantia.jp/posts/1132267"
      )
    end

    context "A product url with no images" do
      strategy_should_work(
        "https://fantia.jp/products/10000",
        image_urls: []
      )
    end

    context "A deleted or non-existing fantia post" do
      strategy_should_work(
        "https://fantia.jp/posts/12345678901234567890",
        image_urls: []
      )
    end

    context "A deleted or non-existing fantia product" do
      strategy_should_work(
        "https://fantia.jp/products/12345678901234567890",
        image_urls: []
      )
    end

    should "Parse Fantia URLs correctly" do
      assert(Source::URL.image_url?("https://c.fantia.jp/uploads/post/file/1070093/16faf0b1-58d8-4aac-9e86-b243063eaaf1.jpeg"))
      assert(Source::URL.image_url?("https://c.fantia.jp/uploads/product/image/249638/main_fd5aef8f-c217-49d0-83e8-289efb33dfc4.jpg"))
      assert(Source::URL.image_url?("https://c.fantia.jp/uploads/product_image/file/219407/bd7419c2-2450-4c53-a28a-90101fa466ab.jpg"))
      assert(Source::URL.image_url?("https://cc.fantia.jp/uploads/post_content_photo/file/4563389/main_a9763427-3ccd-4e51-bcde-ff5e1ce0aa56.jpg?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnRfcGhvdG8vZmlsZS80NTYzMzg5L21haW5fYTk3NjM0MjctM2NjZC00ZTUxLWJjZGUtZmY1ZTFjZTBhYTU2LmpwZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTY0NjkxMzk3OH19fV19&Signature=jyW5ankfO9uCHlKkozYU9RPpO3jzKTW2HuyXgS81i~cRgrXcI9orYU0IXuiit~0TznIyXbB7F~6Z790t7lX948PYAb9luYIREJC2u7pRMP3OBbsANbbFE0o4VR-6O3ZKbYQ4aG~ofVEZfiFVGoKoVtdJxj0bBNQV29eeFylGQATkFmywne1YMtJMqDirRBFMIatqNuunGsiWCQHqLYNHCeS4dZXlOnV8JQq0u1rPkeAQBmDCStFMA5ywjnWTfSZK7RN6RXKCAsMTXTl5X~I6EZASUPoGQy2vHUj5I-veffACg46jpvqTv6mLjQEw8JG~JLIOrZazKZR9O2kIoLNVGQ__"))
      assert(Source::URL.image_url?("https://cc.fantia.jp/uploads/post_content/file/1830956/cbcdfcbe_20220224_120_040_100.png?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnQvZmlsZS8xODMwOTU2L2NiY2RmY2JlXzIwMjIwMjI0XzEyMF8wNDBfMTAwLnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTY0NjkxNDU4Nn19fV19&Signature=d1nw8gs9vcshIAeEH4oESm9-7z6y4A7MfoIRRvtUtV9iqTNA8KM0ORuCI7NwEoYc1VHsxy9ByeuSBpNaJoknnc3TOmHFhVRcLn~OWpnWqiHEPpMcSEG7uGlorysjEPmYYRGHjE7LJYcWiiJxjZ~fSBbYzxxwsjroPm-fyGUtNhdJWEMNp52vHe5P9KErb7M8tP01toekGdOqO-pkWm1t9xm2Tp5P7RWcbtQPOixgG4UgOhE0f3LVwHGHYJV~-lB5RjrDbTTO3ezVi7I7ybZjjHotVUK5MbHHmXzC1NqI-VN3vHddTwTbTK9xEnPMR27NHSlho3-O18WcNs1YgKD48w__"))
      assert(Source::URL.image_url?("https://fantia.jp/posts/1143951/download/1830956"))

      assert(Source::URL.page_url?("https://fantia.jp/posts/1148334"))
      assert(Source::URL.page_url?("https://fantia.jp/products/249638"))

      assert(Source::URL.profile_url?("https://fantia.jp/fanclubs/64496"))
      assert(Source::URL.profile_url?("https://fantia.jp/asanagi"))
    end
  end
end
