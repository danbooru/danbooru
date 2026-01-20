require "test_helper"

module Source::Tests::Extractor
  class PostypeExtractorTest < ActiveSupport::ExtractorTestCase
    context "A https://www.postype.com/_next/image URL" do
      strategy_should_work(
        "https://www.postype.com/_next/image?url=https%3A%2F%2Fd3mcojo3jv0dbr.cloudfront.net%2F2024%2F04%2F03%2F12%2F46%2F1ffb36f1881b16a5c5881fc6eaa06179.jpeg%3Fw%3D1000%26h%3D700%26q%3D65&w=3840&q=75",
        image_urls: %w[https://d3mcojo3jv0dbr.cloudfront.net/2024/04/03/12/46/1ffb36f1881b16a5c5881fc6eaa06179.jpeg],
        media_files: [{ file_size: 35_970 }],
        page_url: nil,
      )
    end

    context "A Postype sample image URL" do
      strategy_should_work(
        "https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg?w=1200&q=90",
        image_urls: %w[https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg],
        media_files: [{ file_size: 791_613 }],
        page_url: nil,
      )
    end

    context "A Postype full image URL" do
      strategy_should_work(
        "https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg",
        image_urls: %w[https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg],
        media_files: [{ file_size: 791_613 }],
        page_url: nil,
      )
    end

    context "A NSFW Postype post" do
      setup do
        skip "NSFW posts require account identify verification (through credit card, ID card, etc)"
      end

      strategy_should_work(
        "https://rottenmustard.postype.com/post/15534076",
        image_urls: %w[
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
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/03/09/17/50/9d877e10134619106926672042.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/03/28/02/22/a73b75637499276956841083.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/03/28/02/22/530d5c14702127082872520822.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/04/14/20/43/2794fb8368572809054138769.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/04/25/00/29/63a66217972697968418083295.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/04/27/20/45/75ec3915095232435142738584.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/04/27/20/45/07f72417152836831668158350.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/04/27/20/45/d93da214214883177591385839.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/05/10/23/00/e0495910488976549975147777.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/05/10/23/00/95d9e88921357639619368656.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/05/12/15/00/38fb5b8972115121705918853.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/05/28/01/39/3e98433563532317057209358.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/06/05/00/01/52d1ec13725900644314259440.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/07/07/23/57/12ed6a275744369663735498.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2025/07/07/23/57/de8cb66353441080547094378.png
        ],
        media_files: [
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
          { file_size: 1_357_795 },
          { file_size: 2_278_703 },
          { file_size: 3_418_023 },
          { file_size: 3_855_443 },
          { file_size: 3_780_100 },
          { file_size: 1_326_900 },
          { file_size: 2_500_660 },
          { file_size: 2_502_081 },
          { file_size: 1_737_186 },
          { file_size: 1_056_481 },
          { file_size: 1_284_638 },
          { file_size: 1_461_479 },
          { file_size: 1_138_476 },
          { file_size: 717_037 },
          { file_size: 777_858 },
        ],
        page_url: "https://www.postype.com/@rottenmustard/post/15534076",
        profile_urls: %w[https://www.postype.com/@rottenmustard https://www.postype.com/profile/@46axcn],
        display_name: "라쿤맨",
        username: "46axcn",
        tags: [
          ["커미션", "https://www.postype.com/search?options_tags=1&keyword=커미션"],
        ],
        dtext_artist_commentary_title: "수위 커미션",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h5. 천천히 진행합니다. 오픈카톡으로 와주세요!

          h5. (카톡 입장이 가능하다면 커미션 슬롯이 남아있는 것입니다)

          "[s]https://open.kakao.com/o/sLKkfiOf[/s]":[https://open.kakao.com/o/sLKkfiOf]

          [u]For foreigner: Paypal Commission OK!-> come to my mail, rac000000n818@gmail.com[/u]

          [hr]

          h4. 타입 설명

          h4. 흑백타입

          * [b]반신[/b] 6.0 (허벅지까지)
          * [b]전신[/b] 8.0

          h4. 컬러(깔끔한 셀채색)타입

          * [b]반신[/b] 8.0 (허벅지까지)
          * [b]전신[/b] 12.0

          작업 순서: 구도(컨펌) -> 러프(컨펌) -> 선화(컨펌) -> 완성본 전달(큰 오류 아닐 시 수정 X)

          작업 기간: 1[b]개월[/b] (기간 초과시 전액 환불 & 완성본까지 드립니다.)

          [hr]

          h4. [b]주의사항[/b]

          * 오로지 [b]근육떡대남[/b]만 그립니다. (정말 자신이 없어요!!: 여캐x, 마른체형x, 중년x)
          * 2인 구도 어려워해요.... (노력합니다... 결과물이 어떻게 나올진 장담 못합니다... 구도가 어려우면 거절할 수도 있습니다.) [b][u]1인 신청 권장[/u]드립니다!!![/b]
          * [b]자신있는요소: [u]근육떡대감자왕가슴남. 인외공. 촉수.[/u][/b]
          * 선호소재: 모브(인원추가로 안칩니다. 명암묘사 생락/신체 일부만 나옵니다), 야시시한 옷, 촉수, 구속, 오모라시, 수간, 본디지...etc
          * 작업불가소재: 스카톨로지(브라운), 너무 고어틱한 소재 etc (보고 거절할 수 있습니다)
          * [b]작업불가장르: 헤타리아, 림버스컴퍼니(or 프문 장르), 원신[/b]

          [hr]

          h4. 신청서 양식

          * 닉네임:
          * 메일주소: [u](모든 작업과정/완성본은 [b]메일[/b]로 전달드립니다.)[/u]
          * 원하는 커미션 타입: 흑백/컬러 전신/반신
          * 캐릭터 자료: (채팅으로 여러 장 보내시면 자료 관리가 어렵습니다. 에버노트와 같은 외부링크를 활용해주시거나 1~2장으로 정돈해서 보내주세요!)
          * 구도/소재: ([b][u]오마카세 불가능[/u][/b]합니다. 꼭 말씀주세요!!!!!!!!!)
          * 기타: (빠지면 안되는 주요사항. 불호소재. etc)

          [hr]

          실제 작업물 (마지막이 가장 최근 작업물입니다)

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/10/23/19/35/71b8456e7e1b09d4abb1aaa20c68e1b8.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/11/10/14/41/5a9d1241dae9d2b3afc26ae83ee1348a.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2023/12/22/16/16/18591b8a834172711b58ec461ce3b063.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/02/11/11/529ac3af609fc14cc2d20b6fe2a0624d.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/02/11/18/54/0fa63596456cb473a45b66f3ea7a993c.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/03/11/15/39/ec5bf8328059bc2fff3fa5d9c5997e30.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/03/24/23/31/111c201da1b34e1b10a9224b3fddbf4a.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/04/10/01/12/c3beaf6cf39540eac3c7f777d04868b1.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/04/10/01/12/9e395efb744332f5a58eb5a02a28c6b2.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/04/16/15/19/a558ad7fb6a7743359ea80e2b6f369cc.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2024/05/02/18/18/1f222c14c268b27e84e898b168f03b4e.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/03/09/17/50/9d877e10134619106926672042.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/03/28/02/22/a73b75637499276956841083.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/03/28/02/22/530d5c14702127082872520822.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/04/14/20/43/2794fb8368572809054138769.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/04/25/00/29/63a66217972697968418083295.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/04/27/20/45/75ec3915095232435142738584.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/04/27/20/45/07f72417152836831668158350.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/04/27/20/45/d93da214214883177591385839.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/05/10/23/00/e0495910488976549975147777.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/05/10/23/00/95d9e88921357639619368656.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/05/12/15/00/38fb5b8972115121705918853.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/05/28/01/39/3e98433563532317057209358.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/06/05/00/01/52d1ec13725900644314259440.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/07/07/23/57/12ed6a275744369663735498.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2025/07/07/23/57/de8cb66353441080547094378.png?w=1000&q=90]
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
          제대로 그린 게 없음 주의

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/33/077029c711213e7524f7927322f66277.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/df47fd9d45f9e1fdb58aabdf352d80ae.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/30/8392d8323ef6637dceb7ad7de815cbc5.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/b1f9786b1ee3027bde61491b92cc0d0c.png?w=1000&q=90]

          도로헤도로 스케치북 초기 설정 AU

          카이(械)와 그 파트너 리스(Lis)... 혼파망 n각관계 돼버리는 십자눈... 은 농담이고 사이좋은 살인집단임.

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/b371804dd7c3c6f9ccc3f3971b52fe9a.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/3d4db53c95bdbf7ac37c7d32b8d139db.png?w=1000&q=90]

          벨툰 구룡특급 마작씬 패러디로 카이도쿠

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/bfc2430f0b31cbacb69cb7e7b9309f06.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/5ef2781a4b5367e52e097963b4e05433.png?w=1000&q=90]

          손길

          노이신 성격 나오는 스킨쉽 그리고 싶었음

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/29332e53cdfb7bf8f0fd7bcb5142ab12.png?w=1000&q=90]

          아이카와랑 리스 행복하게 뽀뽀하고 웃는 거 보고싶어서

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/2254527a872594bfa013b9092168ec1f.png?w=1000&q=90]

          Some kind of education

          어린 도쿠가를 처음으로 마법사 사냥에 데리고 나간 날

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/4f30d229f160b4e5b8fa6eda687c7351.png?w=1000&q=90]

          letting go

          카이를 졸업하는 도쿠가

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/32/d87ab95f08de5a4d3bdfcd72b73562e6.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/31/efa4864c16b310e73f560a9af9c02d9f.png?w=1000&q=90]

          The destruction

          고어와 섹시가 공존하는 카이

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/59/1fb9da2d9d019bb6a0fb80a5edad5cb6.png?w=1000&q=90]

          The (self) destruction

          카이에 대한 내 캐해석. 언젠간 완성하겠지

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/54/afbbb2867ce5b30bf3097fd2d9e4f8f0.jpeg?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/0a9986458989718fb8517eb94c86d0a6.jpeg?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/2f8b143e81e41d343add835345aafeee.jpeg?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/4f415e25cdd70b2ccf50f89e486d3db5.jpeg?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/d1808df413422e9d6e52569be147468c.jpeg?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2022/03/08/15/55/c9489b45ae8f113c138438be88d34e15.jpeg?w=1000&q=90]

          손그림 낙서

          그리고 싶은 동인지는 많고 내 몸은 하나뿐임
        EOS
      )
    end

    context "A membership-only Postype post" do
      setup do
        skip "Dead post (site returns 404, but somehow the API still returns the data for it)"
      end

      strategy_should_work(
        "https://bbunny-backstreet.postype.com/post/12206917",
        image_urls: [],
        page_url: "https://www.postype.com/@bbunny-backstreet/post/12206917",
        profile_urls: %w[https://www.postype.com/@bbunny-backstreet https://www.postype.com/profile/@5faubu],
        display_name: "Bbunny",
        username: "5faubu",
        tags: [],
        dtext_artist_commentary_title: "작년에 왔던 오타쿠 죽지도 않고 또왔소",
        dtext_artist_commentary_desc: "",
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
        dtext_artist_commentary_desc: "",
      )
    end

    context "A postype post that serves its post in the HTML instead of through the API" do
      strategy_should_work(
        "https://www.postype.com/@dee0333/post/21240419",
        image_urls: %w[
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5d676f9205003800853333836.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/bf05453059490499072801227.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/c1a5972803568042567577717.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/8b0a5514936462684914880471.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/9a10736130216340467151772.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/df5d5816132894801814460209.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/22c97511183884864368644428.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/76e31411577777109560769590.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5b78657737676069690242566.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/0bda0b14895777495322847499.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/150a4516235364462117802833.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/53/bdd2fa3656629026265025076.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/c0152618209834826960521934.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/4f05125857667830933940585.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/a6ec13160853042411331169.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/6def661314198191916060743.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/b3a9c52308302091571151601.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/e9e74c12074798393712918128.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/1d4bea4739245817937683535.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/f4008718390479838510330170.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/d8f6441460686102107705462.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/f80d6617191634823588508841.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/f4d0fb43350389637097486.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/61f29a13670159542600021062.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/8d50009380403814831780507.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/d057365267138400933624600.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/a8dbad14929995910269851732.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/63b31512048415981828913549.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/7f1d538939057677937293114.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/241e3014095096192182485743.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/ff2c005930992030866925878.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/ddcfab10068629775321007337.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/3b7d8f3914567307283462382.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/80d9a917464201660912052956.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/85a4c43403554726719475003.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5b61389641080112715054665.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/ab21024180409934747388811.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/021d0211575434844295329517.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/08592c16269976830254400390.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5713e74715419096360541500.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/f7788113986900470311121009.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/41c55b6329562134771406939.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/bc186415317843859070393781.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/421b2010201511825580564162.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/2a11f79059825630691962003.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/c0549a6607168383106089443.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/ad317315836806708929156021.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/f9b29e9703955577132781002.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/e5637d17076563425606731415.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/bafdd014616010246730711387.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/c3d96014329310299866821207.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/61ce2c9157975924198830047.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/893be013476245814984452460.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/56733915086737343677321880.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/85996917447623298468215107.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/b4ca57373693399375576236.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/edb8ab9322691308046683024.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/b08a4f1953700926406073764.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/0c4a5615597697701417134084.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/56c1bd6007558799874275532.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/75c6622219206826893527498.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/109e8c12171097850604911167.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/2e02338953158507891923616.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5b9b3d18255484441826261736.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/c7cdd38370677112280903331.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5ce64f16253538787881974378.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/540f2f7978543330041953645.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/e60fb38214773727219650943.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/64a4bd9279197040462329290.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/2d0d0c16864969355762208892.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/0458c36832008878100473098.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/8f113911782978306964447345.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/faac9414029800665941261349.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/d36b202148572249779565076.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/bbd2684396745863201278609.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/4d67ea2817556500276650054.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/25ffff10208977593828398521.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/d893bd3817887640630639468.png
        ],
        media_files: [
          { file_size: 864_847 },
          { file_size: 818_767 },
          { file_size: 993_106 },
          { file_size: 2_473_776 },
          { file_size: 664_036 },
          { file_size: 2_016_872 },
          { file_size: 536_788 },
          { file_size: 3_302_941 },
          { file_size: 4_714_039 },
          { file_size: 1_390_235 },
          { file_size: 623_393 },
          { file_size: 718_641 },
          { file_size: 1_079_246 },
          { file_size: 1_019_261 },
          { file_size: 2_526_304 },
          { file_size: 5_715_338 },
          { file_size: 3_188_850 },
          { file_size: 915_483 },
          { file_size: 1_731_932 },
          { file_size: 396_868 },
          { file_size: 2_735_407 },
          { file_size: 770_709 },
          { file_size: 4_012_139 },
          { file_size: 851_330 },
          { file_size: 1_493_173 },
          { file_size: 1_493_113 },
          { file_size: 949_750 },
          { file_size: 1_426_024 },
          { file_size: 673_547 },
          { file_size: 3_514_166 },
          { file_size: 1_108_996 },
          { file_size: 3_152_719 },
          { file_size: 1_649_736 },
          { file_size: 1_331_690 },
          { file_size: 7_142_238 },
          { file_size: 2_288_800 },
          { file_size: 2_807_790 },
          { file_size: 1_925_632 },
          { file_size: 2_199_406 },
          { file_size: 1_413_653 },
          { file_size: 537_480 },
          { file_size: 773_439 },
          { file_size: 4_241_640 },
          { file_size: 2_636_432 },
          { file_size: 1_778_967 },
          { file_size: 1_165_971 },
          { file_size: 3_914_368 },
          { file_size: 2_226_971 },
          { file_size: 3_273_676 },
          { file_size: 1_444_548 },
          { file_size: 2_103_957 },
          { file_size: 1_496_402 },
          { file_size: 199_275 },
          { file_size: 1_800_541 },
          { file_size: 1_387_112 },
          { file_size: 1_660_111 },
          { file_size: 3_086_679 },
          { file_size: 1_592_738 },
          { file_size: 723_807 },
          { file_size: 79_966 },
          { file_size: 1_002_567 },
          { file_size: 2_635_709 },
          { file_size: 805_098 },
          { file_size: 249_828 },
          { file_size: 1_748_302 },
          { file_size: 328_672 },
          { file_size: 1_815_996 },
          { file_size: 1_164_703 },
          { file_size: 357_667 },
          { file_size: 3_255_302 },
          { file_size: 1_527_902 },
          { file_size: 1_516_941 },
          { file_size: 414_190 },
          { file_size: 2_125_804 },
          { file_size: 268_928 },
          { file_size: 284_621 },
          { file_size: 1_815_909 },
          { file_size: 789_692 },
        ],
        page_url: "https://www.postype.com/@dee0333/post/21240419",
        profile_urls: %w[https://www.postype.com/@dee0333 https://www.postype.com/profile/@17hzi5],
        display_name: "ㄷ1",
        username: "17hzi5",
        tags: [
          ["레뷰", "https://www.postype.com/search?options_tags=1&keyword=레뷰"],
          ["레뷰스타", "https://www.postype.com/search?options_tags=1&keyword=레뷰스타"],
          ["스타리라", "https://www.postype.com/search?options_tags=1&keyword=스타리라"],
        ],
        dtext_artist_commentary_title: "레뷰 로그_2025_1",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          순서 대체로 시간순

          커플링 표기 없음

          민감한 소재 있을 수 있음

          정리 할 자신 없음

          감당할 수 있는 분만 여세요

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5d676f9205003800853333836.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/bf05453059490499072801227.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/c1a5972803568042567577717.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/8b0a5514936462684914880471.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/9a10736130216340467151772.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/df5d5816132894801814460209.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/22c97511183884864368644428.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/76e31411577777109560769590.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5b78657737676069690242566.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/0bda0b14895777495322847499.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/150a4516235364462117802833.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/53/bdd2fa3656629026265025076.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/c0152618209834826960521934.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/4f05125857667830933940585.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/a6ec13160853042411331169.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/6def661314198191916060743.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/b3a9c52308302091571151601.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/e9e74c12074798393712918128.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/1d4bea4739245817937683535.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/f4008718390479838510330170.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/d8f6441460686102107705462.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/f80d6617191634823588508841.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/f4d0fb43350389637097486.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/61f29a13670159542600021062.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/8d50009380403814831780507.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/d057365267138400933624600.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/a8dbad14929995910269851732.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/63b31512048415981828913549.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/7f1d538939057677937293114.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/241e3014095096192182485743.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/ff2c005930992030866925878.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/ddcfab10068629775321007337.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/3b7d8f3914567307283462382.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/80d9a917464201660912052956.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/85a4c43403554726719475003.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5b61389641080112715054665.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/ab21024180409934747388811.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/021d0211575434844295329517.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/08592c16269976830254400390.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5713e74715419096360541500.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/f7788113986900470311121009.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/41c55b6329562134771406939.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/bc186415317843859070393781.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/421b2010201511825580564162.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/2a11f79059825630691962003.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/c0549a6607168383106089443.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/ad317315836806708929156021.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/f9b29e9703955577132781002.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/e5637d17076563425606731415.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/bafdd014616010246730711387.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/c3d96014329310299866821207.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/61ce2c9157975924198830047.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/893be013476245814984452460.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/56733915086737343677321880.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/85996917447623298468215107.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/b4ca57373693399375576236.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/edb8ab9322691308046683024.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/b08a4f1953700926406073764.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/0c4a5615597697701417134084.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/56c1bd6007558799874275532.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/75c6622219206826893527498.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/109e8c12171097850604911167.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/2e02338953158507891923616.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5b9b3d18255484441826261736.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/c7cdd38370677112280903331.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/5ce64f16253538787881974378.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/540f2f7978543330041953645.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/e60fb38214773727219650943.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/64a4bd9279197040462329290.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/2d0d0c16864969355762208892.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/0458c36832008878100473098.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/8f113911782978306964447345.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/faac9414029800665941261349.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/d36b202148572249779565076.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/bbd2684396745863201278609.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/4d67ea2817556500276650054.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/25ffff10208977593828398521.png?w=1000&q=90]
          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/01/01/00/48/d893bd3817887640630639468.png?w=1000&q=90]
        EOS
      )
    end
  end
end
