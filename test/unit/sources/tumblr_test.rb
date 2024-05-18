require "test_helper"

module Sources
  class TumblrTest < ActiveSupport::TestCase
    def setup
      skip "Tumblr key is not configured" unless Source::Extractor::Tumblr.enabled?
    end

    context "The source for a 'http://*.tumblr.com/post/*' photo post with a single image" do
      strategy_should_work(
        "https://noizave.tumblr.com/post/162206271767",
        image_urls: ["https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png"],
        media_files: [{ file_size: 3655 }],
        page_url: "https://noizave.tumblr.com/post/162206271767",
        username: "noizave",
        profile_url: "https://noizave.tumblr.com",
        tags: ["tag", "red hair", "red-hair", "red_hair"],
        normalized_tags: ["red_hair", "tag"],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          h2. header

          [hr]

          plain [b]bold[/b] [i]italics[/i] [s]strike[/s]

          * one
          * two

          * one

          ** two

          [quote]
          quote
          [/quote]

          "link":[http://www.google.com]
        EOS
      )
    end

    context "The source for a 'http://*.tumblr.com/image/*' image page" do
      strategy_should_work(
        "https://noizave.tumblr.com/image/162206271767",
        image_urls: ["https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png"],
        page_url: "https://noizave.tumblr.com/post/162206271767",
        tags: ["tag", "red hair", "red-hair", "red_hair"],
        normalized_tags: ["red_hair", "tag"]
      )
    end

    context "The source for a 'http://*.media.tumblr.com/$hash/tumblr_$id_540.jpg' image" do
      strategy_should_work(
        "https://78.media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_540.jpg",
        image_urls: ["https://media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_orwwptNBCE1wsfqepo2_1280.jpg"],
        page_url: "https://noizave.tumblr.com/post/162094447052",
        username: "noizave",
        profile_url: "https://noizave.tumblr.com",
        tags: ["tag1", "tag2"]
      )
    end

    context "The source for a 'http://*.tumblr.com/post/*' text post with inline images" do
      strategy_should_work(
        "https://noizave.tumblr.com/post/162221502947",
        image_urls: %w[
          https://media.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os2zhkfhY01v11u29_1280.png
          https://media.tumblr.com/7c4d2c6843466f92c3dd0516e749ec35/tumblr_inline_os2zkg02xH1v11u29_1280.jpg
        ],
        dtext_artist_commentary_title: "test post",
        dtext_artist_commentary_desc: "description"
      )
    end

    context "A video post with inline images" do
      strategy_should_work(
        "https://noizave.tumblr.com/post/162222617101",
        image_urls: %w[
          https://va.media.tumblr.com/tumblr_os31dkexhK1wsfqep.mp4
          https://media.tumblr.com/afed9f5b3c33c39dc8c967e262955de2/tumblr_inline_os31dclyCR1v11u29_1280.png
        ]
      )
    end

    context "A video post with a https://va.media.tumblr.com/tumblr_*_720.mp4 URL" do
      strategy_should_work(
        "https://cloudstation.tumblr.com/post/697975577362251776/direct-quote-from-kaiba-post-battle-city",
        image_urls: ["https://va.media.tumblr.com/tumblr_rjoh0hR8Xe1teimlz_720.mp4"],
        media_files: [{ file_size: 1_073_148 }],
      )
    end

    context "A video post with an embedded Youtube video" do
      strategy_should_work(
        "https://ebith1969.tumblr.com/post/48214164804",
        image_urls: [],
        page_url: "https://ebith1969.tumblr.com/post/48214164804",
        profile_url: "https://ebith1969.tumblr.com",
        username: "ebith1969",
        tags: [],
        artist_commentary_title: nil,
        dtext_artist_commentary_desc: "2009.03.05"
      )
    end

    context "A text post with an inline video" do
      strategy_should_work(
        "https://www.tumblr.com/yraa/736364675654123520/the-divorce-is-going-well-original",
        image_urls: ["https://va.media.tumblr.com/tumblr_s5g5gyT1oY1rnax4f_720.mp4"],
        page_url: "https://yraa.tumblr.com/post/736364675654123520",
        profile_url: "https://yraa.tumblr.com",
        username: "yraa",
        tags: [
          "or maybe it is just... going",
          "genshin impact",
          "haikaveh",
          "bad animatic",
          "i'm sorry",
          "was imagining this for a while and then procreate released their animation app and i had to",
          "today yra desperately tries to figure out procreate dreams. tomorrow?? who knows",
          "crawls back into cave",
        ],
        artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          the divorce is going well

          (edit: added subs) ("original":[https://youtu.be/6youGMi8m-Y?si=XX6Z-KNPOS6BIdr3])
        EOS
      )
    end

    context "The source for a 'http://*.tumblr.com/post/*' answer post with inline images" do
      strategy_should_work(
        "https://noizave.tumblr.com/post/171237880542/test-ask",
        image_urls: ["https://media.tumblr.com/cb481f031010e8ddad564b2150149c9a/tumblr_inline_p4nxoyLrSh1v11u29_1280.png"],
        page_url: "https://noizave.tumblr.com/post/171237880542",
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          [quote]
          Anonymous asked:

          test ask
          [/quote]

          test answer
        EOS
      )
    end

    context "A Tumblr post with new image URLs" do
      strategy_should_work(
        "https://64.media.tumblr.com/3dfdab77d913ad1ea59f22407d6ac6f3/b1764aa0f9c378d0-23/s1280x1920/46f4af7ec94456f8fef380ee6311eb81178ce7e9.jpg",
        referer: "https://make-do5.tumblr.com/post/619663949657423872",
        page_url: "https://make-do5.tumblr.com/post/619663949657423872",
        image_urls: [%r{/3dfdab77d913ad1ea59f22407d6ac6f3/b1764aa0f9c378d0-23/s\d+x\d+/}i],
        media_files: [{ file_size: 7_428_704 }]
      )
    end

    context "A deleted tumblr post" do
      strategy_should_work(
        "http://shimetsukage.tumblr.com/post/176805588268/20180809-ssb-coolboy",
        deleted: true,
        username: "shimetsukage",
        profile_url: "https://shimetsukage.tumblr.com",
        page_url: "https://shimetsukage.tumblr.com/post/176805588268",
        image_urls: [],
        tags: []
      )
    end

    %w[100 250 400 500 500h 540 640 1280].each do |size|
      context "A download for a 'http://*.media.tumblr.com/$hash/tumblr_$id_#{size}.png' image" do
        strategy_should_work(
          "https://66.media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_#{size}.png",
          referer: "https://natsuki-teru.tumblr.com/post/178728919271",
          image_urls: ["https://media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_1280.png"]
        )
      end
    end

    context "A *.media.tumblr.com/$hash/tumblr_$id_$size.png URL with a referer" do
      strategy_should_work(
        "https://64.media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_400.png",
        referer: "https://noizave.tumblr.com/post/162206271767",
        image_urls: ["https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png"],
        media_files: [{ file_size: 3655 }]
      )
    end

    context "A *.media.tumblr.com/tumblr_$id_$size.jpg URL with a referer" do
      strategy_should_work(
        "http://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_250.jpg",
        referer: "https://noizave.tumblr.com/post/162206271767",
        image_urls: ["https://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg"],
        media_files: [{ file_size: 105_963 }]
      )
    end

    context "A *.media.tumblr.com/tumblr_$id_$size.pnj URL" do
      strategy_should_work(
        "https://media.tumblr.com/701a535af224f89684d2cfcc097575ef/tumblr_pjsx70RakC1y0gqjko1_1280.pnj",
        image_urls: ["https://media.tumblr.com/701a535af224f89684d2cfcc097575ef/tumblr_pjsx70RakC1y0gqjko1_1280.png"],
        page_url: nil,
        username: nil,
        media_files: [{ file_size: 296_595, file_ext: :jpg }]
      )
    end

    context "A *.media.tumblr.com/.../$size/$hash.pnj URL" do
      strategy_should_work(
        "https://64.media.tumblr.com/3da3970775ba820dbc80ef3c5dae479e/dcc12b025632aa86-5f/s540x810/6433414944c280dfd6e8bb482e1d9f6466433901.pnj",
        image_urls: ["https://64.media.tumblr.com/3da3970775ba820dbc80ef3c5dae479e/dcc12b025632aa86-5f/s21000x21000/05f92acb893af4b0f738f1518b49d624038c9c5e.png"],
        page_url: "https://esper-eclipse.tumblr.com/post/686575447718395904",
        media_files: [{ file_size: 340_827, file_ext: :png }]
      )
    end

    context "A va.media.tumblr.com/tumblr_$id.mp4 URL" do
      strategy_should_work(
        "https://va.media.tumblr.com/tumblr_pgohk0TjhS1u7mrsl.mp4",
        image_urls: ["https://va.media.tumblr.com/tumblr_pgohk0TjhS1u7mrsl.mp4"],
        page_url: nil,
        username: nil,
        media_files: [{ file_size: 7_960_082 }]
      )
    end

    context "A tumblr.com/$blog_name/$work_id URL" do
      strategy_should_work(
        "https://tumblr.com/munespice/683613396085719040",
        image_urls: ["https://64.media.tumblr.com/fd6b4692f6e902af861fbc242736ae61/010fd31ffbc70e84-a8/s21000x21000/e0587516e05bae4cec244921f220b45bed08335c.jpg"],
        username: "munespice",
        page_url: "https://munespice.tumblr.com/post/683613396085719040",
        profile_url: "https://munespice.tumblr.com"
      )
    end

    context "A www.tumblr.com/$blog_name/$work_id/$slug URL" do
      strategy_should_work(
        "https://www.tumblr.com/munespice/683613396085719040/saur-family",
        image_urls: ["https://64.media.tumblr.com/fd6b4692f6e902af861fbc242736ae61/010fd31ffbc70e84-a8/s21000x21000/e0587516e05bae4cec244921f220b45bed08335c.jpg"],
        username: "munespice",
        page_url: "https://munespice.tumblr.com/post/683613396085719040",
        profile_url: "https://munespice.tumblr.com"
      )
    end

    context "A at.tumblr.com/$blog_name/$work_id/$tracker_id URL" do
      strategy_should_work(
        "https://at.tumblr.com/munespice/683613396085719040/vzs8ma5elvnc",
        image_urls: ["https://64.media.tumblr.com/fd6b4692f6e902af861fbc242736ae61/010fd31ffbc70e84-a8/s21000x21000/e0587516e05bae4cec244921f220b45bed08335c.jpg"],
        username: "munespice",
        page_url: "https://munespice.tumblr.com/post/683613396085719040",
        profile_url: "https://munespice.tumblr.com"
      )
    end

    context "A tumblr image url from a regular tumblr post" do
      strategy_should_work(
        "https://64.media.tumblr.com/591b370b9deb7c6ef33d8c18dc2c8db5/tumblr_ph5huubDdz1w0f6yio1_1280.jpg",
        image_urls: ["https://media.tumblr.com/591b370b9deb7c6ef33d8c18dc2c8db5/tumblr_ph5huubDdz1w0f6yio1_1280.jpg"],
        page_url: "https://compllege.tumblr.com/post/179415753146",
        profile_url: "https://compllege.tumblr.com",
        dtext_artist_commentary_desc: <<~EOS.chomp
          CODL-0001 “C-Experiment”

          2018年10月28日 M3
          第一展示場 I-05ab “compllege” & “wavforme” にて
          ダウンロードカードを頒布予定
          後日DL版も販売予定
          ￥500

          ※wavformeと合同会計です。

          Track List

          01. Opening

          02. Encounter (feat. Nhato)

          03. Human relations (feat. MK)

          04. The Angels

          05. A Moment of Silence (feat. Tomohiko Togashi)

          KORG Gadget for Nintendo Switchを使用し、楽曲を制作しました。

          今回はゲストにNhato氏、MK氏、Tomohiko Togashi氏を招いて共作しております。

          今回はCDではなく、ダウンロードカードの頒布となります。

          デザインは"LiGHTEN":[https://twitter.com/LiGHTEN]、ジャケットイラストは"東山エイト":[http://08b.tokyo/]が担当しています。

          今回は折角なので、制作している風景を撮影し、動画をYoutubeにアップロードいたしました。  第1段はNhato氏との共作です。是非ご覧ください。
        EOS
      )
    end

    context "A tumblr image url from a custom blog domain" do
      strategy_should_work(
        "https://64.media.tumblr.com/68e6c4db6bac37cf9d6a166c133cf758/b81004325e350a36-c3/s1280x1920/a23c96c128b296219ff41a0178fe3e53f05e6680.png",
        image_urls: ["https://64.media.tumblr.com/68e6c4db6bac37cf9d6a166c133cf758/b81004325e350a36-c3/s21000x21000/4d7ef161fe11d1395fd86890a3680b6313352d63.png"],
        page_url: "https://yraa.tumblr.com/post/188271069189",
        profile_url: "https://yraa.tumblr.com",
        username: "yraa",
        tags: ["ffxiv", "draw", "i'm a cat i'm a kitty cat and i dance dance dance", "is anyone still even here", "crawls back into damp cave"],
        dtext_artist_commentary_desc: <<~EOS.chomp
          "@phantom-miria":[https://www.tumblr.com/phantom-miria]
        EOS
      )
    end

    context "A tumblr post url from a custom blog domain (1)" do
      strategy_should_work(
        "https://yra.sixc.me/post/188271069189",
        image_urls: ["https://64.media.tumblr.com/68e6c4db6bac37cf9d6a166c133cf758/b81004325e350a36-c3/s21000x21000/4d7ef161fe11d1395fd86890a3680b6313352d63.png"],
        page_url: "https://yraa.tumblr.com/post/188271069189",
        profile_url: "https://yraa.tumblr.com",
        username: "yraa",
        tags: ["ffxiv", "draw", "i'm a cat i'm a kitty cat and i dance dance dance", "is anyone still even here", "crawls back into damp cave"],
        dtext_artist_commentary_desc: <<~EOS.chomp
          "@phantom-miria":[https://www.tumblr.com/phantom-miria]
        EOS
      )
    end

    context "A tumblr post url from a custom blog domain (2)" do
      strategy_should_work(
        "https://d-floe.art/post/190738927749/commission-of-kat-from-gravity-rush",
        image_urls: ["https://64.media.tumblr.com/faab3d1d9537b9e4e3fe8f04487a1210/42ecfb675692be33-70/s21000x21000/16b1914c6c4834363f30782eebbe045a3721de3b.png"],
        page_url: "https://d-floe.tumblr.com/post/190738927749",
        profile_url: "https://d-floe.tumblr.com",
        username: "d-floe",
        tags: ["2x2F3", "d-floe", "Illustration", "gravity rush", "kat"],
        dtext_artist_commentary_desc: <<~EOS.chomp
          Commission of Kat from Gravity Rush
        EOS
      )
    end

    context "A *.media.tumblr.com/*/*_500.jpg sample image URL" do
      strategy_should_work(
        "https://24.media.tumblr.com/fc328250915434e66e8e6a92773f79d0/tumblr_mf4nshfibc1s0oswoo1_500.jpg",
        image_urls: ["https://media.tumblr.com/fc328250915434e66e8e6a92773f79d0/tumblr_mf4nshfibc1s0oswoo1_1280.jpg"],
        media_files: [{ file_size: 118_315 }],
        page_url: "https://nagian.tumblr.com/post/38061868112",
        profile_url: "https://nagian.tumblr.com",
        username: "nagian",
        tags: [],
        dtext_artist_commentary_desc: "ゆいあず",
      )
    end

    context "A *.media.tumblr.com/tumblr_$id_$size image URL without a larger size" do
      strategy_should_work(
        "https://25.media.tumblr.com/tumblr_lxbzel2H5y1r9yjhso1_500.jpg",
        image_urls: ["https://media.tumblr.com/tumblr_lxbzel2H5y1r9yjhso1_1280.jpg"],
        media_files: [{ file_size: 42_997 }],
        page_url: nil,
        profile_url: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_desc: "",
      )
    end

    context "A *.media.tumblr.com/tumblr_$id_$size image URL with a larger size" do
      strategy_should_work(
        "https://25.media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png",
        image_urls: ["https://media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_1280.png"],
        media_files: [{ file_size: 62_658 }],
        page_url: nil,
        profile_url: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_desc: "",
      )
    end

    context "A *.media.tumblr.com/$hash/tumblr_$id_rN_$size image URL" do
      strategy_should_work(
        "https://33.media.tumblr.com/4b7fecf9a5a8284fbaefb051a2369b55/tumblr_npozqfwc9h1rt6u7do1_r1_500.gif",
        image_urls: ["https://media.tumblr.com/4b7fecf9a5a8284fbaefb051a2369b55/tumblr_npozqfwc9h1rt6u7do1_r1_1280.gif"],
        media_files: [{ file_size: 1_234_017 }],
        page_url: "https://jonroru.tumblr.com/post/121126557895",
        profile_url: "https://jonroru.tumblr.com",
        username: "jonroru",
        tags: ["splatoon", "pixel art", "inkling", "super nes", "animation", "nintendo", "wiiu", "gaming", "gif", "animated gif", "saltspray rig", "ink", "i'm a kid now", "i'm a squid now", "squid"],
        dtext_artist_commentary_desc: "[b]“SPLATOON SUPER NES VERSION (or more like GBA according to some XD)”[/b]",
      )
    end

    context "A *.media.tumblr.com/$hash/tumblr_inline_$id_$size image URL" do
      strategy_should_work(
        "https://68.media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_250.gif",
        image_urls: ["https://media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_1280.gif"],
        media_files: [{ file_size: 110_348 }],
        page_url: nil,
        profile_url: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_desc: "",
      )
    end

    context "A tmblr.co post URL" do
      strategy_should_work(
        "https://tmblr.co/ZdPV4t2OHwdv5",
        image_urls: ["https://media.tumblr.com/605632aa2d218410edaa2f9e2f3a1646/tumblr_ots53vjhn61s5nooco1_1280.png"],
        media_files: [{ file_size: 462_572 }],
        page_url: "https://techsupportdog.tumblr.com/post/163509337669",
        profile_url: "https://techsupportdog.tumblr.com",
        username: "techsupportdog",
        tags: ["anime art", "anime girl", "binkan", "shimoneta", "spiderman", "superior spider-man"],
        dtext_artist_commentary_desc: "",
      )
    end

    context "A reblogged post" do
      strategy_should_work(
        "https://www.tumblr.com/lizalfosrise/731136514455666688/can-you-draw-shiki-from-senran-kagura",
        image_urls: [],
        profile_url: "https://lizalfosrise.tumblr.com",
        tags: ["adorable"],
        dtext_artist_commentary_desc: <<~EOS.chomp
          [quote]
          Anonymous asked:

          Can you draw Shiki from Senran Kagura?
          [/quote]

          [quote]
          "pencilanon":[https://pencilanon.tumblr.com/post/172837943488] answered:

          "[image]":[https://64.media.tumblr.com/a4269a8e3442a025223561525fac778e/tumblr_inline_p71hzjtrPh1u6mv10_540.png]

          Sure

          *EDIT full version [b]"here":[https://files.catbox.moe/fxhzs4.png][/b]
          [/quote]
        EOS
      )
    end

    context "A commentary with alt text containing multiple paragraphs" do
      strategy_should_work(
        "https://dee-toraburu.tumblr.com/post/697041312401309696/fanart-of-alphonse-made-for-the-ee-anthology",
        image_urls: %w[
          https://64.media.tumblr.com/29f28e784f0c37b28546dddfab759b66/683448bbce5cf754-41/s21000x21000/febb7581082b418f8ced5fa5f3d65eb7d1773680.jpg
        ],
        dtext_artist_commentary_desc: <<~EOS.chomp
          [quote]
          h6. Image description

          A digital illustration of a bust of Al in his human body. The highly symbolic illustration style is reminiscent of Art Nouveau from the Belle Epoque. It uses flat colors and bold, round lines.

          In the center of the image, Al is shown in profile, completely facing the left side of the image. The bust cuts off at Al’s neck. Al’s long hair, in various shades of gold, falls in front of his face on the side not facing the viewer and falls in whirling curls down towards the bottom left corner of the image. On the visible side of Al’s face, his hair is tucked behind his left ear, extending in a swoop behind him and out of the frame of the image. Two strands fall loosely over his left cheek. Looking vaguely melancholic and pensive, Al’s visible golden eye is wide open, with stylistically thick eyelashes. His mouth is slightly parted and his eyebrows barely raised.

          Behind Al’s neck, a deep red arc highlights the edge of his bust, reminiscent of blood. Its bottom edge is broken up, like it is fraying or dripping. Delicate wrought iron fences run across the middle of the illustration behind Al, starting at neck level on the left and stepping up to eye level on the right. On the left, there are purple flowers and bright green leaves behind the fence, but on the right, the same flowers in a paler purple reach through the fence to curl around the back of Al’s head.

          Slightly above Al on the left border of the image is a stylized sun in dark gold. Text underneath it reads “Anima” - the Latin for ‘soul’ - in all caps. A matching moon is on the right, with text that reads “Spiritus” - Latin for ‘spirit’ - in all caps beneath it.

          Between them at the very top of the image, a combined sun and moon is drawn in dark gold and black. It is bordered by two curving black arms extending toward it from either side, like the arms that reach out from The Gate of Truth. Behind the arms and combined sun and moon, a horizontal rectangle of orange sunset, surrounded by a gold border.

          The bottom of the combined sun and moon is dark with blood, blood dripping off of its rays. Between the bottom of the sun-moon symbol and the top of Al’s head sits a small philosopher’s stone. The top of Al’s head is cast in a reddish light, either from the sunset or the stone.

          Small shards of philosopher’s stone are strewn across the top half of the image. The sun and moon combination has dripped blood across flowers behind the fence near Al and the flowers around his head.

          At the very bottom of the image on the right, there is text that reads “Fullmetal Alchemist” in a curvy Art Nouveau font. The “T” in Fullmetal is replaced by a Flamel symbol, like Ed wears on the back of his red coat. The text is underlined with a thick, curving black border, a dark green vine, and an array of golden gears in the right hand corner.
          [/quote]

          [b]B[/b][b]o[/b][b]d[/b][b]y[/b][b],[/b][b]M[/b][b]i[/b][b]n[/b][b]d[/b][b]&[/b][b]S[/b][b]o[/b][b]u[/b][b]l[/b]

          [tn]Fanart of Alphonse, made for the E.E. Anthology – [/tn]"[tn]@equivalentexchangeanthology[/tn]":[https://www.tumblr.com/equivalentexchangeanthology][tn] ⚕️[/tn]
          [tn]▪︎ [/tn]"[tn]Image description (audio available)[/tn]":[https://href.li/?https://ee-anthology.dreamwidth.org/tag/artist:+dee+trowble]
        EOS
      )
    end

    context "A commentary with mulitple images with alt text" do
      strategy_should_work(
        "https://timestables.tumblr.com/post/672495082090430464",
        image_urls: %w[
          https://64.media.tumblr.com/05c6636c72a93a59f3e480e4c8fb0933/862b6ac896d7b4d7-10/s21000x21000/5e35c58a2f70c34eefefaadb7f7f5265e90dfc4f.png
          https://64.media.tumblr.com/99cc150f9604305c040b3c2729b2aabf/862b6ac896d7b4d7-a0/s21000x21000/be90b779ece79d49d5c1360bafa51c104e3439f0.png
          https://64.media.tumblr.com/828e84cc37a0f3ec64190ca6d1bd9e57/862b6ac896d7b4d7-77/s21000x21000/e579296c67dcf4bc718c274a9c634de208a65167.png
          https://64.media.tumblr.com/eb8a0a4150334a3df969bab389b7ba64/862b6ac896d7b4d7-1d/s21000x21000/a82cdcd150ded8b37f4b013eac91004d617f66a9.png
        ],
        dtext_artist_commentary_desc: <<~EOS.chomp
          [quote]
          h6. Image description

          page of Kim Dokja drawings from omniscient readers viewpoint. One of him looking at the ground like an investigator, one as demon king of salvation looking gentle with biyoo. and one of him with a very smug expression as he is held by the scruff by (implied) yoo joonghyuk
          [/quote]

          [quote]
          h6. Image description

          drawing of kdj and yjh. They are sitting next to eachother facing away. yjh is calm with his eyes closed, a thought bubble is shown above his head showing a crude drawing of him murdering kdj. kdj is looking up at the thought bubble with a nervous discomfort.
          [/quote]

          [quote]
          h6. Image description

          small comic of han sooyoung wearing a white jacket, a text bubble reads "Kim Dokja read my mind right now". she then looks up with confrontational expression. the text bubble reads in large letters "[Bitch]"
          [/quote]

          [quote]
          h6. Image description

          drawings of Kim Dokja from omniscient readers viewpoint. He is smiling and the text reads "heres where i would brag about my cool best friend yoo joonghyuk to the three ways to survive a ruined world fanbase". Below he is drawn with an angry and frustrated expression, the text reads "... IF there were any other readers." Below that is another small drawing of kdj leaning against the wall looking defeated.
          [/quote]

          hmm
        EOS
      )
    end

    context "A commentary with alt text containing quote marks" do
      strategy_should_work(
        "https://dumpsterf11re.tumblr.com/post/745620363722047488",
        image_urls: %w[https://64.media.tumblr.com/b823b6e057a6cca109a0b081d541b1e2/e6da9f752eeebab0-96/s21000x21000/64688ba897ef51f3928c4e24ac4901531c6f5144.png],
        media_files: [{ file_size: 541_679 }],
        page_url: "https://dumpsterf11re.tumblr.com/post/745620363722047488",
        profile_url: "https://dumpsterf11re.tumblr.com",
        profile_urls: %w[https://dumpsterf11re.tumblr.com],
        username: "dumpsterf11re",
        other_names: ["dumpsterf11re"],
        tags: [
          ["dungeon meshi", "https://tumblr.com/tagged/dungeon meshi"],
          ["tw blood", "https://tumblr.com/tagged/tw blood"],
          ["july says things", "https://tumblr.com/tagged/july says things"],
          ["july draws things", "https://tumblr.com/tagged/july draws things"],
          ["my art", "https://tumblr.com/tagged/my art"],
          ["marcille", "https://tumblr.com/tagged/marcille"],
          ["chilchuck", "https://tumblr.com/tagged/chilchuck"],
          ["fanart", "https://tumblr.com/tagged/fanart"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          [quote]
          h6. Image description

          Chilchuck from Dungeon Meshi yells at Marcille, and in his speech bubble is a screenshot of a Tumblr post saying "bro stop chanting in dead languages you're scaring the hoes", and a blood-stained Marcille standing over a dark magic circle replies with another screenshot saying "im summoning the hoes fool"
          [/quote]
        EOS
      )
    end

    context "A commentary with nested reblogs" do
      strategy_should_work(
        "https://www.tumblr.com/shortgremlinman/707877745599905792/get-asked-idiot",
        image_urls: %w[
          https://64.media.tumblr.com/a2d9051a56877325cc97dd1d4a44b335/29c31c5d4773345f-37/s21000x21000/e01081a0c6cf5a6f4bd78862130e1b7cef0d861d.jpg
        ],
        dtext_artist_commentary_desc: <<~EOS.chomp
          [quote]
          Anonymous asked:

          Get asked. Idiot
          [/quote]

          [quote]
          "mlarayoukai":[https://mlarayoukai.tumblr.com/post/705514137627852800] answered:

          Get answered. Idiot
          [/quote]

          [quote]
          "mlarayoukai":[https://mlarayoukai.tumblr.com/post/705515061923479553]:

          "[image]":[https://64.media.tumblr.com/7f86ced76c3bdb3d1f7e37b94300a0f8/8a2f1b95cb77a442-0c/s640x960/b61020fc02ca7d336ef607d9e92b9640664bcf75.jpg]

          Get screenshotted. Idiot
          [/quote]

          [quote]
          "leafgreen6":[https://leafgreen6.tumblr.com/post/705541898577821696]:

          Get reblogged. Idiot
          [/quote]

          [quote]
          "secondimpact":[https://secondimpact.tumblr.com/post/707478301796614144]:

          [quote]
          h6. Image description

          Text ID: #Get tagged #Idiot
          [/quote]

          Get peer reviewed. Idiot.
          [/quote]

          [quote]
          "leonardburton":[https://leonardburton.tumblr.com/post/707502587639939072]:

          [image description:

          1. a screenshot of a reply that reads “Get replied. Idiot”

          2. a screenshot of tumblr tags reading “#get tagged #idiot”/ end ID]

          get image described. idiot
          [/quote]

          [quote]
          "professionalchaoticdumbass":[https://professionalchaoticdumbass.tumblr.com/post/707743740292382721]:

          get polled.

          * idiot.
          * idiot.
          [/quote]

          [quote]
          "chongoblog":[https://chongoblog.tumblr.com/post/707833854516396032]:

          "[image]":[https://64.media.tumblr.com/f6a26f624875be4f1d367abfef0e37b1/f75fe728063ddfea-79/s640x960/3f62c9e9166ccf7df919a563c1bb7902673cb3a0.png]
          [/quote]

          [quote]
          "spinji":[https://spinji.tumblr.com/post/707835443054592000]:

          "[image]":[https://64.media.tumblr.com/e4a1800a1be40f81acf00eebe43107b9/81439051814a73c3-7c/s640x960/7b483b9d0b74c63910d5de276e53e0fba3231b2a.jpg]
          [/quote]

          [quote]
          "totallyjazzed":[https://totallyjazzed.tumblr.com/post/707835856285843456]:

          "[image]":[https://64.media.tumblr.com/f27e13b72ea6b435e96ca087bc8efa7e/adadfdda93422e04-54/s640x960/96e6f10ba5d86ced934f4bea52bb8e53b2466bad.png]
          [/quote]

          Get photographed. Idiot
        EOS
      )
    end

    context "generating page urls" do
      should "work" do
        source1 = "https://octrain1020.tumblr.com/post/190713122589"
        source2 = "https://octrain1020.tumblr.com/image/190713122589"
        source3 = "https://octrain1020.tumblr.com/image/190713122589#asd"
        source4 = "https://superboin.tumblr.com/post/141169066579/photoset_iframe/superboin/tumblr_o45miiAOts1u6rxu8/500/false"

        assert_equal(source1, Source::URL.page_url(source1))
        assert_equal(source1, Source::URL.page_url(source2))
        assert_equal(source1, Source::URL.page_url(source3))
        assert_equal("https://superboin.tumblr.com/post/141169066579", Source::URL.page_url(source4))
        assert_nil(Source::URL.page_url("https://octrain1020.tumblr.com/"))
      end
    end

    should "parse Tumblr URLs correctly" do
      assert_not(Source::URL.image_url?("https://tumblr.com"))
      assert_not(Source::URL.image_url?("https://www.tumblr.com"))
      assert_not(Source::URL.image_url?("https://yogurtmedia.tumblr.com/post/45732863347"))

      assert(Source::URL.image_url?("http://data.tumblr.com/07e7bba538046b2b586433976290ee1f/tumblr_o3gg44HcOg1r9pi29o1_raw.jpg"))
      assert(Source::URL.image_url?("https://40.media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_1280.jpg"))
      assert(Source::URL.image_url?("https://media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_raw.jpg"))
      assert(Source::URL.image_url?("https://66.media.tumblr.com/2c6f55531618b4335c67e29157f5c1fc/tumblr_pz4a44xdVj1ssucdno1_1280.png"))
      assert(Source::URL.image_url?("https://68.media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_250.gif"))
      assert(Source::URL.image_url?("https://media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_500.gif"))
      assert(Source::URL.image_url?("https://66.media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_500h.png"))
      assert(Source::URL.image_url?("https://media.tumblr.com/701a535af224f89684d2cfcc097575ef/tumblr_pjsx70RakC1y0gqjko1_1280.pnj"))

      assert(Source::URL.image_url?("https://25.media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png"))
      assert(Source::URL.image_url?("https://media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_1280.png"))
      assert(Source::URL.image_url?("https://media.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_500.jpg"))
      assert(Source::URL.image_url?("https://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg"))
      assert(Source::URL.image_url?("https://va.media.tumblr.com/tumblr_pgohk0TjhS1u7mrsl.mp4"))

      assert(Source::URL.image_url?("https://66.media.tumblr.com/168dabd09d5ad69eb5fedcf94c45c31a/3dbfaec9b9e0c2e3-72/s640x960/bf33a1324f3f36d2dc64f011bfeab4867da62bc8.png"))
      assert(Source::URL.image_url?("https://66.media.tumblr.com/5a2c3fe25c977e2281392752ab971c90/3dbfaec9b9e0c2e3-92/s500x750/4f92bbaaf95c0b4e7970e62b1d2e1415859dd659.png"))

      assert(Source::URL.image_url?("https://25.media.tumblr.com/91719d337b218681abc48cdc24e"))
      assert_not(Source::URL.page_url?("https://25.media.tumblr.com/91719d337b218681abc48cdc24e"))
      assert_not(Source::URL.profile_url?("https://25.media.tumblr.com/91719d337b218681abc48cdc24e"))

      assert(Source::URL.profile_url?("https://www.tumblr.com/tawni-tailwind"))
      assert(Source::URL.profile_url?("https://www.tumblr.com/dashboard/blog/dankwartart"))
      assert(Source::URL.profile_url?("https://www.tumblr.com/blog/artofelaineho"))
      assert(Source::URL.profile_url?("https://www.tumblr.com/blog/view/artofelaineho"))
      assert(Source::URL.profile_url?("https://tumblr.com/tawni-tailwind"))
      assert(Source::URL.profile_url?("https://tumblr.com/dashboard/blog/dankwartart"))
      assert(Source::URL.profile_url?("https://tumblr.com/blog/kervalchan"))
      assert(Source::URL.profile_url?("https://tumblr.com/blog/view/artofelaineho"))
      assert(Source::URL.profile_url?("https://rosarrie.tumblr.com/archive"))
      assert(Source::URL.profile_url?("https://solisnotte.tumblr.com/about"))
      assert(Source::URL.profile_url?("https://whereisnovember.tumblr.com/tagged/art"))

      assert_equal("https://pizza-and-ramen.tumblr.com/post/118684413624", Source::URL.page_url("https://at.tumblr.com/pizza-and-ramen/118684413624/uqndb20nkyob"))
      assert_equal("https://cyanideqpoison.tumblr.com", Source::URL.profile_url("https://at.tumblr.com/cyanideqpoison/u2czj612ttzq"))
    end
  end
end
