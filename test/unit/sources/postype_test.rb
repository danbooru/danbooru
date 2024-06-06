# frozen_string_literal: true

require "test_helper"

module Sources
  class PostypeTest < ActiveSupport::TestCase
    context "Postype:" do
      context "A https://www.postype.com/_next/image URL" do
        strategy_should_work(
          "https://www.postype.com/_next/image?url=https%3A%2F%2Fd3mcojo3jv0dbr.cloudfront.net%2F2024%2F04%2F03%2F12%2F46%2F1ffb36f1881b16a5c5881fc6eaa06179.jpeg%3Fw%3D1000%26h%3D700%26q%3D65&w=3840&q=75",
          image_urls: %w[https://d3mcojo3jv0dbr.cloudfront.net/2024/04/03/12/46/1ffb36f1881b16a5c5881fc6eaa06179.jpeg],
          media_files: [{ file_size: 35_970 }],
          page_url: nil
        )
      end

      context "A Postype sample image URL" do
        strategy_should_work(
          "https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg?w=1200&q=90",
          image_urls: %w[https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg],
          media_files: [{ file_size: 791_613 }],
          page_url: nil
        )
      end

      context "A Postype full image URL" do
        strategy_should_work(
          "https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg",
          image_urls: %w[https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg],
          media_files: [{ file_size: 791_613 }],
          page_url: nil
        )
      end

      context "A Postype post" do
        strategy_should_work(
          "https://athanjccgg.postype.com/post/15762592",
          image_urls: %w[
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/18/37/e982ccab314dbd965157030f06b3828e.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/e176808d694ac811a8584fe2a2c26ff9.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/d0ec24ca2d8d59afa4a2ef4e72868cdf.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/13104038ae48fc91ae989a07b59cefc4.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/19/22/22/f6b8f26eedae78fbe446a01d6e6d71df.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/19/22/22/c1f7ec96000087c986e7fe903d8c2897.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/ef08f075aa7f28ceb5e3497b30682878.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/010e3f3a4537948591686853adfdb5e7.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/56/ce6d9613301160957d79419c5ebe93e9.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/31/7aa5394beaa2c6137294d554f0ce3021.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/e8ca9c99f0a291f7cca37f59e8a04504.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/0e911b2491ce79cfc34263ab8fa7f321.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/c0580a3afab3afec14a92a442e450cf0.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/79bb9f544cb774f81b3a84a74c47ee82.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/670767285f24d8ffdf5757cc47737f7a.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/46840ea027bf7777c67a60daacc64898.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/cd4a852afa856f82320dd1f050779401.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/18/25/4c580ee5f2d33aab223068a9bade3312.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/55/bfd35e46694449ced5f67f1c857bc98b.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/10/7c9fa9dcf632f417bc89e9bc9c623f0c.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/1c3f33326013cba06f00e5ae5323f312.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/52757da8fa5d65e7fcbc6952cef86339.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/18/42/1d9b4caae40ccf95c93268fdf911a588.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/55/7f29bba54885a28b2ea530b8550f9bc9.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/09/e91037a73172fa6c6d96c56f5d17c84b.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/68c98094631a94674989619b8df32d15.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/00f0b41eabb89a65ebbde399eee44eb1.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/d82ae617f59b9603ca903241fe411908.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/a468ef7913e7dec2f52d8db4ed44122b.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/55/212187cb36b23bbb7e0efdff3e310801.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/a3b203463c3239c0cb108f3da6227509.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/10/00/37/bcc816931e1768567d2caa1bbee4fd27.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/ab67a8f2b6e836f5130993631e1bb9f4.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/21/7c45c9d8d9c0413dbfb7ed8bbde004e5.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/55/4c4186f352b85b6ace1baa2f7a123ec3.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/39/d34a59fdb61d7e98bbdebb5380159e35.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/f164e245319c5263732eccc86c8a43f6.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/25/73b73893950168bbff9abeee3af2196d.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/39/f7bb7fde9c858466d1397827350f3288.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/20e95db3b647a55937a29d9c83eee8bc.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/25/24105c83720d5e7b38714140b9419c2d.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/25/59f5e836312750b402ab1216385f9dbe.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/26/3974daa81edb865e029a1aaaeb6e86ee.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/25/ffeeaa9789058dd7f917d76f2c5dfb07.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/01/32/c4f99a0212a1d19c8477872026d523a0.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/25/1e68ec345302d2a32390ed594c5442b0.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/00/53/96fd53b11b5dca135ece683486420280.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/00/53/dab5c4612e74bbe4b929ce5e29860ab0.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/21/38/18b4be31fe337227e41dd070534ad8b5.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/15/00/2f5815964b746abc093e1990613e1538.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/18/33/053de136cb57364c980fab70daf028f7.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/33/289a4e4c7c2a930f2232a9c2f827bf0c.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/03/14/b74199027c683bb5b66e8a1bb1d5b7b1.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/03/49/7d7125d249216b8ac39d7c06f855fc48.jpeg
          ],
          media_files: [
            { file_size: 210_280 },
            { file_size: 567_426 },
            { file_size: 1_171_978 },
            { file_size: 1_312_734 },
            { file_size: 362_101 },
            { file_size: 349_591 },
            { file_size: 245_661 },
            { file_size: 2_514_947 },
            { file_size: 432_253 },
            { file_size: 751_860 },
            { file_size: 196_062 },
            { file_size: 437_366 },
            { file_size: 1_191_756 },
            { file_size: 381_211 },
            { file_size: 464_061 },
            { file_size: 105_203 },
            { file_size: 1_003_260 },
            { file_size: 142_036 },
            { file_size: 1_256_566 },
            { file_size: 247_356 },
            { file_size: 154_747 },
            { file_size: 94_717 },
            { file_size: 1_481_762 },
            { file_size: 909_140 },
            { file_size: 217_548 },
            { file_size: 793_926 },
            { file_size: 267_291 },
            { file_size: 79_855 },
            { file_size: 163_827 },
            { file_size: 2_577_570 },
            { file_size: 196_567 },
            { file_size: 271_809 },
            { file_size: 379_406 },
            { file_size: 879_503 },
            { file_size: 415_726 },
            { file_size: 276_683 },
            { file_size: 262_524 },
            { file_size: 3_573_937 },
            { file_size: 542_140 },
            { file_size: 248_825 },
            { file_size: 1_979_530 },
            { file_size: 1_148_762 },
            { file_size: 277_343 },
            { file_size: 845_435 },
            { file_size: 173_727 },
            { file_size: 434_088 },
            { file_size: 342_659 },
            { file_size: 213_829 },
            { file_size: 1_861_224 },
            { file_size: 447_988 },
            { file_size: 221_965 },
            { file_size: 234_277 },
            { file_size: 43_137 },
            { file_size: 1_736_147 },
          ],
          page_url: "https://www.postype.com/@athanjccgg/post/15762592",
          profile_urls: %w[https://www.postype.com/@athanjccgg https://www.postype.com/profile/@2g2740],
          display_name: "얼음비데",
          username: "2g2740",
          tags: [],
          dtext_artist_commentary_title: "스파 로그",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/18/37/e982ccab314dbd965157030f06b3828e.png?w=1200&q=90]

            한 반년동안 그린건데 이게 그린순으로 정렬하니까

            아저씨였다가 남자아이였다가 왔다갔다하니까 정신없어서 그냥 연령대순으로 정리했습니다

            스6->스제로->존재할리없는날조된남자아이

            순으로 나열하였습니다

            보시다보면 언제부턴가 갑자기 쥐도새도모르게 어려져있을 것입니다.............ㄷㄷㄷㄷㄷㄷㄷㄷㄷㄷ

            커플링은 그냥 원하시는대로 생각해주세요..ㅎㅎ 이젠 적기도 귀찮아져서가 아니고 인마!!!!!!!!!!!!!!!!!

            + 20240604 수정

            딱히 성인물은 없는데

            외국인들이 여기서 불펌해가길래 성인걸었어요

            낚시ㄷㄷ 죄송합니다

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/e176808d694ac811a8584fe2a2c26ff9.png?w=1200&q=90]

            류 수련의성과로 뼈늘어서 176되면어떡하지

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/d0ec24ca2d8d59afa4a2ef4e72868cdf.jpeg?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/13104038ae48fc91ae989a07b59cefc4.jpeg?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/19/22/22/f6b8f26eedae78fbe446a01d6e6d71df.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/19/22/22/c1f7ec96000087c986e7fe903d8c2897.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/ef08f075aa7f28ceb5e3497b30682878.png?w=1200&q=90]

            고양이수염같은상처 저거 멀리서봐도 진짜 잘보이는데

            아.. 이게 진짜 귀여운데..

            아.. 아무도 모르네.. 아..

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/010e3f3a4537948591686853adfdb5e7.jpeg?w=1200&q=90]

            뭐 이쁘게 나올걸 기대를 하진 않았는데

            신스킨이 무슨 이덕화같이생겨서 그날의 충격이 안잊혀지네요ㅎㅎ

            충격을 중화하려고 그린건가

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/56/ce6d9613301160957d79419c5ebe93e9.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/31/7aa5394beaa2c6137294d554f0ce3021.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/e8ca9c99f0a291f7cca37f59e8a04504.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/0e911b2491ce79cfc34263ab8fa7f321.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/c0580a3afab3afec14a92a442e450cf0.png?w=1200&q=90]

            게임하면서 극대노할때마다 갑자기 슥슥 그리고

            다시 게임하러가고 < 이짓을 몇번을햇어서.. 그중 하나인듯

            저 한창 할때에는 플래면 상위8퍼라고 들었었거든요 그래서 플래따고 욜~이정도면멋있지~ 하고 관뒀었는데

            랭크 초기화됏는지 최근에 들어가서 리플레이보니까 브론즈꺼보여주던데

            이..이런....!!!!!!!!!!!다신안해.......!!!!!!!!!ㅋ

            그리고 진짜 웃긴게 컴퓨터 진짜비싸게맞췄는디

            컴퓨터가 너무 사랑스러운나머지 집에서 쓰질 못했어요 게임은 피씨방가서했습니다.

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/79bb9f544cb774f81b3a84a74c47ee82.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/670767285f24d8ffdf5757cc47737f7a.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/46840ea027bf7777c67a60daacc64898.png?w=1200&q=90]

            근데 꾸준히 jp켄 좋다고생각했는데 뭐 이리저리검색해봐도 하나도안나와서

            아니 이거 약간그.. 리*북스개아가공x지랄수이런느낌아녀? 메이저한취향이라고 생각하는데요? 했는데 생각해보니 메이저인지마이너인지 판단은 제가 하는게 아니죠? 제가 내릴수있는거였으면 지금

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/cd4a852afa856f82320dd1f050779401.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/18/25/4c580ee5f2d33aab223068a9bade3312.png?w=1200&q=90]

            부자친구가 사준 터치펜내장폰 <- 저는 당연히 갤럭시울트라일거라고생각했는데

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/55/bfd35e46694449ced5f67f1c857bc98b.png?w=1200&q=90]

            근데 휘핑크림이 있으니까 프라푸치노인건가

            ?????

            지금 인간을 만드는데 심장을빼고만들어도되겠습니까 묻는거아녀?

            커피안마시고 1도모르는사람이 그린 티가 나버린것인가?

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/10/7c9fa9dcf632f417bc89e9bc9c623f0c.jpeg?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/1c3f33326013cba06f00e5ae5323f312.jpeg?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/52757da8fa5d65e7fcbc6952cef86339.jpeg?w=1200&q=90]

            지말아저씨가된류...

            게임 성능도 어째 ㅠㅠ

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/18/42/1d9b4caae40ccf95c93268fdf911a588.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/55/7f29bba54885a28b2ea530b8550f9bc9.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/09/e91037a73172fa6c6d96c56f5d17c84b.jpeg?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/68c98094631a94674989619b8df32d15.png?w=1200&q=90]

            곰귀는 어느샌가 붙어있었고

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/00f0b41eabb89a65ebbde399eee44eb1.jpeg?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/d82ae617f59b9603ca903241fe411908.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/a468ef7913e7dec2f52d8db4ed44122b.png?w=1200&q=90]

            글은 위키백과엿나 어디서긁어왔는지 기억이..

            그나저나 더러운마초장르주제에 왜자꾸 키스를부르는초코렛과자랑 콜라보하는건지 그냥 상시로하는수준이던데 ㅠ0

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/55/212187cb36b23bbb7e0efdff3e310801.png?w=1200&q=90]

            이거 아마 난생처음그린 제로켄인가 그럴텐데

            아니 더러운남자를그리는데 이런 아리따운 미인박명헤어를 그려도되는가

            아리따운리본댕기머리를 그려도되는가 고민한 티가 ㅈㄴ 나는

            지금은 양심 잃어서 그냥 .. ㅡ 더했으면더했지

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/57/a3b203463c3239c0cb108f3da6227509.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/10/00/37/bcc816931e1768567d2caa1bbee4fd27.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/ab67a8f2b6e836f5130993631e1bb9f4.png?w=1200&q=90]

            뭔가 시행착오가 많았던 류그리기..

            짧은 머리가 너무 어렵다.. 삼지창 일본호빠st미소년만 사랑했다보니..

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/21/7c45c9d8d9c0413dbfb7ed8bbde004e5.png?w=1200&q=90]

            코 높이, 코끝 날카로운지둥근지

            에 심히 집착하는모습

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/55/4c4186f352b85b6ace1baa2f7a123ec3.jpeg?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/22/39/d34a59fdb61d7e98bbdebb5380159e35.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/03/17/58/f164e245319c5263732eccc86c8a43f6.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/25/73b73893950168bbff9abeee3af2196d.jpeg?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/39/f7bb7fde9c858466d1397827350f3288.png?w=1200&q=90]

            이 장면인듸 ㅎㅎㅎ

            배경이 .. 겨울이신가 ... .. 나무가 저렇게 앙상한줄몰랐는데^^;;;;;;;;;

            제 망상속의 류옵하는 저렇게 배경자체보정이 돼잇엇나봅니다;; 그가지나가는곳엔 아름다운꽃이피고 그가머문곳엔 생명의나무가 자랍니다 새와벌이꼬이고 땅이비옥해지며

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/00/20e95db3b647a55937a29d9c83eee8bc.png?w=1200&q=90]

            완전 초기연성

            그래서 약간 캐해석에 때묻지않은느낌이...

            지금은 타락해서 남자아이버전만그리거든요 이런나이대는 보면 할아버지같습니다

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/25/24105c83720d5e7b38714140b9419c2d.png?w=1200&q=90]

            이그림 뭔 만화관계자분이나 뭔가 알법한 .. 그런분들이 자꾸 훨래날래 퍼뜨려가지고

            쪽팔려서 samang할뻔 아니 욕망 개때려박은그림인데이거.. 슴가크기차이 손목발목굵기차이그리려고 그렸슴ㅠㅠㅠ 그만퍼뜌려

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/25/59f5e836312750b402ab1216385f9dbe.png?w=1200&q=90]

            만화그리고하다보니 궁금한게 얘네 생활수준이 어땠는지 몰라서

            전기가스수도는 ... 썼...나,...?????? 물 길어다쓴거보면 아닌가..?

            진짜 밤되면 컴컴해져서 촛불랜턴들고다녔던수준인가???

            근데 강덕사 (류켄살던데말고 고우켄 고우키 살던데) 설정화를 봤었는데 가스렌지 쓰더라고요

            근데 공식만화같은데서 류캔 장작패는씬이 몇번 나오던데 강덕사는 딴집이라 상관없고 얘네는 진짜 아궁이로 죽끓여먹는수준이었나??????가스렌지안쓰나??

            근데 또 서양 미디어믹스 (실사판영화같은거) 보면 가스렌지를넘어 얘네 세탁기쓰고 티비보고게임하고있거든요????

            그냥 그리는사람 나름이겠군요...

            개인적으론 완전 원시생활은아니고 전기가스까지는 썼을거같은? 티비는 있는데 안나왔음좋겠어요 (시골 특.티비왜있는지모름,위에뭐잔뜩쌓여있음) 스승님이 고치기귀찮아해서

            아무튼 그래서 식재는 기본적으론 자급자족하나 가끔 멀리 장보러갔다오고했음 좋겠음

            저녁에 천장에전구매달아놓은거 땡겨서 켜는데

            근데 사실 전기세아깝고 당시의 전구 개빨리닳고 등등의이유로 촛불랜턴을 더자주쓰고 그런느낌?

            일본은 모기도 별로 없으니 너무 로맨틱한 시골생활.^^

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/26/3974daa81edb865e029a1aaaeb6e86ee.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/25/ffeeaa9789058dd7f917d76f2c5dfb07.png?w=1200&q=90]

            키크다 발크다 어쩌구하고잇는데 별로 안그래보이는이유

            그림 다그려놓고 글만 몇달뒤에 써서 그럼..엌ㅋㅋ

            지금은 고쳤는데 이때쯤에 타블렛이 진짜 맛이가있어서 글도잘못쓰고 그림도 그리는데 시간 한 5배걸렸음

            뚝뚝끊겨갖고 강제로 필압없어짐

            타블렛펜 더블클릭간격? 설정 문제더라고요..

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/01/32/c4f99a0212a1d19c8477872026d523a0.jpeg?w=1200&q=90]

            컴으로그렸다가 아이패드로그렸다가 원본잃어먹어서 불펌따운하고 아무튼 이리저리옮겨다녔더니

            화질이 아주 넝마가됐군요;;;;;;;;;;ㄱ-

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/01/31/00/25/1e68ec345302d2a32390ed594c5442b0.png?w=1200&q=90]

            입만열면 동식물에비유하는 산골소년

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/00/53/96fd53b11b5dca135ece683486420280.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/00/53/dab5c4612e74bbe4b929ce5e29860ab0.png?w=1200&q=90]

            분조장이란걸 자기도 이쯤때 처음알았을듯

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/21/38/18b4be31fe337227e41dd070534ad8b5.png?w=1200&q=90]

            3d판사람 이감성 알텐데 브이 꼭 못하는애가 있어요

            다른멤버가 어떻게 잡아놔도 바로 풀리고 그러는애..

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/15/00/2f5815964b746abc093e1990613e1538.png?w=1200&q=90]

            원래 브이를 더못하는중이었는데

            코딱지파는거같애가지고 고쳐가지고.. 좀 잘하게돼버렸군

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/18/33/053de136cb57364c980fab70daf028f7.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/23/23/33/289a4e4c7c2a930f2232a9c2f827bf0c.png?w=1200&q=90]

            과연 강해지는법을 가르쳐줬을 것인가?!?!?!!?!!?

            다음 포스팅은 19금으로...

            아이고 그림 올려놔야지 하다가 하다가 지금 포타에 글을안쓴지 약 2년이 지났고..

            싸가지없이 주인이안오는 포타 봐주셨던분들 감사합니다 그새에 구독자가 800명이나 되어있었군요..

            이제 진짜 자주오도록 하겠습니다 글을 짧게짧게 쓰겠습니다

            사실 제가 제 옜날그림 못보겠어서 이 포타 글들을 안 봅니다 답글만달고 부리나케도망치고 그러는데

            웃긴게 "자주오도록하겠습니다" <-이말만큼은 기억난다.. 다른글에서도 말했을것임

            하지만!!!!!!!

            이제 진짜라면 어떨까????? 전설이 시작되려한다..

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/03/14/b74199027c683bb5b66e8a1bb1d5b7b1.png?w=1200&q=90]

            그리고 이 블로그에 대해서...

            지금 글 보고계신 이곳말고 블로그가 하나가 더있을텐데 이게 대체 뭐냐하면

            사실 게임리뷰같은걸 생각해보고 있었어요

            요즘게임들좀 추천받아가지고 신문물좀 경험해보려고

            목적: 틀딱탈출!!!

            근데 어차피 추천받아도 안할거같더라고..

            실제로 몇개 써봤었는데 걍 제가좋아하는거만 쓰고있더라고요 어쩌라는거지 결국 또 나는나와사랑한다찍음 틀딱이면 주제에맞게살자

            아무튼 그러려고 만든 블로그였습니다 한번도쓰지못했지만......

            나중에 일있으면 쓸텐데 뭔일이생길진 모르겠다

            그나저나 알람이 간것도 아닐텐데 저 6명은 어떻게 알고 구독을 하였느냐

            위 6명은 연락 주시면 문화상품권 코드를 저에게 알려주시는 법을 알려드리겠습니다.

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/24/03/49/7d7125d249216b8ac39d7c06f855fc48.jpeg?w=1200&q=90]

            글을 어떻게 끝내야할지 모르겠군.............................

            새해 복 많이 받으세요^^
          EOS
        )
      end

      context "A NSFW Postype post" do
        strategy_should_work(
          "https://rottenmustard.postype.com/post/15534076",
          image_urls: %w[
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/23/19/35/71b8456e7e1b09d4abb1aaa20c68e1b8.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/27/18/34/f8a600d3afc5f1532e266f5e5848642c.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/27/17/59/556347d9784fb62ff60637527a1119c0.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/27/18/29/78f9a62af536866508315c7a331d94e4.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/23/19/39/9d0caf9c7231f7ef3ca8865de08fc39e.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/27/18/06/9a9361dfe67c102d4a2e3af22ca14fdc.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/27/18/06/15a33b9962fb95d6368ae06c023cc0f3.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/23/19/35/71b8456e7e1b09d4abb1aaa20c68e1b8.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/11/10/14/41/5a9d1241dae9d2b3afc26ae83ee1348a.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/22/16/16/18591b8a834172711b58ec461ce3b063.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/02/11/11/529ac3af609fc14cc2d20b6fe2a0624d.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/11/18/54/0fa63596456cb473a45b66f3ea7a993c.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/03/11/15/39/ec5bf8328059bc2fff3fa5d9c5997e30.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/03/24/23/31/111c201da1b34e1b10a9224b3fddbf4a.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/04/10/01/12/c3beaf6cf39540eac3c7f777d04868b1.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/04/10/01/12/9e395efb744332f5a58eb5a02a28c6b2.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/04/16/15/19/a558ad7fb6a7743359ea80e2b6f369cc.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2024/05/02/18/18/1f222c14c268b27e84e898b168f03b4e.png
          ],
          media_files: [
            { file_size: 8_537 },
            { file_size: 2_702_134 },
            { file_size: 971_989 },
            { file_size: 638_984 },
            { file_size: 552_426 },
            { file_size: 7_401_213 },
            { file_size: 5_974_634 },
            { file_size: 8_537 },
            { file_size: 1_206_150 },
            { file_size: 435_371 },
            { file_size: 902_258 },
            { file_size: 2_566_623 },
            { file_size: 1_083_740 },
            { file_size: 417_397 },
            { file_size: 297_318 },
            { file_size: 462_469 },
            { file_size: 566_921 },
            { file_size: 1_631_025 },
          ],
          page_url: "https://www.postype.com/@rottenmustard/post/15534076",
          profile_urls: %w[https://www.postype.com/@rottenmustard https://www.postype.com/profile/@46axcn],
          display_name: "라쿤맨",
          username: "46axcn",
          tags: [
            ["커미션", "https://www.postype.com/search?options_tags=1&keyword=커미션"],
          ],
          dtext_artist_commentary_title: "수위 커미션",
          dtext_artist_commentary_desc: <<~EOS.chomp
            h5. [s]천천히 진행합니다. 오픈카톡으로 와주세요![/s]

            h5. [s](카톡 입장이 가능하다면 커미션 슬롯이 남아있는 것입니다)[/s]

            [s]슬롯:[/s]

            "[s]https://open.kakao.com/o/sLKkfiOf[/s]":[https://open.kakao.com/o/sLKkfiOf]

            (신청 X)

            [hr]

            h4. 타입 설명

            h4. 흑백

            * [b]전신 [/b]6.0
            * [b]반신[/b] 4.0 (허벅지까지)

            h4. 컬러 (깔끔한 셀채색)

            * [b]전신 [/b]12.0
            * [b]반신[/b] 8.0 (허벅지까지)

            h4. 퀄리티업 (반무테 채색)

            * 4.0

            작업 순서: 러프(컨펌) -> 선화(컨펌) -> 완성본 전달(큰 오류 아닐 시 수정 X)

            작업 기간: [b]2개월[/b] (기간 초과시 전액 환불 & 완성본까지 드립니다)

            샘플: 채색스타일 확인용

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/23/19/35/71b8456e7e1b09d4abb1aaa20c68e1b8.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/27/18/34/f8a600d3afc5f1532e266f5e5848642c.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/27/17/59/556347d9784fb62ff60637527a1119c0.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/27/18/29/78f9a62af536866508315c7a331d94e4.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/23/19/39/9d0caf9c7231f7ef3ca8865de08fc39e.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/27/18/06/9a9361dfe67c102d4a2e3af22ca14fdc.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/27/18/06/15a33b9962fb95d6368ae06c023cc0f3.png?w=1200&q=90]

            [hr]

            h4. [b]주의사항[/b]

            * 오로지 근육떡대남만 그립니다. (정말 자신이 없어요!!: 여캐x, 마른체형x, 중년x)
            * 2인 구도 어려워해요.... (ㅠㅠ 정말 노력합니다... 결과물이 어떻게 나올진 장담 못합니다... 구도가 어려우면 거절할 수도 있습니다.) 1인 신청 권장드립니다.. (이메레스를 주시거나 구도 자료가 자세하면 괜찮아요!)
            * [b]자신있는요소: 근육떡대감자왕가슴남. 인외공. 촉수.[/b]
            * 선호소재: 모브(인원추가로 안칩니다), 야시시한 옷, 촉수, 구속, 오모라시, 본디지...etc
            * 작업불가소재: 스카톨로지(큰 거.), 너무 고어틱한 소재 etc
            * [b]작업불가장르: 헤타리아, 림버스컴퍼니(프문 장르), 원신[/b]
            * [b][u]작품은 한국식으로 검열되어 전달드립니다. (성기, 항문이 보이지 않는 흰색 광선)[/u][/b]

            [hr]

            h4. 신청서 양식

            * 닉네임:
            * 메일주소: (모든 작업과정/완성본은 메일로 전달드립니다.)
            * 원하는 커미션 타입: 흑백/컬러 전신/반신
            * 캐릭터 자료: (채팅으로 여러 장 보내시면 자료 관리가 어렵습니다. 에버노트와 같은 외부링크를 활용해주시거나 1~2장으로 정돈해서 보내주세요!)
            * 구도/소재: (오마카세 불가능합니다. 꼭 말씀주세요!!!)
            * 기타: (빠지면 안되는 주요사항. 불호소재. etc)

            [hr]

            실제 작업물

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/23/19/35/71b8456e7e1b09d4abb1aaa20c68e1b8.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/11/10/14/41/5a9d1241dae9d2b3afc26ae83ee1348a.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/22/16/16/18591b8a834172711b58ec461ce3b063.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/02/11/11/529ac3af609fc14cc2d20b6fe2a0624d.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/11/18/54/0fa63596456cb473a45b66f3ea7a993c.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/03/11/15/39/ec5bf8328059bc2fff3fa5d9c5997e30.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/03/24/23/31/111c201da1b34e1b10a9224b3fddbf4a.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/04/10/01/12/c3beaf6cf39540eac3c7f777d04868b1.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/04/10/01/12/9e395efb744332f5a58eb5a02a28c6b2.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/04/16/15/19/a558ad7fb6a7743359ea80e2b6f369cc.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/05/02/18/18/1f222c14c268b27e84e898b168f03b4e.png?w=1200&q=90]
          EOS
        )
      end

      context "A Postype post with tiled and seamless images in the commentary" do
        strategy_should_work(
          "https://jadedrop.postype.com/post/11998130",
          image_urls: %w[
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/33/077029c711213e7524f7927322f66277.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/df47fd9d45f9e1fdb58aabdf352d80ae.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/30/8392d8323ef6637dceb7ad7de815cbc5.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/b1f9786b1ee3027bde61491b92cc0d0c.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/b371804dd7c3c6f9ccc3f3971b52fe9a.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/3d4db53c95bdbf7ac37c7d32b8d139db.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/bfc2430f0b31cbacb69cb7e7b9309f06.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/5ef2781a4b5367e52e097963b4e05433.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/29332e53cdfb7bf8f0fd7bcb5142ab12.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/2254527a872594bfa013b9092168ec1f.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/4f30d229f160b4e5b8fa6eda687c7351.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/d87ab95f08de5a4d3bdfcd72b73562e6.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/efa4864c16b310e73f560a9af9c02d9f.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/59/1fb9da2d9d019bb6a0fb80a5edad5cb6.png
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/54/afbbb2867ce5b30bf3097fd2d9e4f8f0.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/0a9986458989718fb8517eb94c86d0a6.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/2f8b143e81e41d343add835345aafeee.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/4f415e25cdd70b2ccf50f89e486d3db5.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/d1808df413422e9d6e52569be147468c.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/c9489b45ae8f113c138438be88d34e15.jpeg
          ],
          media_files: [
            { file_size: 798_408 },
            { file_size: 670_843 },
            { file_size: 790_655 },
            { file_size: 677_264 },
            { file_size: 472_194 },
            { file_size: 718_609 },
            { file_size: 3_184_670 },
            { file_size: 2_981_272 },
            { file_size: 1_492_243 },
            { file_size: 689_180 },
            { file_size: 180_642 },
            { file_size: 10_788_922 },
            { file_size: 10_696_685 },
            { file_size: 10_423_375 },
            { file_size: 1_685_449 },
            { file_size: 874_152 },
            { file_size: 846_948 },
            { file_size: 1_658_547 },
            { file_size: 1_168_028 },
            { file_size: 1_559_593 },
          ],
          page_url: "https://www.postype.com/@jadedrop/post/11998130",
          profile_urls: %w[https://www.postype.com/@jadedrop https://www.postype.com/profile/@gbv1wt],
          display_name: "제이드",
          username: "gbv1wt",
          tags: [
            ["도로헤도로", "https://www.postype.com/search?options_tags=1&keyword=도로헤도로"],
            ["팬창작", "https://www.postype.com/search?options_tags=1&keyword=팬창작"],
          ],
          dtext_artist_commentary_title: "도로헤도로 로그 모음 - 6",
          dtext_artist_commentary_desc: <<~EOS.chomp
            제대로 그린 게 없음 주의

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/33/077029c711213e7524f7927322f66277.png?w=1200&q=90]
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/df47fd9d45f9e1fdb58aabdf352d80ae.png?w=1200&q=90]
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/30/8392d8323ef6637dceb7ad7de815cbc5.png?w=1200&q=90]
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/b1f9786b1ee3027bde61491b92cc0d0c.png?w=1200&q=90]

            도로헤도로 스케치북 초기 설정 AU

            카이(械)와 그 파트너 리스(Lis)... 혼파망 n각관계 돼버리는 십자눈... 은 농담이고 사이좋은 살인집단임.

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/b371804dd7c3c6f9ccc3f3971b52fe9a.png?w=1200&q=90]
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/3d4db53c95bdbf7ac37c7d32b8d139db.png?w=1200&q=90]

            벨툰 구룡특급 마작씬 패러디로 카이도쿠

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/bfc2430f0b31cbacb69cb7e7b9309f06.png?w=1200&q=90]
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/5ef2781a4b5367e52e097963b4e05433.png?w=1200&q=90]

            손길

            노이신 성격 나오는 스킨쉽 그리고 싶었음

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/29332e53cdfb7bf8f0fd7bcb5142ab12.png?w=1200&q=90]

            아이카와랑 리스 행복하게 뽀뽀하고 웃는 거 보고싶어서

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/2254527a872594bfa013b9092168ec1f.png?w=1200&q=90]

            Some kind of education

            어린 도쿠가를 처음으로 마법사 사냥에 데리고 나간 날

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/4f30d229f160b4e5b8fa6eda687c7351.png?w=1200&q=90]

            letting go

            카이를 졸업하는 도쿠가

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/d87ab95f08de5a4d3bdfcd72b73562e6.png?w=1200&q=90]

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/efa4864c16b310e73f560a9af9c02d9f.png?w=1200&q=90]

            The destruction

            고어와 섹시가 공존하는 카이

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/59/1fb9da2d9d019bb6a0fb80a5edad5cb6.png?w=1200&q=90]

            The (self) destruction

            카이에 대한 내 캐해석. 언젠간 완성하겠지

            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/54/afbbb2867ce5b30bf3097fd2d9e4f8f0.jpeg?w=1200&q=90]
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/0a9986458989718fb8517eb94c86d0a6.jpeg?w=1200&q=90]
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/2f8b143e81e41d343add835345aafeee.jpeg?w=1200&q=90]
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/4f415e25cdd70b2ccf50f89e486d3db5.jpeg?w=1200&q=90]
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/d1808df413422e9d6e52569be147468c.jpeg?w=1200&q=90]
            "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/c9489b45ae8f113c138438be88d34e15.jpeg?w=1200&q=90]

            손그림 낙서

            그리고 싶은 동인지는 많고 내 몸은 하나뿐임
          EOS
        )
      end

      context "A Postype post with images but no text in the commentary" do
        strategy_should_work(
          "https://ansdj8181.postype.com/post/15493366",
          image_urls: %w[
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/6486472d8fb33260fda91f57a543a3d1.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/d8d1805775f5de2337c686951543d8ad.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/73f44ae2fdb96f7bd2c58dd56ea42559.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/ed587778cc9e70802f8f731203c326d9.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/cc1d2ad2c5c32f7f0719863620b0810a.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/ea37a663dd8fdbe1838afdb9253f890e.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/17/00/34/1b37c5349372bb2694b58dae489a937e.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/14/45/2e8b6191827e6c18d4461c62cc79d9ec.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/3609f03cfdac44b6edeb32c15fb77214.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/e83c4f621f0aca0d1d274e591d719160.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/92d68223de97aa48aac4d26f8f4b5832.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/457be792f81e5f4d9d29793c6030c593.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/6fee38ed54d7e91c77f5eed2079f5fc3.jpeg
            https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/16/13/27/cf11aa9cce528a582336aacf5bdff0a1.jpeg
          ],
          media_files: [
            { file_size: 746_115 },
            { file_size: 677_171 },
            { file_size: 739_227 },
            { file_size: 812_278 },
            { file_size: 797_612 },
            { file_size: 898_144 },
            { file_size: 760_613 },
            { file_size: 822_691 },
            { file_size: 705_406 },
            { file_size: 751_220 },
            { file_size: 504_816 },
            { file_size: 731_975 },
            { file_size: 752_746 },
            { file_size: 118_919 },
          ],
          page_url: "https://www.postype.com/@ansdj8181/post/15493366",
          profile_urls: %w[https://www.postype.com/@ansdj8181 https://www.postype.com/profile/@53g0ab],
          display_name: "박펩",
          username: "53g0ab",
          tags: [],
          dtext_artist_commentary_title: "[소요타키]",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A membership-only Postype post" do
        strategy_should_work(
          "https://bbunny-backstreet.postype.com/post/12206917",
          image_urls: [],
          page_url: "https://www.postype.com/@bbunny-backstreet/post/12206917",
          profile_urls: %w[https://www.postype.com/@bbunny-backstreet https://www.postype.com/profile/@5faubu],
          display_name: "Bbunny",
          username: "5faubu",
          tags: [],
          dtext_artist_commentary_title: "작년에 왔던 오타쿠 죽지도 않고 또왔소",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent Postype post" do
        strategy_should_work(
          "https://somebody.postype.com/post/999999999999",
          image_urls: [],
          page_url: "https://www.postype.com/@somebody/post/999999999999",
          profile_urls: %w[https://www.postype.com/@somebody],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "parse Postype URLs correctly" do
        assert(Source::URL.image_url?("https://d3mcojo3jv0dbr.cloudfront.net/2021/03/19/20/57/7e8c74bfe4a77f6a037ed8b02194955c.webp?w=240&h=180&q=65"))
        assert(Source::URL.image_url?("https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg"))
        assert(Source::URL.image_url?("https://i.postype.com/2017/01/27/01/28/22c423dd569a1c2aaec66bc551c54d5b.png?w=1000"))
        assert(Source::URL.image_url?("https://c3.postype.com/2017/07/04/21/29/42fc32581770dd593788cce89652f757.png"))
        assert(Source::URL.image_url?("https://www.postype.com/_next/image?url=https%3A%2F%2Fd3mcojo3jv0dbr.cloudfront.net%2F2024%2F04%2F03%2F12%2F46%2F1ffb36f1881b16a5c5881fc6eaa06179.jpeg%3Fw%3D1000%26h%3D700%26q%3D65&w=3840&q=75"))

        assert(Source::URL.page_url?("https://luland.postype.com/post/11659399"))
        assert(Source::URL.page_url?("https://www.postype.com/@fruitsnoir/post/5316533"))

        assert(Source::URL.profile_url?("https://luland.postype.com"))
        assert(Source::URL.profile_url?("https://luland.postype.com/posts"))
        assert(Source::URL.profile_url?("https://www.postype.com/profile/@ep58bc"))
        assert(Source::URL.profile_url?("https://www.postype.com/profile/@ep58bc/posts"))
        assert(Source::URL.profile_url?("https://www.postype.com/@fruitsnoir"))
        assert(Source::URL.profile_url?("https://www.postype.com/@fruitsnoir/post"))
      end
    end
  end
end
