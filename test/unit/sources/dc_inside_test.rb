require "test_helper"

module Sources
  class DcInsideTest < ActiveSupport::TestCase
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
        dtext_artist_commentary_desc: <<~EOS.chomp
          "2caed427f6d63cb16aa8c5b158c12a3a1ad241f0fad285a362abf5ad4a":[https://dcimg4.dcinside.co.kr/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ff1ad5734a6e5c0f5d163c4901cdb8e4f7c6616fd39a3109f70107]
          "2caed427f6d63cb16aa8c5b132f5020e75544ba9563d9cf99c8ea652d451ad6b3b1a":[https://dcimg4.dcinside.co.kr/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ff1ad5734a6e5c0f5d163c4901cdb8e1f3926f6ad29a25dea500f8]
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
        dtext_artist_commentary_desc: <<~EOS.chomp
          "2caed427f6d63cb16aa8c5b158c12a3a1ad241f0fad285a362abf5ad4a":[https://dcimg4.dcinside.co.kr/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ff1ad5734a6e5c0f5d163c4901cdb8e4f7c6616fd39a3109f70107]
          "2caed427f6d63cb16aa8c5b132f5020e75544ba9563d9cf99c8ea652d451ad6b3b1a":[https://dcimg4.dcinside.co.kr/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de885fa1bd62531058478fac3157bc024e4bab3a06677d6d31d4957ed12b900e4a4ff1ad5734a6e5c0f5d163c4901cdb8e1f3926f6ad29a25dea500f8]
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
        dtext_artist_commentary_desc: ""
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
        dtext_artist_commentary_desc: <<~EOS.chomp
          "7fe88072b78676ac7eb8f68b12d21a1d0cf382bbf066db":[https://dcimg4.dcinside.co.kr/viewimage.php?id=20b4d22c&no=24b0d769e1d32ca73ce885fa1bd6253138ca63577cd68a52ea2273d44e23221455bf85eaff144adaeee5566732fd26352d7749bb84bec21da42bf63865caf93f]
          그렸으니 나오겠지?
          다들 행복가챠하자
        EOS
      )
    end

    context "A .gif post" do
      strategy_should_work(
        "https://gall.dcinside.com/mgallery/board/view/?id=mibj&no=5554705",
        image_urls: %w[
          https://dcimg4.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c039c2cde73e9e69751b6508367a96317c90201edfd835548d8ecce669
          https://dcimg4.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c061d1310c3ea322cedc88a2c2a5d8e92b0ee3e21da5f76f136e5b21ee77
          https://dcimg4.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c0665183a0ef7dfa0b12b082178f5b95cf7028847baf586ddb2874c5cd
          https://dcimg4.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c063b7f07dd18f844fa3a6152c3378d0a18b2690573df03aea122105da
          https://dcimg4.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c062ad4f16a6cff931cf75d3bb6bb7320030c5391877128a50628fc0b6
          https://dcimg4.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c03258e40cb0adb9de12d7d605b0b574b7d5d3c15deaaaaeb32b9c61cc
          https://dcimg4.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c062f91c46a4cff637cf75d3bb6bb7320030e093d86e9607f18e7cb8ae
          https://dcimg4.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c039959ae36ec433711b6508367a96317c9048fb48e58d73c54a6db1b4
          https://dcimg4.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c03344d242a0d3e68d1b3650375dcd9322229b83f6b0ca12695d513205
          https://dcimg4.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73ce885fa11d02831c6a32dfed26d20f239ad53f34611e2dff73e5581758fb07253207f5a6256c06435857b77080b053a66cfb364a58425b803ce436b13fa6eef61b76c
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
        dtext_artist_commentary_desc: <<~EOS.chomp
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
        dtext_artist_commentary_desc: <<~EOS.chomp
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
        image_urls: %w[https://dcimg8.dcinside.co.kr/viewimage.php?no=24b0d769e1d32ca73de882fa1bd62531b6b898211a669f8109c0200b5f38eee53cbc0166b03709dfe09883156a5b650175adb480faac5778fa1858b1221531f2e4f250522e52de0ab12ca7],
        media_files: [{ file_size: 0 }],
        page_url: "https://gall.dcinside.com/mgallery/board/view/?id=wutheringwaves&no=1048846",
        profile_urls: %w[https://gallog.dcinside.com/mission7804],
        display_name: "요로로롱",
        username: "mission7804",
        tags: [],
        dtext_artist_commentary_title: "[창작🎨] 카르띳띠 그렸음다",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "0ebcc232e0c630bf67be9bb619dc6a373d1058f1942ff49dbfce9ab3f7bf":[https://dcimg8.dcinside.co.kr/viewimage.php?id=3aa8c42ee0c031a869a8d7a313c2&no=24b0d769e1d32ca73de882fa1bd62531b6b898211a669f8109c0200b5f38eee53cbc0166b03709dfe09883156a5b650175adb480faac5778fa1858b1221531f2e4f250522e52de0ab12ca7]
          개미는 오늘도 열심히 ...!!!
        EOS
      )
    end

    should "Parse DC Inside URLs correctly" do
      assert(Source::URL.image_url?("https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a394179b720ead53a80d89030c996204118d07dadf713bafb452d54f081&orgExt"))
      assert(Source::URL.image_url?("https://image.dcinside.com/viewimagePop.php?no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b"))
      assert(Source::URL.image_url?("https://image.dcinside.com/viewimage.php?id=&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b"))
      assert(Source::URL.page_url?("https://gall.dcinside.com/mgallery/board/view?id=projectmx&no=11076518"))
      assert(Source::URL.profile_url?("https://gallog.dcinside.com/mannack0106"))
    end
  end
end
