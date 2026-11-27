require "test_helper"

module Source::Tests::Extractor
  class SkimaExtractorTest < ActiveSupport::ExtractorTestCase
    context "A gallery post with multiple images" do
      strategy_should_work(
        "https://skima.jp/gallery?id=6428",
        image_urls: %w[
          https://cdn-gallery.skima.jp/gallery/017/284/17284/d1905510dbb435ce81cc4056c32055d8-20171226132800.jpeg
          https://cdn-gallery.skima.jp/gallery/055/208/55208/7b086a7cdfaa95d1e38e183344a1d829-20190215093718.jpeg
        ],
        media_files: [
          { file_size: 327_685 },
          { file_size: 288_903 },
        ],
        page_url: "https://skima.jp/gallery?id=6428",
        profile_url: "https://skima.jp/profile?id=1927",
        profile_urls: %w[https://skima.jp/profile?id=1927],
        display_name: "猫箸",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["キャラクター", "https://skima.jp/gallery/search?tag=キャラクター"],
          ["女の子", "https://skima.jp/gallery/search?tag=女の子"],
          ["イラスト", "https://skima.jp/gallery/search?tag=イラスト"],
          ["東方", "https://skima.jp/gallery/search?tag=東方"],
          ["可愛い", "https://skima.jp/gallery/search?tag=可愛い"],
          ["FGO", "https://skima.jp/gallery/search?tag=FGO"],
        ],
        dtext_artist_commentary_title: "一枚絵イラストまとめ",
        dtext_artist_commentary_desc: "CDジャケットやTCGイラスト、表紙等今まで描かせて頂いたものを掲載しています",
      )
    end

    context "A commission with sample images on skima.jp" do
      strategy_should_work(
        "https://skima.jp/item/detail?item_id=169712",
        image_urls: %w[
          https://cdn-common.skima.jp/item/830/165/1830165/65d2ad6c9fd348e89bf69c08ccb85545-20260310222935.jpeg
          https://cdn-common.skima.jp/item/902/978/1902978/8115d7579c5f912d10996a39ecff906e-20260810214959.jpeg
          https://cdn-common.skima.jp/item/902/980/1902980/049be1002be0974d929c57a167b0ea27-20260810215108.png
          https://cdn-common.skima.jp/item/727/378/1727378/3b08229cfb02203372294db496469732-20250814215520.png
          https://cdn-common.skima.jp/item/902/981/1902981/bcf6d915b131a6400b09d8cd175040e8-20260810215121.png
          https://cdn-common.skima.jp/item/927/405/1927405/6c401b217ccbf0152ffa27f2a47c8d10-20261012204214.png
        ],
        media_files: [
          { file_size: 315_573 },
          { file_size: 246_853 },
          { file_size: 871_922 },
          { file_size: 902_359 },
          { file_size: 952_892 },
          { file_size: 1_029_101 },
        ],
        page_url: "https://skima.jp/item/detail?item_id=169712",
        profile_url: "https://skima.jp/profile?id=1927",
        profile_urls: %w[https://skima.jp/profile?id=1927],
        display_name: "猫箸",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "【企業実績多数！商用費込】プロ品質のvtuber立ち絵制作",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          【2025 5/7】商用利用費込の価格に改訂いたしました！

          vtuber向けのLive2d用パーツ分け立ち絵をお仕立てさせて頂きます！
          オプション無しで、瞳揺れの実装が可能な精度のパーツ分け仕様でお渡しいたします🌸
          ご希望があれば、提携モデラー様のご紹介、連携した制作が可能です！

          ＊既に活動されている方、固定デザインがある方のお仕立て直しも承っております！

          ＊パーツ分けイラストのみの料金となります。お見積もり、制作内容にモデリングは含んでおりませんのであらかじめご了承くださいませ。

          ◾️ポートフォリオ、ご依頼規約
          https://312tikuwa.wixsite.com/-site

          ◾️主な実績
          ・2019年 にじさんじ所属vtuberMVイラスト(ANYCOLOR株式会社様)
          ・2019年 にじさんじ所属赤羽葉子様配信用イラスト(ANYCOLOR株式会社様)
          ・2024年 PROMISU3期 舞日いこか様モデルイラスト(株式会社PLAX様)
          ・2025年 アソビシステム株式会社 ANNIN所属 月宮まどか様モデルイラスト
          ・2025年 Vtuber LIVEイベント “Ribbon parade”キービジュアルイラスト
          (株式会社Newrona様)
          ・2025年 Vtuber LIVEイベント “RISERVERSE”キービジュアルイラスト(株式会社Newrona様)

          新規衣装や周年グッズイラストなどの継続ご依頼も歓迎しております🌸

          ◾️得意な制作内容
          可愛らしい女性キャラクター、中性的な男性キャラクターの作画が得意です！

          ■制作フロー
          ヒアリング→ラフ画→清書、パーツ分け→最終調整
          各フロー毎に提出、修正点のご確認を行わせて頂きます！

          ■修正に関して
          ラフ画時点で3回、清書後1回の無償リテイクが可能です！
          ※当方のミス(塗りミスやパーツの漏れなど)に関してはリテイク回数に含みません。

          ■著作権について
          買取希望される場合は予めお伝えくださいませ！
          (原則企業様のみ。個人様でご希望の方はご相談をお願いいたします。)

          ■料金について
          【メイン立ち絵】
          (商用費用込、可動範囲による目安)
          ・頭部パーツ分けイラスト ¥100000〜
          ・上半身パーツ分けイラスト ¥150000〜
          ・全身パーツ分けイラスト ¥180000〜250000
          ＊立ち絵自体はいずれも全身での制作となります。
          ＊SKIMA手数料が発生いたします。

          【差分・オプション】
          ・表情差分 一種 ¥1500〜
          ・手元差分 一種 ¥8000〜
          ・髪型差分(全体) ¥30000〜
          ・アウター等着脱 ¥20000〜¥50000
          ・ケモ耳、尻尾作成 ¥4000〜
          ・オッドアイ ¥2000

          上記に記載のない差分やオプションもお気軽にご相談くださいませ🌸

          モデルデザインによって変動がございますので、下記テンプレートをご記入の上、メッセージよりお見積もりご相談くださいませ。
          ご希望ご予算が予めお決まりでしたら、金額に応じた制作プランのご提案も可能です！

          ✳︎お見積もり用テンプレート✳︎
          各種参考画像の添付をお願いします！
          ---------------
          ・性別:
          ・ポーズ希望の有無:
          (特になければ左右対称で金額を抑えての制作となります！)
          ・身長イメージ(cm):
          ・体型イメージ:
          ・髪型イメージ:
          ・服装概要(トップス、ボトムス、脚元各種)
          ・パーツ分けの希望範囲:
          (頭部のみ、上半身、全身)
          ・希望納期:
          ・希望予算(あれば):
          その他備考(猫耳や羽、その他装飾、差分のご希望など)
          ---------------

          ▪️パーツ分け仕様
          モデリング時の仕上がりが魅力的になるよう、顔周りや女性キャラクターの胸元など、主要パーツに関しては塗り単位で細かなパーツ分けを行います！
          また前髪に関してはなるべく細かく毛束ごとに分割してご用意いたします！
          ※後頭部別途

          瞳揺れ用パーツ分離を標準で含み、後頭部のつむじ分離や袖などの裏面作成、落ち影の分離を含めて丁寧に制作いたします。
          (パーツ分けご指定範囲外は統合パーツでのご用意となります。)

          パーツ分けの仕様・制作料金は、普段提携しているモデラー様に問題なく制作いただけているパーツ仕様を基準としております！
          背面法や細かなリネームなどの調整に関しては内容に応じて料金を含め応相談となります。

          パーツ分け指定範囲に関しては、モデラー様の手でご自由に塗りたし等調整いただいて問題ございません！

          綺麗なデータ作成を心がけておりますが、提携外のモデラー様にご依頼される場合は、ある程度ご自身でデータ調整が可能な方にご依頼頂くことを推奨いたします。
          (特に高稼働モデリングをご希望される場合)

          お見積もりのご希望やご質問などお気軽にお声がけくださいませ！
          お問い合わせお待ちしております✨
        EOS
      )
    end

    context "An adoptable (opt販売) post with multiple images" do
      strategy_should_work(
        "https://skima.jp/dl/detail?id=400576",
        image_urls: %w[
          https://cdn-common.skima.jp/dlsample/545/135/3545135/3407fda42109d68db315fb7ae38a8239-20261113223746.jpeg
          https://cdn-common.skima.jp/dlsample/545/136/3545136/9a0488f67b42f25160ab5d40f837dfcb-20261113223754.png
          https://cdn-common.skima.jp/dlsample/545/137/3545137/1c7cdb2fb39ccec6e395b2ee5285e652-20261113223800.png
          https://cdn-common.skima.jp/dlsample/545/138/3545138/995da7cd68a764c7c38c5b0fd9db6bf0-20261113223807.png
          https://cdn-common.skima.jp/dlsample/545/139/3545139/d7210258d981fb4b4a5598253fb2a237-20261113223814.png
          https://cdn-common.skima.jp/dlsample/545/140/3545140/f137b572547ba4514f3670389e2ee671-20261113223818.png
          https://cdn-common.skima.jp/dlsample/545/141/3545141/5091f304cab17ea4c84cb696790bda68-20261113223823.png
          https://cdn-common.skima.jp/dlsample/545/142/3545142/47df013f59d7c90c0953113814f53664-20261113223828.png
          https://cdn-common.skima.jp/dlsample/545/143/3545143/8e113cdce7d397d69a0f8a93f9f30d4e-20261113223835.png
          https://cdn-common.skima.jp/dlsample/545/144/3545144/07161aeda8f0add61db46289bb99461d-20261113223838.png
          https://cdn-common.skima.jp/dlsample/545/145/3545145/3896a6937f3eae8611bb96c6cf260db5-20261113223843.png
        ],
        media_files: [
          { file_size: 4_059_032 },
          { file_size: 2_738_323 },
          { file_size: 2_739_475 },
          { file_size: 2_738_283 },
          { file_size: 2_737_586 },
          { file_size: 2_738_393 },
          { file_size: 2_740_128 },
          { file_size: 1_717_089 },
          { file_size: 1_775_083 },
          { file_size: 1_717_318 },
          { file_size: 1_772_569 },
        ],
        page_url: "https://skima.jp/dl/detail?id=400576",
        profile_url: "https://skima.jp/profile?id=343119",
        profile_urls: %w[https://skima.jp/profile?id=343119],
        display_name: "108",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "【表情6種＋仕草4種】くたびれたコートの男性【タバコ】",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          閲覧いただきありがとうございます。

          スーツにコートのくたびれた雰囲気の男性です。
          くたびれて不健康そうなおじさんって最高ですよね！！！！！！！！！！！！！！！！！！！！
          仕草差分として煙草(＋缶コーヒー)を持った演技仕草が４種ついております。
          主にTRPGやゲーム、動画にてご利用いただけます。

          【納品内容】
          ・全身差分 6種
          →標準、げんなり、葛藤、閉じ目、目そらし、冷や汗
          ・仕草差分 4種※全身差分の上に重ねてご使用ください。
          (名前の頭に〇がついています)
          →手下ろし、煙草、首、缶コーヒー

          【形式等】
          ・透過PNG
          ・350dpi
          ・縦3000×横1200px

          【諸注意】
          ●ご利用OK
          ・TRPG、ゲーム、動画等にてご利用いただけます。（商用含）
          →例：SNS等でのTRPGへの利用報告（スクリーンショットの掲載等）
          ・購入者様及び購入者様の周辺でのキャラクターを利用した二次創作もお気兼ねなくどうぞ。
          ・軽度の加工
          →原型を損ねない範囲での色変更、加筆、他素材との併用、トリミング

          ●ご利用NG
          ・自作発言、二次配布、転売等の第三者への受渡行為は禁止させていただきます。
          ・政治・宗教・反社会的活動及びあらゆるヘイト行為利用のためのご購入はおやめください。
          ・著作人格権の侵害にあたる行為はおやめください。
          ・購入したキャラクターをAI学習等に利用するのはご遠慮ください。

          ※このイラストを利用したことによるトラブルについて、当方は一切責任を負いません。
          ※制作例としてイラストをSNS・ポートフォリオ等で公開する場合があります。
          ※クレジット表記は任意ですが、もししていただけるとありがたいです。

          ご不明点等ございましたら、ご連絡のほどよろしくお願いいたします。
        EOS
      )
    end

    context "A pre-made illustration on the international site" do
      strategy_should_work(
        "https://commission.skima.jp/en/pre-made-illustration/detail/388844",
        image_urls: %w[
          https://cdn-common.skima.jp/dlsample/439/019/3439019/4ba8f916a70dd2eed65db0a9ef49e002-20260802220619.jpg
          https://cdn-common.skima.jp/dlsample/439/020/3439020/398071311e78e56be2ee7f0366bbaf9e-20260802220622.png
          https://cdn-common.skima.jp/dlsample/439/021/3439021/a9a99830c09716ddd7fb760a5e66822e-20260802220627.png
        ],
        media_files: [
          { file_size: 668_770 },
          { file_size: 2_117_248 },
          { file_size: 2_119_557 },
        ],
        page_url: "https://commission.skima.jp/pre-made-illustration/detail/388844",
        profile_url: "https://skima.jp/profile?id=24831",
        profile_urls: %w[https://skima.jp/profile?id=24831],
        display_name: "potato",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "差分あり　スーツ　制服　女の子　現代ファンタジー　組織　青髪　サングラス",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          ご覧いただきありがとうございます。
          出品者が制作した、オリジナルキャラクターの全身立ち絵です。

          元気で爽やかな雰囲気の女の子をイメージして描きました！
          企画・イメージキャラクター・TRPG・VTuber活動など、さまざまな用途でご自由にお使いいただけたら嬉しいです！

          ◆内容◆

          ・全身立ち絵
          ・差分 1種類（合計2枚になります。）
          ・PNG形式（透過）
          ・サイズ：縦2000px × 横1416px

          ◆使用について◆

          ・自作発言はご遠慮ください。
          ・実績紹介やオーダー受付時のサンプルとして使用する場合があります。
          （その際は、画像に「SAMPLE」の文字を入れて使用いたします。）

          気になる点などがありましたら、お気軽にご相談ください!
          よろしくお願いいたします!

          青色，ハーフツイン，女性，女子，スカート，黒
        EOS
      )
    end

    context "A commission on the international site" do
      strategy_should_work(
        "https://commission.skima.jp/en/commission/detail/307121",
        image_urls: %w[
          https://cdn-common.skima.jp/item/604/144/1604144/b4caf6639c5dde3e528ad5ed36d3daec-20241227020423.png
          https://cdn-common.skima.jp/item/604/118/1604118/dfdf70f509a380d810d668413c4095a5-20241227013937.png
          https://cdn-common.skima.jp/item/604/124/1604124/87cd1b8194dda1fc49c1b0fec2f6e2a9-20241227014630.jpeg
          https://cdn-common.skima.jp/item/604/125/1604125/2b97cb58a6eed99d1900a30cf42ded34-20241227014639.jpeg
          https://cdn-common.skima.jp/item/604/126/1604126/b1bc8d2d570fa04fa2dd6e3c9390d0a0-20241227014642.jpeg
          https://cdn-common.skima.jp/item/604/146/1604146/84862f5f8f7f7e8606f83a1c3aac7299-20241227020436.png
        ],
        media_files: [
          { file_size: 1_472_078 },
          { file_size: 1_577_277 },
          { file_size: 263_058 },
          { file_size: 293_107 },
          { file_size: 239_715 },
          { file_size: 1_328_013 },
        ],
        page_url: "https://commission.skima.jp/commission/detail/307121",
        profile_url: "https://skima.jp/profile?id=32030",
        profile_urls: %w[https://skima.jp/profile?id=32030],
        display_name: "Yum",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "世界観のあるイラスト全般オーダー♡最短即日納品",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          元作品やテーマの"世界観"を大切にした、まるであなたのキャラクターがその世界に初めからいるような一枚絵をお描きします^^*
          二人の日常を切り取って欲しい、特別な瞬間を素敵な演出で、一見夢絵に見えないかっこいいイラストが欲しい、どんなご希望も叶えてみせます*°
          一行ポエム、お題、セリフ、曲などからでもイラスト化できます。

          女夢主、男夢主、3L可能です！
          夢絵以外にも様々な用途、媒体、目的に対応しております。

          ◆基本◆
          構図…キャラ一人、バストアップ
          背景…白or単色or簡単なデザイン背景
          サイズ解像度…1000×1000、解像度72dpi、png
          塗り…指定がない場合ブラシ塗り

          【お取引の流れ】

          お問い合わせ＋ご相談
          ↓
          専用出品
          ↓
          ご購入＆ヒアリング
          ↓
          ラフ提出(訂正)
          ↓
          完成品提出(訂正)
          ↓
          納品
          ↓
          相互評価

          オプションにない媒体の注文にも対応していますので、まずはお気軽にご相談を^^*

          個人鑑賞用はもちろん、ペアアイコン、PCやスマホの壁紙、本の表紙や挿絵、TRPG、立ち絵、コンセプトアート、デザイン、グッズなど何でもお任せ下さい！
          存じ上げないジャンルやキャラであっても、丁寧にヒアリングし対応します。

          納期調整＋双方のトラブル回避のために、ご依頼前のお見積もり相談必須です。
          お手数をお掛けしますが、よろしくお願い致します。
        EOS
      )
    end

    context "A full-size gallery image" do
      strategy_should_work(
        "https://cdn-gallery.skima.jp/gallery/017/284/17284/d1905510dbb435ce81cc4056c32055d8-20171226132800.jpeg",
        image_urls: %w[https://cdn-gallery.skima.jp/gallery/017/284/17284/d1905510dbb435ce81cc4056c32055d8-20171226132800.jpeg],
        media_files: [{ file_size: 327_685 }],
        page_url: nil,
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A gallery sample image" do
      strategy_should_work(
        "https://cdn-gallery.skima.jp/gallery/017/284/17284/detail-e2ff46808671c188aba936b55038db1b-20171226132800.jpeg",
        image_urls: %w[https://cdn-gallery.skima.jp/gallery/017/284/17284/detail-e2ff46808671c188aba936b55038db1b-20171226132800.jpeg],
        media_files: [{ file_size: 158_901 }],
        page_url: nil,
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A commission sample image" do
      strategy_should_work(
        "https://cdn-common.skima.jp/item/472/833/1472833/showcase-9006bf8a7e0026066bfba843d2e12364-20240403213428.jpeg",
        image_urls: %w[https://cdn-common.skima.jp/item/472/833/1472833/9006bf8a7e0026066bfba843d2e12364-20240403213428.jpeg],
        media_files: [{ file_size: 185_307 }],
        page_url: nil,
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "An adoptable sample image" do
      strategy_should_work(
        "https://cdn-common.skima.jp/dlsample/254/683/2254683/thumbnail-46e31a21c3cb1df7fb698d7ac5b02131-20240509045904.jpeg",
        image_urls: %w[https://cdn-common.skima.jp/dlsample/254/683/2254683/46e31a21c3cb1df7fb698d7ac5b02131-20240509045904.png],
        media_files: [{ file_size: 3_401_225 }],
        page_url: nil,
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deleted adoptable post" do
      strategy_should_work(
        "https://skima.jp/dl/detail?id=260834",
        image_urls: [],
        page_url: "https://skima.jp/dl/detail?id=260834",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deleted post on the international site" do
      strategy_should_work(
        "https://wskima.com/items/256160",
        image_urls: [],
        page_url: "https://commission.skima.jp/pre-made-illustration/detail/256160",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A nonexistent gallery post" do
      strategy_should_work(
        "https://skima.jp/gallery?id=999999999",
        image_urls: [],
        page_url: "https://skima.jp/gallery?id=999999999",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "An adoptable sample image with a referer" do
      strategy_should_work(
        "https://cdn-common.skima.jp/dlsample/545/136/3545136/thumbnail-9a0488f67b42f25160ab5d40f837dfcb-20261113223754.jpeg",
        referer: "https://skima.jp/dl/detail?id=400576",
        image_urls: %w[https://cdn-common.skima.jp/dlsample/545/136/3545136/9a0488f67b42f25160ab5d40f837dfcb-20261113223754.png],
        media_files: [{ file_size: 2_738_323 }],
        page_url: "https://skima.jp/dl/detail?id=400576",
        profile_url: "https://skima.jp/profile?id=343119",
        profile_urls: %w[https://skima.jp/profile?id=343119],
        display_name: "108",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "【表情6種＋仕草4種】くたびれたコートの男性【タバコ】",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          閲覧いただきありがとうございます。

          スーツにコートのくたびれた雰囲気の男性です。
          くたびれて不健康そうなおじさんって最高ですよね！！！！！！！！！！！！！！！！！！！！
          仕草差分として煙草(＋缶コーヒー)を持った演技仕草が４種ついております。
          主にTRPGやゲーム、動画にてご利用いただけます。

          【納品内容】
          ・全身差分 6種
          →標準、げんなり、葛藤、閉じ目、目そらし、冷や汗
          ・仕草差分 4種※全身差分の上に重ねてご使用ください。
          (名前の頭に〇がついています)
          →手下ろし、煙草、首、缶コーヒー

          【形式等】
          ・透過PNG
          ・350dpi
          ・縦3000×横1200px

          【諸注意】
          ●ご利用OK
          ・TRPG、ゲーム、動画等にてご利用いただけます。（商用含）
          →例：SNS等でのTRPGへの利用報告（スクリーンショットの掲載等）
          ・購入者様及び購入者様の周辺でのキャラクターを利用した二次創作もお気兼ねなくどうぞ。
          ・軽度の加工
          →原型を損ねない範囲での色変更、加筆、他素材との併用、トリミング

          ●ご利用NG
          ・自作発言、二次配布、転売等の第三者への受渡行為は禁止させていただきます。
          ・政治・宗教・反社会的活動及びあらゆるヘイト行為利用のためのご購入はおやめください。
          ・著作人格権の侵害にあたる行為はおやめください。
          ・購入したキャラクターをAI学習等に利用するのはご遠慮ください。

          ※このイラストを利用したことによるトラブルについて、当方は一切責任を負いません。
          ※制作例としてイラストをSNS・ポートフォリオ等で公開する場合があります。
          ※クレジット表記は任意ですが、もししていただけるとありがたいです。

          ご不明点等ございましたら、ご連絡のほどよろしくお願いいたします。
        EOS
      )
    end

    context "A gallery sample image with a referer" do
      strategy_should_work(
        "https://cdn-gallery.skima.jp/gallery/055/208/55208/tip-f0081762dcb72ab22241526cbc00c814-20190215093719.jpeg",
        referer: "https://skima.jp/gallery?id=6428",
        image_urls: %w[https://cdn-gallery.skima.jp/gallery/055/208/55208/7b086a7cdfaa95d1e38e183344a1d829-20190215093718.jpeg],
        media_files: [{ file_size: 288_903 }],
        page_url: "https://skima.jp/gallery?id=6428",
        profile_url: "https://skima.jp/profile?id=1927",
        profile_urls: %w[https://skima.jp/profile?id=1927],
        display_name: "猫箸",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [
          ["キャラクター", "https://skima.jp/gallery/search?tag=キャラクター"],
          ["女の子", "https://skima.jp/gallery/search?tag=女の子"],
          ["イラスト", "https://skima.jp/gallery/search?tag=イラスト"],
          ["東方", "https://skima.jp/gallery/search?tag=東方"],
          ["可愛い", "https://skima.jp/gallery/search?tag=可愛い"],
          ["FGO", "https://skima.jp/gallery/search?tag=FGO"],
        ],
        dtext_artist_commentary_title: "一枚絵イラストまとめ",
        dtext_artist_commentary_desc: "CDジャケットやTCGイラスト、表紙等今まで描かせて頂いたものを掲載しています",
      )
    end

    context "A commission sample image with an international referer" do
      strategy_should_work(
        "https://cdn-common.skima.jp/item/604/124/1604124/showcase-87cd1b8194dda1fc49c1b0fec2f6e2a9-20241227014630.jpeg",
        referer: "https://commission.skima.jp/en/commission/detail/307121",
        image_urls: %w[https://cdn-common.skima.jp/item/604/124/1604124/87cd1b8194dda1fc49c1b0fec2f6e2a9-20241227014630.jpeg],
        media_files: [{ file_size: 263_058 }],
        page_url: "https://commission.skima.jp/commission/detail/307121",
        profile_url: "https://skima.jp/profile?id=32030",
        profile_urls: %w[https://skima.jp/profile?id=32030],
        display_name: "Yum",
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "世界観のあるイラスト全般オーダー♡最短即日納品",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          元作品やテーマの"世界観"を大切にした、まるであなたのキャラクターがその世界に初めからいるような一枚絵をお描きします^^*
          二人の日常を切り取って欲しい、特別な瞬間を素敵な演出で、一見夢絵に見えないかっこいいイラストが欲しい、どんなご希望も叶えてみせます*°
          一行ポエム、お題、セリフ、曲などからでもイラスト化できます。

          女夢主、男夢主、3L可能です！
          夢絵以外にも様々な用途、媒体、目的に対応しております。

          ◆基本◆
          構図…キャラ一人、バストアップ
          背景…白or単色or簡単なデザイン背景
          サイズ解像度…1000×1000、解像度72dpi、png
          塗り…指定がない場合ブラシ塗り

          【お取引の流れ】

          お問い合わせ＋ご相談
          ↓
          専用出品
          ↓
          ご購入＆ヒアリング
          ↓
          ラフ提出(訂正)
          ↓
          完成品提出(訂正)
          ↓
          納品
          ↓
          相互評価

          オプションにない媒体の注文にも対応していますので、まずはお気軽にご相談を^^*

          個人鑑賞用はもちろん、ペアアイコン、PCやスマホの壁紙、本の表紙や挿絵、TRPG、立ち絵、コンセプトアート、デザイン、グッズなど何でもお任せ下さい！
          存じ上げないジャンルやキャラであっても、丁寧にヒアリングし対応します。

          納期調整＋双方のトラブル回避のために、ご依頼前のお見積もり相談必須です。
          お手数をお掛けしますが、よろしくお願い致します。
        EOS
      )
    end
  end
end
