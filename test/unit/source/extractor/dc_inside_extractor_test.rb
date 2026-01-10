require "test_helper"

module Source::Tests::Extractor
  class DcInsideExtractorTest < ActiveSupport::TestCase
    context "A page URL" do
      strategy_should_work(
        "https://gall.dcinside.com/mgallery/board/view?id=projectmx&no=14994409",
        image_urls: %w[
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ba4f8f184a66ea61b10f0d45c16cd41b0a8f6f6cfef1d4
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ba4f8f184a66ea61b10f0d40c538da1e0b8f616cfef11d
        ],
        media_files: [
          { file_size: 6_297_287 },
          { file_size: 6_422_384 },
        ],
        page_url: "https://gall.dcinside.com/mgallery/board/view/?id=projectmx&no=14994409",
        profile_urls: %w[https://gallog.dcinside.com/wd3h8jz2hdnf],
        display_name: "메홍챠",
        username: "wd3h8jz2hdnf",
        tags: [],
        dtext_artist_commentary_title: "[🎨창작] 지뢰계 히카리/노조미 그림그렸어요",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "2caed427f6d63cb16aa8c5b158c12a3a1ad241f0fad285a362abf5ad4a":[https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ff1ad5734a6e5c0f5d163c4901cdb8e4f7c6616fd39a3109f70107]
          "2caed427f6d63cb16aa8c5b132f5020e75544ba9563d9cf99c8ea652d451ad6b3b1a":[https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ff1ad5734a6e5c0f5d163c4901cdb8e1f3926f6ad29a25dea500f8]
          5일페 ［난선생님에게아무것도아니야사라져도누구도신경쓰지않을거야그렇지만날계속봐줬으면좋겠...］부스에 굿즈로 나가는 친구들입니다
          타이밍 좋게 게임에도 실장되어서 너무 기쁘네요^_^
        EOS
      )
    end

    context "An image URL with a referer" do
      strategy_should_work(
        "https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ba4f8f184a66ea61b10f0d45c16cd41b0a8f6f6cfef1d4",
        referer: "https://gall.dcinside.com/mgallery/board/view?id=projectmx&no=14994409",
        image_urls: %w[
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ba4f8f184a66ea61b10f0d45c16cd41b0a8f6f6cfef1d4
        ],
        media_files: [
          { file_size: 6_297_287 },
        ],
        page_url: "https://gall.dcinside.com/mgallery/board/view/?id=projectmx&no=14994409",
        profile_urls: %w[https://gallog.dcinside.com/wd3h8jz2hdnf],
        display_name: "메홍챠",
        username: "wd3h8jz2hdnf",
        tags: [],
        dtext_artist_commentary_title: "[🎨창작] 지뢰계 히카리/노조미 그림그렸어요",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "2caed427f6d63cb16aa8c5b158c12a3a1ad241f0fad285a362abf5ad4a":[https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ff1ad5734a6e5c0f5d163c4901cdb8e4f7c6616fd39a3109f70107]
          "2caed427f6d63cb16aa8c5b132f5020e75544ba9563d9cf99c8ea652d451ad6b3b1a":[https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ff1ad5734a6e5c0f5d163c4901cdb8e1f3926f6ad29a25dea500f8]
          5일페 ［난선생님에게아무것도아니야사라져도누구도신경쓰지않을거야그렇지만날계속봐줬으면좋겠...］부스에 굿즈로 나가는 친구들입니다
          타이밍 좋게 게임에도 실장되어서 너무 기쁘네요^_^
        EOS
      )
    end

    context "An image URL without a referer" do
      strategy_should_work(
        "https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ba4f8f184a66ea61b10f0d45c16cd41b0a8f6f6cfef1d4",
        image_urls: %w[
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ba4f8f184a66ea61b10f0d45c16cd41b0a8f6f6cfef1d4
        ],
        media_files: [
          { file_size: 6_297_287 },
        ],
        page_url: nil,
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A post from user without an account" do
      strategy_should_work(
        "https://gall.dcinside.com/mgallery/board/view/?id=mibj&no=5555447",
        image_urls: %w[https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa1bd6253138ca63577cd68a52ea2273d44e23221455bf85eaff50198e86e7556536f8225ec43c51bee7f880553a480c13],
        media_files: [{ file_size: 1_802_358 }],
        page_url: "https://gall.dcinside.com/mgallery/board/view/?id=mibj&no=5555447",
        profile_urls: %w[],
        display_name: "ㅇㅇ",
        username: "",
        tags: [],
        dtext_artist_commentary_title: "[창작🎨] 꼬술이 그림",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "7fe88072b78676ac7eb8f68b12d21a1d0cf382bbf066db":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce885fa1bd6253138ca63577cd68a52ea2273d44e23221455bf85eaff144adaeee5566732fd26352d7749bb84bec21da42bf63865caf93f]
          그렸으니 나오겠지?
          다들 행복가챠하자
        EOS
      )
    end

    context "A .gif post" do
      strategy_should_work(
        "https://gall.dcinside.com/mgallery/board/view/?id=mibj&no=5554705",
        image_urls: %w[
          https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c039c2cde73e9e69751b6508367a96317c90201edfd835548d8ecce669
          https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c061d1310c3ea322cedc88a2c2a5d8e92b0ee3e21da5f76f136e5b21ee77
          https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c0665183a0ef7dfa0b12b082178f5b95cf7028847baf586ddb2874c5cd
          https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c063b7f07dd18f844fa3a6152c3378d0a18b2690573df03aea122105da
          https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c062ad4f16a6cff931cf75d3bb6bb7320030c5391877128a50628fc0b6
          https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c03258e40cb0adb9de12d7d605b0b574b7d5d3c15deaaaaeb32b9c61cc
          https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c039959ae36ec433711b6508367a96317c9048fb48e58d73c54a6db1b4
          https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c062f91c46a4cff637cf75d3bb6bb7320030e093d86e9607f18e7cb8ae
          https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c03344d242a0d3e68d1b3650375dcd9322229b83f6b0ca12695d513205
          https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c06435857b77080b053a66cfb364a58425b803ce436b13fa6eef61b76c
        ],
        media_files: [
          { file_size: 9_017_382 },
          { file_size: 8_464_656 },
          { file_size: 8_385_480 },
          { file_size: 7_595_402 },
          { file_size: 10_579_355 },
          { file_size: 8_443_734 },
          { file_size: 16_802_464 },
          { file_size: 12_739_034 },
          { file_size: 12_784_623 },
          { file_size: 7_558_038 },
        ],
        page_url: "https://gall.dcinside.com/mgallery/board/view/?id=mibj&no=5554705",
        profile_urls: %w[https://gallog.dcinside.com/kimin3424],
        display_name: "타르가",
        username: "kimin3424",
        tags: [],
        dtext_artist_commentary_title: "[창작🎨] 로도스의 빛 볼겜이랑 콜라보하기앱에서 작성",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          배치
          걷기
          그로기
          멍때리기
          스킬
          화내기
          대기
          공격1
          공격2
          댄스
          스즈란은 우리들의 빛이라는 것을 기억해
        EOS
      )
    end

    context "A post without download links" do
      strategy_should_work(
        "https://gall.dcinside.com/mgallery/board/view?id=projectmx&no=12834101",
        image_urls: %w[https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de98efa1bd62531416b0cf072989a548cbc1d4adf4728efb2c5786b58077507144c1adb1423abd69b4ca94b482af027fd0f42fa68bbbaaebc],
        media_files: [{ file_size: 4_949_125 }],
        page_url: "https://gall.dcinside.com/mgallery/board/view/?id=projectmx&no=12834101",
        profile_urls: %w[https://gallog.dcinside.com/4756qwer],
        display_name: "44",
        username: "4756qwer",
        tags: [],
        dtext_artist_commentary_title: "[🎨창작] 아로나 그린거 보실분",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de98efa1bd62531416b0cf072989a548cbc1d4adf4728efb2c5786b58077507144c5e8b424ba8d4f071e5f71bb7f51881cd678a6d59e4c5bf7874b906":[https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de98efa1bd62531416b0cf072989a548cbc1d4adf4728efb2c5786b58077507144c5e8b424ba8d4f071e5f71bb7f51881cd678a6d59e4c5bf7874b906]
          "11":[https://dcimg5.dcinside.com/dccon.php?no=62b5df2be09d3ca567b1c5bc12d46b394aa3b1058c6e4d0ca41648b65fe8266eadc328cfdea5b74810026b505984e855639060800d4d06195f505e37f50b07e65e55156664b2e18c4d318c15]
          "[b]イブ님(@IV70311741) [/b]
          15.晴れ
          x.com
          ":[https://x.com/IV70311741/status/1838151449202798751]
        EOS
      )
    end

    context "A post with lowres static image" do
      strategy_should_work(
        "https://gall.dcinside.com/mgallery/board/view/?id=wutheringwaves&no=1048846",
        image_urls: %w[https://dcimg1.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de882fa1bd62531b6b898211a669f8109c0200b5f38eee53cbc0166b03709dfe09883156a5b650175adb480faac5778fa1858b1221531f2e4f250522e52de0ab12ca7],
        media_files: [{ file_size: 68_996 }],
        page_url: "https://gall.dcinside.com/mgallery/board/view/?id=wutheringwaves&no=1048846",
        profile_urls: %w[https://gallog.dcinside.com/mission7804],
        display_name: "요로로롱",
        username: "mission7804",
        tags: [],
        dtext_artist_commentary_title: "[창작🎨] 카르띳띠 그렸음다",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "0ebcc232e0c630bf67be9bb619dc6a373d1058f1942ff49dbfce9ab3f7bf":[https://dcimg1.dcinside.com/viewimage.php?id=3aa8c42ee0c031a869a8d7a313c2&no=24b0d769e1d32ca73de882fa1bd62531b6b898211a669f8109c0200b5f38eee53cbc0166b03709dfe09883156a5b650175adb480faac5778fa1858b1221531f2e4f250522e52de0ab12ca7]
          개미는 오늘도 열심히 ...!!!
        EOS
      )
    end

    context "A post with images with no src in the html" do
      strategy_should_work(
        "https://gall.dcinside.com/mgallery/board/view/?id=mibj&no=5697412",
        image_urls: %w[
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bc9db103b394dfafb9279fd26dab9dff402031a3ad2453a
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bc9d81d3b3e4cfefe9872fd6df4532d510fd111bf3be3e6
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bcedf16303e4cfbf99d79fd63a61448d07192b32e7c4655
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bc8d8163d3d4dfeff9c78fde55a6df3990de1d07fa8143f
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bcdd91d3f3a4bfaf99f79fd592e747ff4a830178c0ef10a
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bcdd615313d48f8f69e70fd104eabd3614616514755b421
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bcdda1d303b48f9fc9a74fd1c0b81c8e32f6cca66741c54
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bc9d817383e4ef3f79f72fd87e2a87e839925b12b7b6fda
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bc6de123a394bfefb9974fd6a6871eff0ebb00f53c4b813
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bc7d91730324ef8f79977fdc7882fa1af1553fe24c084d7
          https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516bcbd8133e3f48fef69978fd38046aeaa6635f1073856021
        ],
        media_files: [
          { file_size: 6_763_431 },
          { file_size: 5_907_319 },
          { file_size: 772_479 },
          { file_size: 3_548_200 },
          { file_size: 3_059_745 },
          { file_size: 5_042_700 },
          { file_size: 3_133_262 },
          { file_size: 4_869_753 },
          { file_size: 1_577_104 },
          { file_size: 3_131_848 },
          { file_size: 7_881_577 },
        ],
        page_url: "https://gall.dcinside.com/mgallery/board/view/?id=mibj&no=5697412",
        profile_urls: %w[https://gallog.dcinside.com/miyulover024],
        display_name: "ㅇㅇ",
        username: "miyulover024",
        tags: [],
        dtext_artist_commentary_title: "[창작🎨] 그렸던거 모음",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "a1400cad1a1eb44caa323c6d4f866c69e20ff04ca48f381c65234429c370d44bf3":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b47573d4efefd997793ab4b82f67947bee055bcb9277f382898]
          "a1400cad1a1eb44caa323c6d4f866c6867c191ed705175230e5d48a8af24f55746":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b47573d4df3fd9e7697c77d716e0ab8d8169a97edc27d7d5479]
          "a1400cad1a1eb44caa323c6d4e816c6eea749a3b5e693d99da3fa7b6a3a5ec06":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b47573a4af8f69e769291f5854d095e9aeb3949fe02665deb8c]
          "a1400cad1a1eb44caa323c6d4e896c6fd90c908ff13b2fc1428763ad7b5438cca1":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b47573c4df8fb9d7797816d38f8c90519ad67eb6796d27cd366]
          "a1400cad1a1eb44caa323c6d4e896a2d06b1659250ca6fedce63f6c22f63bc":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b4757394cf3f99a7193098fc8393c0645c24fed00f4dc8a1e5f]
          "a1400cad1a1eb44caa323c6d4f826a2dfa06ae90edfea1ba04cc37405e7e4f":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b47573943fbf79d72910dcf63414f76aa2e00ad8473226eae07]
          "a1400cad1a1eb44caa323c6d4f856c691d7df994adc87b65e8bcf8a580cad23e10":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b4757394ff3f69b72904fb3c3f69c2169db0aad220029be5a7e]
          "a1400cad1a1eb44caa323c6d4f876c6c461f989149b3e828b87cfabae3dfd950dc":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b47573d4df9fe9e749a419a3c7236e776ca430cce0f3fd1861b]
          "a1400cad1a1eb44caa323c6d40876c6cda07e4e911d230b0f1390f9623805426e0":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b4757324bfcfc997197db79debbb5f7ac533ee1183ecbc2cd37]
          "a1400cad1a1eb44caa323c6d4f896a2d9faded3f829978c97e39d8c02aab93":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b4757334cf9f69274917df7338a3a295b7a14fd093f0f8c8273]
          "a1400cad1a1eb44caa323c6d4f896c6e3c3c82106dc37fb800f0c9cc6373ca4d0d":[https://dcimg1.dcinside.com/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce880fa1bd62531b1ff05ae57c74e7d1bb347396ebf29a7b754e2516b888b47573f4dfdf89f72978cdd21ee33cdfd4de845214b6ee944b8]
        EOS
      )
    end
  end
end
