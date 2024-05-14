require 'test_helper'

module Sources
  class MisskeyTest < ActiveSupport::TestCase
    context "A https://misskey.io/notes/:note_id url" do
      strategy_should_work(
        "https://misskey.io/notes/9bxaf592x6",
        image_urls: %w[https://media.misskeyusercontent.jp/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png],
        media_files: [{ file_size: 197_151 }],
        page_url: "https://misskey.io/notes/9bxaf592x6",
        profile_url: "https://misskey.io/@ixy194",
        profile_urls: %w[https://misskey.io/@ixy194 https://misskey.io/users/9bpemdns40],
        artist_name: "Ｉｘｙ（いくしー）",
        tag_name: "ixy194",
        other_names: ["Ｉｘｙ（いくしー）", "ixy194"],
        tags: [
          ["村上さん", "https://misskey.io/tags/村上さん"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          村上さん "#村上さん":[https://misskey.io/tags/村上さん] 村上アート
        EOS
      )
    end

    context "A note with multiple files" do
      strategy_should_work(
        "https://misskey.io/notes/9e5pggsolw",
        image_urls: %w[
          https://media.misskeyusercontent.jp/misskey/c6909d66-9f53-4050-b46d-643d266995c7.jpg
          https://media.misskeyusercontent.jp/misskey/08e1b86c-0d5e-4391-9b02-125a5f7f4794.jpg
        ],
        media_files: [
          { file_size: 81_793 },
          { file_size: 80_996 },
        ],
        page_url: "https://misskey.io/notes/9e5pggsolw",
        profile_url: "https://misskey.io/@ixy194",
        profile_urls: %w[https://misskey.io/@ixy194 https://misskey.io/users/9bpemdns40],
        artist_name: "Ｉｘｙ（いくしー）",
        tag_name: "ixy194",
        other_names: ["Ｉｘｙ（いくしー）", "ixy194"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "おりきゃら"
      )
    end

    context "A note without any files" do
      strategy_should_work(
        "https://misskey.io/notes/9ef8xtot2m",
        image_urls: [],
        page_url: "https://misskey.io/notes/9ef8xtot2m",
        profile_url: "https://misskey.io/@ixy194",
        profile_urls: %w[https://misskey.io/@ixy194 https://misskey.io/users/9bpemdns40],
        artist_name: "Ｉｘｙ（いくしー）",
        tag_name: "ixy194",
        other_names: ["Ｉｘｙ（いくしー）", "ixy194"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          【お絵描き雑談】息抜き <https://www.youtube.com/live/7wNu09QE0SU?feature=share> "@YouTube":[https://misskey.io/@YouTube]より
        EOS
      )
    end

    context "A renote of another note" do
      strategy_should_work(
        "https://misskey.io/notes/9t8uyeog9an508vj",
        image_urls: [],
        media_files: [],
        page_url: "https://misskey.io/notes/9t8uyeog9an508vj",
        profile_url: "https://misskey.io/@77Pokomoko",
        profile_urls: %w[https://misskey.io/@77Pokomoko https://misskey.io/users/9t6jyv4n69zb085t],
        artist_name: "DP",
        tag_name: "77pokomoko",
        other_names: ["DP", "77Pokomoko"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "RE: <https://misskey.io/notes/9t8uxi3tcjpg026q>"
      )
    end

    context "A note crossposted from a remote instance" do
      strategy_should_work(
        "https://misskey.io/notes/9t3ulxtf6ydq00na",
        image_urls: %w[https://proxy.misskeyusercontent.jp/image.webp?url=https%3A%2F%2Fmedia.nijimissusercontent.app%2Fnull%2F0c368eb5-3ded-4d3b-a0b6-f729b3447ccf.webp],
        media_files: [{ file_size: 537_234 }],
        page_url: "https://misskey.io/notes/9t3ulxtf6ydq00na",
        profile_url: "https://misskey.io/@orizanin@nijimiss.moe",
        profile_urls: %w[https://misskey.io/@orizanin@nijimiss.moe https://nijimiss.moe/@orizanin],
        artist_name: "イケメン雌堕ちさせたい",
        tag_name: "orizanin",
        other_names: ["イケメン雌堕ちさせたい", "orizanin"],
        tags: [
          ["にじみすお絵描き部", "https://nijimiss.moe/tags/にじみすお絵描き部"],
          ["にじみすメイドの日", "https://nijimiss.moe/tags/にじみすメイドの日"],
          ["blobcat", "https://nijimiss.moe/tags/blobcat"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          :nyanpuppu:がメイドの日でメイド服を着てくれたよ！
          :kawaiidesune: "#にじみすお絵描き部":[https://nijimiss.moe/tags/にじみすお絵描き部] "#にじみすメイドの日":[https://nijimiss.moe/tags/にじみすメイドの日] "#blobcat":[https://nijimiss.moe/tags/blobcat]
        EOS
      )
    end

    context "A note with content warning" do
      strategy_should_work(
        "https://misskey.io/notes/9eh2m7ir57",
        image_urls: [],
        page_url: "https://misskey.io/notes/9eh2m7ir57",
        profile_url: "https://misskey.io/@sasanosuke00",
        profile_urls: %w[https://misskey.io/@sasanosuke00 https://misskey.io/users/9bvodr8oee],
        artist_name: "朝之助",
        tag_name: "sasanosuke00",
        other_names: ["朝之助", "sasanosuke00"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          RNしてくれたフォロワーさんの第一印象を答えます！
          (知らねぇやつばっかだからプロフィールとアイコンと直近のノートを参照しよう…。)
        EOS
      )
    end

    context "A note with an image with ALT text" do
      strategy_should_work(
        "https://misskey.io/notes/9s5obplljspt0cgi",
        image_urls: %w[https://media.misskeyusercontent.jp/io/webpublic-7d39c2bf-c743-415d-b839-277c01414d91.png],
        media_files: [{ file_size: 280_884 }],
        page_url: "https://misskey.io/notes/9s5obplljspt0cgi",
        profile_url: "https://misskey.io/@MishimaHiaka",
        profile_urls: %w[https://misskey.io/@MishimaHiaka https://misskey.io/users/9cb3x9itt0],
        artist_name: "三島ひあか🔞📐📕",
        tag_name: "mishimahiaka",
        other_names: ["三島ひあか🔞📐📕", "MishimaHiaka"],
        tags: [
          ["blobcat", "https://misskey.io/tags/blobcat"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          動かない方も見て:ablobcatangel:💘 "#blobcat":[https://misskey.io/tags/blobcat]

          キューピッドのにゃんぷっぷー(動かない方) :ablobcatangel:を元に私が描きました。
        EOS
      )
    end

    context "A note with a .wav file and an artist name containing emojis" do
      strategy_should_work(
        "https://misskey.io/notes/9t8taey8ejc402is",
        image_urls: %w[https://media.misskeyusercontent.jp/io/9a757584-3c18-42eb-a09a-ed41d716511e.wav],
        media_files: [{ file_size: 18_630_318 }],
        page_url: "https://misskey.io/notes/9t8taey8ejc402is",
        profile_url: "https://misskey.io/@asatsukininica",
        profile_urls: %w[https://misskey.io/@asatsukininica https://misskey.io/users/9bwwabvrw2],
        artist_name: "糸葱ににか",
        tag_name: "asatsukininica",
        other_names: ["糸葱ににか", "asatsukininica"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          チャリ乗りながらぶーんって言ってるだけの音声
        EOS
      )
    end

    context "A /play/ URL" do
      strategy_should_work(
        "https://misskey.io/play/9p3itbedgcal048f",
        image_urls: [],
        page_url: "https://misskey.io/play/9p3itbedgcal048f",
        profile_url: "https://misskey.io/@ruruke",
        profile_urls: %w[https://misskey.io/@ruruke https://misskey.io/users/9go6zwzccc],
        artist_name: "ruru (瑠々)",
        tag_name: "ruruke",
        other_names: ["ruru (瑠々)", "ruruke"],
        tags: [],
        dtext_artist_commentary_title: "にゃんぷっぷーとあそぼう！",
        dtext_artist_commentary_desc: <<~EOS.chomp
          あなただけのにゃんぷっぷーと共に、2人(1人と1匹？)だけのひとときを過ごしましょう！

          正常にプレイが出来ない場合リロードをお願いいたします

          [tn]代理で運用しております[/tn]
        EOS
      )
    end

    context "A s3.arkjp.net direct image url" do
      strategy_should_work(
        "https://s3.arkjp.net/misskey/99ae6116-2896-4cf3-9abc-e9746cd2408e.jpg",
        image_urls: ["https://s3.arkjp.net/misskey/99ae6116-2896-4cf3-9abc-e9746cd2408e.jpg"],
        media_files: [{ file_size: 100_766 }],
        page_url: nil
      )
    end

    context "A media.misskeyusercontent.jp direct image url" do
      strategy_should_work(
        "https://media.misskeyusercontent.jp/io/webpublic-806fd8e2-3425-486f-975e-2fb57d8e651a.png",
        image_urls: ["https://media.misskeyusercontent.jp/io/webpublic-806fd8e2-3425-486f-975e-2fb57d8e651a.png"],
        media_files: [{ file_size: 386_451 }],
        page_url: nil
      )
    end

    context "A media.misskeyusercontent.jp direct image url with referer" do
      strategy_should_work(
        "https://media.misskeyusercontent.jp/io/webpublic-806fd8e2-3425-486f-975e-2fb57d8e651a.png",
        referer: "https://misskey.io/notes/9ralx49uwpls07uy",
        image_urls: %w[https://media.misskeyusercontent.jp/io/webpublic-806fd8e2-3425-486f-975e-2fb57d8e651a.png],
        media_files: [{ file_size: 386_451 }],
        page_url: "https://misskey.io/notes/9ralx49uwpls07uy",
        profile_url: "https://misskey.io/@naga_U_",
        profile_urls: %w[https://misskey.io/@naga_U_ https://misskey.io/users/9e2h6b7kbv],
        artist_name: "ながユー@ｺﾐﾃｨｱ148【か05a】",
        tag_name: "naga_u",
        other_names: ["ながユー@ｺﾐﾃｨｱ148【か05a】", "naga_U_"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A files.misskey.art direct image url" do
      strategy_should_work(
        "https://files.misskey.art//webpublic-94d9354f-ddba-406b-b878-4ce02ccfa505.webp",
        image_urls: ["https://files.misskey.art//webpublic-94d9354f-ddba-406b-b878-4ce02ccfa505.webp"],
        media_files: [{ file_size: 35_338 }],
        page_url: nil
      )
    end

    context "A file.misskey.design direct image url" do
      strategy_should_work(
        "https://file.misskey.design/post/webpublic-ac7072e9-812f-460b-ad24-1f303a62f0b4.webp",
        image_urls: ["https://file.misskey.design/post/webpublic-ac7072e9-812f-460b-ad24-1f303a62f0b4.webp"],
        media_files: [{ file_size: 188_294 }],
        page_url: nil
      )
    end

    context "A note on https://oekakiskey.com" do
      strategy_should_work(
        "https://oekakiskey.com/notes/9t6ylo4flx",
        image_urls: %w[https://storage.googleapis.com/oekakiskey/drive/aecec9c1-5b1f-4781-abe1-3c94596aa2c1.webp],
        media_files: [{ file_size: 153_986 }],
        page_url: "https://oekakiskey.com/notes/9t6ylo4flx",
        profile_url: "https://oekakiskey.com/@zarame_zarame00",
        profile_urls: %w[https://oekakiskey.com/@zarame_zarame00 https://oekakiskey.com/users/9jf8m9wlo5],
        artist_name: "ざらめ",
        tag_name: "zarame_zarame00",
        other_names: ["ざらめ", "zarame_zarame00"],
        tags: [
          ["ざら博", "https://oekakiskey.com/tags/ざら博"],
          ["描いたよ", "https://oekakiskey.com/tags/描いたよ"],
          ["二次創作", "https://oekakiskey.com/tags/二次創作"],
          ["崩壊スターレイル", "https://oekakiskey.com/tags/崩壊スターレイル"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          Dr.レイシオ
          "#ざら博":[https://oekakiskey.com/tags/ざら博] "#描いたよ":[https://oekakiskey.com/tags/描いたよ]
          "#二次創作":[https://oekakiskey.com/tags/二次創作] "#崩壊スターレイル":[https://oekakiskey.com/tags/崩壊スターレイル]
        EOS
      )
    end

    context "A note on https://voskey.icalo.net" do
      strategy_should_work(
        "https://voskey.icalo.net/notes/9t87js83lp",
        image_urls: %w[https://voskeyfiles.icalo.net/drv/9ef122da-5431-4e80-a147-96a8e3e3a412.webp],
        media_files: [{ file_size: 315_422 }],
        page_url: "https://voskey.icalo.net/notes/9t87js83lp",
        profile_url: "https://voskey.icalo.net/@charks",
        profile_urls: %w[https://voskey.icalo.net/@charks https://voskey.icalo.net/users/9lgkn1xlpu],
        artist_name: "ちゃーくす",
        tag_name: "charks",
        other_names: ["ちゃーくす", "charks"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          いつものノリで言おうとしたけど、ひよっちゃったウナちゃん
        EOS
      )
    end

    context "A note on https://nijimiss.moe" do
      strategy_should_work(
        "https://nijimiss.moe/notes/01HPZQPJ6M9Y2DP134PRQ548EX",
        image_urls: %w[https://media.nijimiss.app/null/webpublic-ac9c1b40-8059-435b-b6b5-122a823d3594.webp],
        media_files: [{ file_size: 29_610 }],
        page_url: "https://nijimiss.moe/notes/01HPZQPJ6M9Y2DP134PRQ548EX",
        profile_url: "https://nijimiss.moe/@GAtturi_",
        profile_urls: %w[https://nijimiss.moe/@GAtturi_ https://nijimiss.moe/users/01GV09J8CQ19F0Z3T0D3PNDRRN],
        artist_name: "がっつり太郎",
        tag_name: "gatturi",
        other_names: ["がっつり太郎", "GAtturi_"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          $[shake :nekonohanao_nadetai:]
          横になっている猫の写真
        EOS
      )
    end

    context "A note on https://sushi.ski" do
      strategy_should_work(
        "https://sushi.ski/notes/9t78mwgf9v",
        image_urls: %w[https://media.sushi.ski/files/webpublic-530bd137-d146-4cd4-b1f0-676d7ce39db7.png],
        media_files: [{ file_size: 1_045_802 }],
        page_url: "https://sushi.ski/notes/9t78mwgf9v",
        profile_url: "https://sushi.ski/@Ru47me",
        profile_urls: %w[https://sushi.ski/@Ru47me https://sushi.ski/users/9rikwnr0fj],
        artist_name: "するめ",
        tag_name: "ru47me",
        other_names: ["するめ", "Ru47me"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "伊草ハルカ誕"
      )
    end

    context "A note on https://mk.yopo.work" do
      strategy_should_work(
        "https://mk.yopo.work/notes/995ig09wop",
        image_urls: %w[https://mk.yopo.work/files/webpublic-dcab49b3-4ad3-4455-aea0-28aa81ecca48],
        media_files: [{ file_size: 70_693 }],
        page_url: "https://mk.yopo.work/notes/995ig09wop",
        profile_url: "https://mk.yopo.work/@nano",
        profile_urls: %w[https://mk.yopo.work/@nano https://mk.yopo.work/users/9414vv7ush],
        artist_name: "菜乃",
        tag_name: "nano",
        other_names: ["菜乃", "nano"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          今日から菜乃は、ピュアホワイトピンクアラモーゼザ・ボルテーニョだ、、
          略して菜乃と呼んでくれ
        EOS
      )
    end

    context "An image URL on https://mk.yopo.work with a referer" do
      strategy_should_work(
        "https://mk.yopo.work/files/webpublic-dcab49b3-4ad3-4455-aea0-28aa81ecca48",
        referer: "https://mk.yopo.work/notes/995ig09wop",
        image_urls: %w[https://mk.yopo.work/files/webpublic-dcab49b3-4ad3-4455-aea0-28aa81ecca48],
        media_files: [{ file_size: 70_693 }],
        page_url: "https://mk.yopo.work/notes/995ig09wop",
        profile_url: "https://mk.yopo.work/@nano",
        profile_urls: %w[https://mk.yopo.work/@nano https://mk.yopo.work/users/9414vv7ush],
        artist_name: "菜乃",
        tag_name: "nano",
        other_names: ["菜乃", "nano"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          今日から菜乃は、ピュアホワイトピンクアラモーゼザ・ボルテーニョだ、、
          略して菜乃と呼んでくれ
        EOS
      )
    end

    context "An image URL on https://mk.yopo.work without a referer" do
      strategy_should_work(
        "https://mk.yopo.work/files/webpublic-dcab49b3-4ad3-4455-aea0-28aa81ecca48",
        image_urls: %w[https://mk.yopo.work/files/webpublic-dcab49b3-4ad3-4455-aea0-28aa81ecca48],
        media_files: [{ file_size: 70_693 }],
        page_url: nil,
        profile_url: nil,
        profile_urls: %w[],
        artist_name: nil,
        tag_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil
      )
    end

    context "A note that is deleted or nonexistent" do
      strategy_should_work(
        "https://misskey.io/notes/9pwis0jctbci003d",
        image_urls: [],
        media_files: [],
        page_url: "https://misskey.io/notes/9pwis0jctbci003d",
        profile_url: nil,
        profile_urls: %w[],
        artist_name: nil,
        tag_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    should "Parse Misskey URLs correctly" do
      assert(Source::URL.image_url?("https://s3.arkjp.net/misskey/thumbnail-10c4379a-b999-4148-9d32-7bb6f22453bf.webp"))
      assert(Source::URL.image_url?("https://s3.arkjp.net/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png"))
      assert(Source::URL.image_url?("https://media.misskeyusercontent.jp/io/dfca7bd4-c073-4ea0-991f-313ab3a77847.png"))
      assert(Source::URL.image_url?("https://media.misskeyusercontent.com/io/thumbnail-e9f307e4-3fad-435f-91b6-3768d688491d.webp"))
      assert(Source::URL.image_url?("https://media.misskeyusercontent.com/io/webpublic-a2cdd9c7-0449-4a61-b453-b5c7b2134677.png"))
      assert(Source::URL.image_url?("https://proxy.misskeyusercontent.com/image.webp?url=https%3A%2F%2Fimg.pawoo.net%2Fmedia_attachments%2Ffiles%2F111%2F232%2F575%2F490%2F284%2F147%2Foriginal%2F9aaf0c71a41b5647.jpeg"))
      assert(Source::URL.image_url?("https://media.misskeyusercontent.com/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png"))
      assert(Source::URL.image_url?("https://nos3.arkjp.net/image.webp?url=https%3A%2F%2Fimg.pawoo.net%2Fmedia_attachments%2Ffiles%2F110%2F314%2F466%2F230%2F358%2F806%2Foriginal%2F6fbcc38659d3cb97.jpeg"))
      assert(Source::URL.image_url?("https://s3.arkjp.net/misskey/930fe4fb-c07b-4439-804e-06fb472d698f.gif"))
      assert(Source::URL.image_url?("https://files.misskey.art//webpublic-94d9354f-ddba-406b-b878-4ce02ccfa505.webp"))
      assert(Source::URL.image_url?("https://file.misskey.design/post/webpublic-ac7072e9-812f-460b-ad24-1f303a62f0b4.webp"))
      assert_not(Source::URL.image_url?("https://media.misskeyusercontent.com"))

      assert(Source::URL.page_url?("https://misskey.io/notes/9bxaf592x6"))
      assert_equal("https://misskey.io/notes/9bxaf592x6", Source::URL.page_url("https://misskey.io/notes/9bxaf592x6#pswp"))

      assert(Source::URL.profile_url?("https://misskey.io/@ixy194"))
      assert(Source::URL.profile_url?("https://misskey.io/users/9bpemdns40"))
      assert_equal("https://misskey.io/users/9bpemdns40", Source::URL.profile_url("https://misskey.io/user-info/9bpemdns40"))

      assert_not(Source::URL.profile_url?("https://misskey.io/@"))
      assert_not(Source::URL.profile_url?("https://misskey.io/users/"))
      assert_not(Source::URL.profile_url?("https://misskey.io/user-info/"))

      assert_nil(Source::URL.parse("https://misskey.io/@ixy194").user_id)
      assert_equal("ixy194", Source::URL.parse("https://misskey.io/@ixy194").username)

      assert_equal("9bpemdns40", Source::URL.parse("https://misskey.io/users/9bpemdns40").user_id)
      assert_nil(Source::URL.parse("https://misskey.io/users/9bpemdns40").username)
    end
  end
end
