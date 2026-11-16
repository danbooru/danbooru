require "test_helper"

module Source::Tests::Extractor
  class MyPortfolioExtractorTest < ActiveSupport::ExtractorTestCase
    context "A sample image URL" do
      strategy_should_work(
        "https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/c7aa631f-3b26-47c7-9b06-ccddb68f0a91_rw_3840.jpg?h=a9596060df5dd40e5b8dfc1efe01aaed",
        image_urls: %w[https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/c7aa631f-3b26-47c7-9b06-ccddb68f0a91_rw_3840.jpg?h=a9596060df5dd40e5b8dfc1efe01aaed],
        media_files: [{ file_size: 4_306_216 }],
        page_url: nil,
        profile_url: nil,
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        tag_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A full image URL" do
      strategy_should_work(
        "https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/c7aa631f-3b26-47c7-9b06-ccddb68f0a91.jpg?h=472290e9e754255494bd2996a3eaffe0",
        image_urls: %w[https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/c7aa631f-3b26-47c7-9b06-ccddb68f0a91.jpg?h=472290e9e754255494bd2996a3eaffe0],
        media_files: [{ file_size: 10_574_178 }],
        page_url: nil,
        profile_url: nil,
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        tag_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A MyPortfolio page with a single image" do
      strategy_should_work(
        "https://sekigahara023.myportfolio.com/ea-apexlegends-4",
        image_urls: %w[https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/c7aa631f-3b26-47c7-9b06-ccddb68f0a91.jpg?h=472290e9e754255494bd2996a3eaffe0],
        media_files: [{ file_size: 10_574_178 }],
        page_url: "https://sekigahara023.myportfolio.com/ea-apexlegends-4",
        profile_url: "https://sekigahara023.myportfolio.com",
        profile_urls: %w[https://sekigahara023.myportfolio.com],
        display_name: "関ケ原023Webサイト",
        username: "sekigahara023",
        tag_name: "sekigahara023",
        other_names: ["関ケ原023Webサイト", "sekigahara023"],
        tags: [],
        dtext_artist_commentary_title: "ApexLegends 4周年記念 ファミ通掲載イラスト",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          ファミ通のApexLegends4周年記念特集の掲載作品です。制作期間－約3週間
        EOS
      )
    end

    context "A MyPortfolio page with multiple images" do
      strategy_should_work(
        "https://sekigahara023.myportfolio.com/162ecc19294305",
        image_urls: %w[
          https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/a56f2235-fc44-45b8-bf7d-98ba7e463b28.png?h=92024944431f8db0e2769c0e0b59eeaa
          https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/81648ba8-aff3-4d4f-a248-3c67331e9b7a.png?h=2e7960e7025d7b1a0683ca39b1e40824
        ],
        media_files: [
          { file_size: 2_105_702 },
          { file_size: 1_886_285 },
        ],
        page_url: "https://sekigahara023.myportfolio.com/162ecc19294305",
        profile_url: "https://sekigahara023.myportfolio.com",
        profile_urls: %w[https://sekigahara023.myportfolio.com],
        display_name: "関ケ原023Webサイト",
        username: "sekigahara023",
        tag_name: "sekigahara023",
        other_names: ["関ケ原023Webサイト", "sekigahara023"],
        tags: [],
        dtext_artist_commentary_title: "Vtuverポル様 ご依頼品",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          制作時間－合わせて約8日
        EOS
      )
    end

    context "A MyPortfolio gallery page where each image has its own page" do
      strategy_should_work(
        "https://sekigahara023.myportfolio.com/work",
        image_urls: %w[],
        media_files: [],
        page_url: "https://sekigahara023.myportfolio.com/work",
        profile_url: "https://sekigahara023.myportfolio.com",
        profile_urls: %w[https://sekigahara023.myportfolio.com],
        display_name: "関ケ原023Webサイト",
        username: "sekigahara023",
        tag_name: "sekigahara023",
        other_names: ["関ケ原023Webサイト", "sekigahara023"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A MyPortfolio gallery page where each image doesn't have its own page" do
      strategy_should_work(
        "https://shiori-shii.myportfolio.com/portfolio",
        image_urls: %w[
          https://pro2-bar-s3-cdn-cf2.myportfolio.com/59753a162c5d8748646b051378da184f/3f8cfe1d-86c3-413b-b55c-400dc9e5159e_rw_1920.jpg?h=7abd9c3ef81c13e8a77a8d7210004e4f
          https://pro2-bar-s3-cdn-cf3.myportfolio.com/59753a162c5d8748646b051378da184f/46fb9d5b-1c8e-4742-801b-726c9efe7fbc_rw_1200.png?h=243b38db8efb3b8a5a0adec116cc9e82
          https://pro2-bar-s3-cdn-cf2.myportfolio.com/59753a162c5d8748646b051378da184f/d2ffa64a-14da-4f2d-99fe-df5415a2315f_rw_1920.png?h=f4d64d562a8895f8827d651cde183002
          https://pro2-bar-s3-cdn-cf2.myportfolio.com/59753a162c5d8748646b051378da184f/37e87d81-1099-4648-ab36-92792e2cf81d_rw_1920.png?h=4abb59774f8c3a6c0e38f4b18e197655
          https://pro2-bar-s3-cdn-cf.myportfolio.com/59753a162c5d8748646b051378da184f/8b529113-84ae-4bd3-99ef-79fe3b2b8523_rw_1920.png?h=291a83f431a771e3e623d37ddebd75f1
          https://pro2-bar-s3-cdn-cf2.myportfolio.com/59753a162c5d8748646b051378da184f/3357a87e-88b9-42b5-b540-94b94b54e1d8_rw_1920.png?h=91eccbb452c1f9f90d3da6fc237ff7a6
          https://pro2-bar-s3-cdn-cf5.myportfolio.com/59753a162c5d8748646b051378da184f/69b1fc15-4a61-446b-a1f9-55869eeb4e2c_rw_1920.png?h=945ffe077936832d408d2df586072dd0
          https://pro2-bar-s3-cdn-cf1.myportfolio.com/59753a162c5d8748646b051378da184f/202283d1-d349-43d2-b20e-e42a3594d5a0_rw_1920.png?h=5b2ed01dc7702490bb35a560e185482b
        ],
        media_files: [
          { file_size: 1_309_730 },
          { file_size: 764_266 },
          { file_size: 3_330_665 },
          { file_size: 3_422_386 },
          { file_size: 3_223_691 },
          { file_size: 2_998_597 },
          { file_size: 2_487_860 },
          { file_size: 3_024_153 },
        ],
        page_url: "https://shiori-shii.myportfolio.com/portfolio",
        profile_url: "https://shiori-shii.myportfolio.com",
        profile_urls: %w[https://shiori-shii.myportfolio.com],
        display_name: "栞のアトリエ",
        username: "shiori-shii",
        tag_name: "shiori-shii",
        other_names: ["栞のアトリエ", "shiori-shii"],
        tags: [],
        dtext_artist_commentary_title: "作品",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A MyPortfolio page with a mix of text and images" do
      strategy_should_work(
        "https://shiori-shii.myportfolio.com/work-1",
        image_urls: %w[
          https://pro2-bar-s3-cdn-cf.myportfolio.com/59753a162c5d8748646b051378da184f/199ec693-0d0c-43eb-81c3-60c6114cb4bf.jpg?h=0098a43e91490501bdc68894c637939d
          https://pro2-bar-s3-cdn-cf6.myportfolio.com/59753a162c5d8748646b051378da184f/77f237b4-25e9-46ed-b8ef-2b3709c92491.jpg?h=021034439a138a0920b78342343cb37e
        ],
        media_files: [
          { file_size: 4_614_324 },
          { file_size: 544_967 },
        ],
        page_url: "https://shiori-shii.myportfolio.com/work-1",
        profile_url: "https://shiori-shii.myportfolio.com",
        profile_urls: %w[https://shiori-shii.myportfolio.com],
        display_name: "栞のアトリエ",
        username: "shiori-shii",
        tag_name: "shiori-shii",
        other_names: ["栞のアトリエ", "shiori-shii"],
        tags: [],
        dtext_artist_commentary_title: "制作実績",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "[image]":[https://pro2-bar-s3-cdn-cf.myportfolio.com/59753a162c5d8748646b051378da184f/199ec693-0d0c-43eb-81c3-60c6114cb4bf_rw_3840.jpg?h=4feabf5ead1c0cd86ce6dfd3a93e037a]

          株式会社月鈴舎様
          TVアニメ「みるタイツ」応援イラスト制作

          "[image]":[https://pro2-bar-s3-cdn-cf6.myportfolio.com/59753a162c5d8748646b051378da184f/77f237b4-25e9-46ed-b8ef-2b3709c92491_rw_1200.jpg?h=24a897ae2c7f7ffdaf8ab60b3bd3f8fb]

          腕時計ブランド KLASSE14様
          腕時計PRイラスト
        EOS
      )
    end

    context "A MyPortfolio page without any images" do
      strategy_should_work(
        "https://sekigahara023.myportfolio.com/about",
        image_urls: [],
        media_files: [],
        page_url: "https://sekigahara023.myportfolio.com/about",
        profile_url: "https://sekigahara023.myportfolio.com",
        profile_urls: %w[https://sekigahara023.myportfolio.com],
        display_name: "関ケ原023Webサイト",
        username: "sekigahara023",
        tag_name: "sekigahara023",
        other_names: ["関ケ原023Webサイト", "sekigahara023"],
        tags: [],
        dtext_artist_commentary_title: "About",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          関ヶ原023（せきがはらおじさん）

          ご連絡先

          256gigab@gmail.com

          "Twitter":[https://twitter.com/SEKIGAHARA023]

          "pixiv":[https://www.pixiv.net/users/22221993]

          "Skeb":[https://skeb.jp/@SEKIGAHARA023]

          "Tiktok":[https://www.tiktok.com/@kubo_3?_t=8jXWSUZUhJy&_r=1]

          🌟コンテスト受賞歴

          ・XP-PEN パッケージイラストコンテスト 審査員賞受賞

          ・APEX LEGENDS ＃レジェンドと共に(第2回) Respawn Entertainment賞受賞

          🌟企業様ご依頼

          ・Electronic Arts様 ApexLegends イラスト制作

          ApexLegendsMobile イラスト制作

          ・カプコン様 ストリートファイター6×カプくじ イラスト制作

          ・株式会社コアデ様 ヴァンねねくじ イラスト制作

          ・株式会社FATTRUNK様 ASGS大会 KV制作

          ・シュガービッツ様 eスポーツ大会「SoulZ」イラスト制作

          ・ソラジマ様 Webtoon作品 一部人物作画

          「逆行令嬢の復讐計画」

          「傷だらけ聖女より報復をこめて」

          「消える私に夫の愛はいりません」

          「愛されてる場合じゃないの」

          ・DMM様その他企業様 イラスト制作協力多数

          🌟個人様ご依頼

          ・Restia様×杏仁ミル様 Apex Legends 大会キービジュアル/アクスタイラスト

          ・Fleur Rose 愛華様 アルバム「Miss you」全曲イラスト

          ・Rosecreate所属アーティスト様 イラスト多数

          ・Vtuberイデア様 動画用キャラクターイラスト

          ・オヤスミめざまし様 MVイラスト

          ・Vtuber大島ゆり様 キャラクターデザイン

          ・Vtuber夕暮坂灯歌様 MVイラスト2点

          ・ふみんちゃん様 MVイラスト

          ・Vtuber宇宙人ロキ様 配信用キャラクターイラスト

          ・Vtuver花守栞様 MVイラスト

          ・Vtuverポル様 配信用キャラクターイラスト2点

          ・Vtuberたまこ様 キャラクターイラスト2点

          ・Yong様 MVイラスト

          ・Vtuberぴぴぴぷちぽ様 MVイラスト

          その他ご依頼多数

          🌟メッセージ

          作品は随時追加していきます。

          こちらに掲載していない作品もTwitterやpixivに多数ございますので、

          そちらもよければお目通し頂けますと嬉しいです。

          全力の作品づくりをしますので、どうぞよろしくお願いいたします。
        EOS
      )
    end

    context "A MyPortfolio gallery page with a custom domain" do
      strategy_should_work(
        "https://artgerm.com/dc-comics-b",
        image_urls: %w[
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/2eed3dd0-3ebb-4159-a8e5-f5ce67f1a579_rw_1200.jpg?h=77e1683694d802138968384e1e2d9648
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/8a3c9941-85f8-48fa-9fb2-d06ced997197_rw_1200.jpg?h=15515d07be405b0774f2a06e06a9b6bd
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/a63961eb-663f-4be6-a3dd-f224d933f76c_rw_1200.jpg?h=26d866c72f450bf76d1681ea62da264b
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/baa6ed83-5fa2-4ddd-911e-0c910ee4b594_rw_1200.jpg?h=195d32b3ba3a2b92da5c135754b9e9dd
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/0ab3a574-c77c-48ec-8229-fca5c200c846_rw_1200.jpg?h=bcc29f95f8b85b9b347d1ede1eb0d25a
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/fdb14b44-7110-4df3-b26c-e0ec4149ec40_rw_1200.jpg?h=95cd0d36d6ad06e5999e697ce2bdc1cb
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/ff7e8422-5756-47e3-944e-dbb8cef0da09_rw_1200.jpg?h=42af643817d2a43d15c0b4c416fc858f
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/6d82039e-8f39-4c93-b359-d5bbacc3bdcc_rw_1200.jpg?h=d3a198cc03bd5d6237ee63f85edb5292
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/3ae88ce9-3987-44c5-b54c-a1d18d1a9b50_rw_1200.jpg?h=c5e71de3d11e129ceb1c1e0618b7810d
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/e2e857d1-4307-46ea-8176-1674cf6bef0b_rw_1200.jpg?h=74f0281e3557d265dbc9ea461c61970b
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/c0ba149c-ad4b-4c43-bf66-93e0e228fca6_rw_600.jpg?h=03864d87ffeb527ab05e770976c8c87e
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/d7d87d2e-3a12-49b3-8dff-f1c828da438e_rw_600.jpg?h=c2c9cdab5f5ec16bba1bbf4fe5f0c46c
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/08dc724e-c31e-4523-8af3-196d46ae5d4a_rw_600.jpg?h=1a6de8f3e9de815570b31cf620f167da
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/25391448-2ad4-43d8-8c14-0bb2d2ab95b4_rw_600.jpg?h=62520541ed337650f8adf3811943f217
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/3df153c1-5b6a-4616-9dae-94e770b54bb4_rw_600.jpg?h=c5735bf22b1fe341bf5649f67d3c1d23
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/6d3be5f8-5fa2-4e81-808a-0d50078824d6_rw_600.jpg?h=f0a381a955131a2d94b50a67ffad3438
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/26b9e086-1cdd-40f4-b1f6-1b037e1ed40d_rw_600.jpg?h=cd59f1d2f8ee979dcc290a9345ae19ba
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/046bde95-926b-4879-85ec-530c50bc8a21_rw_1200.jpg?h=3e448f8f610c3603ed708646ff997487
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/fc4612e8-2b06-4e4d-9fc1-d2426f403256_rw_600.jpg?h=2a724854a5c05ef03704e812c548583b
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/8510b012-d6bb-439a-9c77-bc90860a5f9f_rw_1200.jpg?h=fa80f42f182535a6adee1f077d6478ed
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/8aaa6e0a-3529-4a28-b86f-ccd4c8e6c4da_rw_1200.jpg?h=53df14373330c5dcd4c6d009cfe79302
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/8d57769c-1281-4e1d-88f6-9a3dac2fe908_rw_1200.jpg?h=1a99412b28422bba44e4c2e7e236aa8b
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/f61653fd-14b7-42a2-a907-07d0b8cc6d7f_rw_1200.jpg?h=2a6f891e62a1b8a69e9993fb1aa10436
          https://cdn.myportfolio.com/3a87c4599bde55ea6e62b2756c9e48ab/fd789c3a-c59b-40ed-bbd8-a9df7cf6cb9f_rw_600.jpg?h=c9aa168f922f8f6f9b1810203c12ffcc
        ],
        media_files: [
          { file_size: 375_771 },
          { file_size: 376_614 },
          { file_size: 269_579 },
          { file_size: 405_080 },
          { file_size: 234_007 },
          { file_size: 327_279 },
          { file_size: 377_935 },
          { file_size: 382_858 },
          { file_size: 383_752 },
          { file_size: 398_324 },
          { file_size: 169_155 },
          { file_size: 308_489 },
          { file_size: 188_284 },
          { file_size: 293_803 },
          { file_size: 296_693 },
          { file_size: 215_767 },
          { file_size: 219_426 },
          { file_size: 309_855 },
          { file_size: 185_610 },
          { file_size: 241_673 },
          { file_size: 261_060 },
          { file_size: 309_888 },
          { file_size: 251_733 },
          { file_size: 211_057 },
        ],
        page_url: "https://artgerm.com/dc-comics-b",
        profile_url: "https://artgerm.com",
        profile_urls: %w[https://artgerm.com],
        display_name: "Stanley Artgerm Lau",
        username: nil,
        tag_name: "stanley_artgerm_lau",
        other_names: ["Stanley Artgerm Lau"],
        tags: [],
        dtext_artist_commentary_title: "DC Comics 3",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A MyPortfolio post page with a custom domain" do
      strategy_should_work(
        "https://tooco.com.ar/6-of-diamonds-paradise-bird",
        image_urls: %w[
          https://cdn.myportfolio.com/ea94248a8ad87a031cf807d40eb5ac83/4e578de7400d3ffa7566376b.jpg?h=d4175c45d88c67e51c1cbfce49decc3b
          https://cdn.myportfolio.com/ea94248a8ad87a031cf807d40eb5ac83/af57cb30368b3d3b3576fe81.jpg?h=d656289b0092beab1297ad678ef12647
          https://cdn.myportfolio.com/ea94248a8ad87a031cf807d40eb5ac83/42e3fff0107e417fde1053a5.jpg?h=a1ea27ce8ed8ca8c19d6fc9a8f761815
        ],
        media_files: [
          { file_size: 1_073_457 },
          { file_size: 720_852 },
          { file_size: 703_521 },
        ],
        page_url: "https://tooco.com.ar/6-of-diamonds-paradise-bird",
        profile_url: "https://tooco.com.ar",
        profile_urls: %w[https://tooco.com.ar],
        display_name: "TOOCO",
        username: nil,
        tag_name: "tooco",
        other_names: ["TOOCO"],
        tags: [],
        dtext_artist_commentary_title: "Visual Art, Illustration & Design - 6 of Diamonds Paradise Bird",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Illustration and card design for Playing Arts Cards, Edition 3.

          "[image]":[https://cdn.myportfolio.com/ea94248a8ad87a031cf807d40eb5ac83/4e578de7400d3ffa7566376b_rw_1920.jpg?h=70c316859053e0140e6102f60ecfb13c]

          "[image]":[https://cdn.myportfolio.com/ea94248a8ad87a031cf807d40eb5ac83/af57cb30368b3d3b3576fe81_rw_1920.jpg?h=7a34fa585a387d6fe534680114fd77f4]

          "[image]":[https://cdn.myportfolio.com/ea94248a8ad87a031cf807d40eb5ac83/42e3fff0107e417fde1053a5_rw_1920.jpg?h=599fb064e15bd811b81745569dc5c7e3]

          ◊ - ◊ - ◊
        EOS
      )
    end
  end
end
