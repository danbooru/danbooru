require "test_helper"

module Source::Tests::Extractor
  class MisskeyExtractorTest < ActiveSupport::ExtractorTestCase
    context "A https://misskey.io/notes/:note_id url" do
      strategy_should_work(
        "https://misskey.io/notes/9bxaf592x6",
        image_urls: %w[https://media.misskeyusercontent.jp/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png],
        media_files: [{ file_size: 197_151 }],
        page_url: "https://misskey.io/notes/9bxaf592x6",
        profile_url: "https://misskey.io/@ixy194",
        profile_urls: %w[https://misskey.io/@ixy194 https://misskey.io/users/9bpemdns40],
        display_name: "Ｉｘｙ（いくしー）",
        username: "ixy194",
        tag_name: "ixy194",
        other_names: ["Ｉｘｙ（いくしー）", "ixy194"],
        tags: [
          ["村上さん", "https://misskey.io/tags/村上さん"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "Ｉｘｙ（いくしー）",
        username: "ixy194",
        tag_name: "ixy194",
        other_names: ["Ｉｘｙ（いくしー）", "ixy194"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "おりきゃら",
      )
    end

    context "A note without any files" do
      strategy_should_work(
        "https://misskey.io/notes/9ef8xtot2m",
        image_urls: [],
        page_url: "https://misskey.io/notes/9ef8xtot2m",
        profile_url: "https://misskey.io/@ixy194",
        profile_urls: %w[https://misskey.io/@ixy194 https://misskey.io/users/9bpemdns40],
        display_name: "Ｉｘｙ（いくしー）",
        username: "ixy194",
        tag_name: "ixy194",
        other_names: ["Ｉｘｙ（いくしー）", "ixy194"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "DP",
        username: "77Pokomoko",
        tag_name: "77pokomoko",
        other_names: ["DP", "77Pokomoko"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "RE: <https://misskey.io/notes/9t8uxi3tcjpg026q>",
      )
    end

    context "A note crossposted from a remote instance" do
      strategy_should_work(
        "https://misskey.io/notes/9t3ulxtf6ydq00na",
        image_urls: %w[https://proxy.misskeyusercontent.jp/image/media.nijimissusercontent.app%2Fnull%2F0c368eb5-3ded-4d3b-a0b6-f729b3447ccf.webp?],
        media_files: [{ file_size: 537_234 }],
        page_url: "https://misskey.io/notes/9t3ulxtf6ydq00na",
        profile_url: "https://misskey.io/@orizanin@nijimiss.moe",
        profile_urls: %w[https://misskey.io/@orizanin@nijimiss.moe https://nijimiss.moe/@orizanin],
        display_name: "いけめす",
        username: "orizanin",
        tags: [
          ["にじみすお絵描き部", "https://nijimiss.moe/tags/にじみすお絵描き部"],
          ["にじみすメイドの日", "https://nijimiss.moe/tags/にじみすメイドの日"],
          ["blobcat", "https://nijimiss.moe/tags/blobcat"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "朝之助",
        username: "sasanosuke00",
        tag_name: "sasanosuke00",
        other_names: ["朝之助", "sasanosuke00"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "三島ひあか🔞📐📕",
        username: "MishimaHiaka",
        tag_name: "mishimahiaka",
        other_names: ["三島ひあか🔞📐📕", "MishimaHiaka"],
        tags: [
          ["blobcat", "https://misskey.io/tags/blobcat"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "糸葱ににか",
        username: "asatsukininica",
        tag_name: "asatsukininica",
        other_names: ["糸葱ににか", "asatsukininica"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: nil,
        username: "ruruke",
        tags: [],
        dtext_artist_commentary_title: "にゃんぷっぷーとあそぼう！",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          あなただけのにゃんぷっぷーと共に、2人(1人と1匹？)だけのひとときを過ごしましょう！

          正常にプレイが出来ない場合リロードをお願いいたします

          [tn]代理で運用しております[/tn]
        EOS
      )
    end

    context "A media.misskeyusercontent.jp direct image url" do
      strategy_should_work(
        "https://media.misskeyusercontent.jp/io/webpublic-806fd8e2-3425-486f-975e-2fb57d8e651a.png",
        image_urls: ["https://media.misskeyusercontent.jp/io/webpublic-806fd8e2-3425-486f-975e-2fb57d8e651a.png"],
        media_files: [{ file_size: 386_451 }],
        page_url: nil,
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
        display_name: "ながユー",
        username: "naga_U_",
        tag_name: "naga_u",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A files.misskey.art direct image url" do
      strategy_should_work(
        "https://files.misskey.art//webpublic-94d9354f-ddba-406b-b878-4ce02ccfa505.webp",
        image_urls: ["https://files.misskey.art//webpublic-94d9354f-ddba-406b-b878-4ce02ccfa505.webp"],
        media_files: [{ file_size: 35_338 }],
        page_url: nil,
      )
    end

    context "A file.misskey.design direct image url" do
      # https://misskey.design/notes/a7lgqwn63mac1nhk
      strategy_should_work(
        "https://file.misskey.design/post/42d7b257-a2a2-4b68-bd10-d1ac3d0cc4fe.webp",
        image_urls: %w[https://file.misskey.design/post/42d7b257-a2a2-4b68-bd10-d1ac3d0cc4fe.webp],
        media_files: [{ file_size: 115_390 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
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
        display_name: "ざらめ",
        username: "zarame_zarame00",
        tag_name: "zarame_zarame00",
        other_names: ["ざらめ", "zarame_zarame00"],
        tags: [
          ["ざら博", "https://oekakiskey.com/tags/ざら博"],
          ["描いたよ", "https://oekakiskey.com/tags/描いたよ"],
          ["二次創作", "https://oekakiskey.com/tags/二次創作"],
          ["崩壊スターレイル", "https://oekakiskey.com/tags/崩壊スターレイル"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "ちゃーくす",
        username: "charks",
        tag_name: "charks",
        other_names: ["ちゃーくす", "charks"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "がっつり太郎",
        username: "GAtturi_",
        tag_name: "gatturi",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          $[shake :nekonohanao_nadetai:]
          横になっている猫の写真
        EOS
      )
    end

    context "A note on https://sushi.ski" do
      strategy_should_work(
        "https://sushi.ski/notes/aj6emmgk64",
        image_urls: %w[https://media.sushi.ski/files/81c28c2c-bd40-4cd8-9e33-2d96bd5c6028.webp],
        media_files: [{ file_size: 171_046 }],
        page_url: "https://sushi.ski/notes/aj6emmgk64",
        profile_urls: %w[https://sushi.ski/@mgmgrun https://sushi.ski/users/9grk7g7v93],
        display_name: "繧ゅ＄繧ゅ＄",
        username: "mgmgrun",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "モフモフ仲間が増えたぜ",
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
        display_name: "菜乃",
        username: "nano",
        tag_name: "nano",
        other_names: ["菜乃", "nano"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "菜乃",
        username: "nano",
        tag_name: "nano",
        other_names: ["菜乃", "nano"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: nil,
        username: nil,
        tag_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil,
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
        display_name: nil,
        username: nil,
        tag_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
