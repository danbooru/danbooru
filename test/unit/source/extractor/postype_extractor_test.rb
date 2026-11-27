require "test_helper"

module Source::Tests::Extractor
  class PostypeExtractorTest < ActiveSupport::ExtractorTestCase
    context "A https://www.postype.com/_next/image URL" do
      strategy_should_work(
        "https://www.postype.com/_next/image?url=https%3A%2F%2Fd3mcojo3jv0dbr.cloudfront.net%2F2024%2F04%2F03%2F12%2F46%2F1ffb36f1881b16a5c5881fc6eaa06179.jpeg%3Fw%3D1000%26h%3D700%26q%3D65&w=3840&q=75",
        image_urls: %w[https://d3mcojo3jv0dbr.cloudfront.net/2024/04/03/12/46/1ffb36f1881b16a5c5881fc6eaa06179.jpeg],
        media_files: [{ file_size: 35_970 }],
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

    context "A Postype sample image URL" do
      strategy_should_work(
        "https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg?w=1200&q=90",
        image_urls: %w[https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg],
        media_files: [{ file_size: 791_613 }],
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

    context "A Postype full image URL" do
      strategy_should_work(
        "https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg",
        image_urls: %w[https://d2ufj6gm1gtdrc.cloudfront.net/2018/09/10/22/49/e91aea7d82404cdfcb12ecbc99ef856f.jpg],
        media_files: [{ file_size: 791_613 }],
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

    context "A NSFW Postype post" do
      setup { skip "Postype credentials required for NSFW posts" unless SiteCredential.for_site("Postype").present? }

      strategy_should_work(
        "https://www.postype.com/@rottenmustard/post/21814822",
        image_urls: %w[
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/03/08/21/16/e235e93841347773728715340.png
          https://d2ufj6gm1gtdrc.cloudfront.net/2026/03/08/21/16/4f55a514656093801329044156.png
        ],
        media_files: [
          { file_size: 3_393_506 },
          { file_size: 1_470_891 },
        ],
        page_url: "https://www.postype.com/@rottenmustard/post/21814822",
        profile_url: "https://www.postype.com/profile/@46axcn",
        profile_urls: %w[https://www.postype.com/@rottenmustard https://www.postype.com/profile/@46axcn],
        display_name: "라쿤맨",
        username: "46axcn",
        published_at: Time.parse("2026-03-08T12:24:37.000000Z"),
        updated_at: nil,
        tags: [
          ["떡대수", "https://www.postype.com/search?options_tags=1&keyword=떡대수"],
          ["미남수", "https://www.postype.com/search?options_tags=1&keyword=미남수"],
        ],
        dtext_artist_commentary_title: "몬스터의 신부가 되는 일",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          간만에 3페이지 짧그림을 그려왔습니다 ^_^

          근황: 리디북스에 웹툰 런칭했습니다! 궁금하신 분은

          <https://ridibooks.com/books/1632012441?_rdt_sid=keyword_finder_page&_rdt_idx=0>

          "

          h5. 노가다 로맨스 - 리디

          웹툰, 웹소설, 전자책 모두 여기에! 이야기를 즐기는 나만의 공간, RIDI 리디 ":[https://ridibooks.com/books/1632012441?_rdt_sid=keyword_finder_page&_rdt_idx=0]

          이쪽으로...

          주의: 촉수, 실금, 양성구유화, 착유

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/03/08/21/16/e235e93841347773728715340.png?w=1000&q=90]

          "[image]":[https://d2ufj6gm1gtdrc.cloudfront.net/2026/03/08/21/16/4f55a514656093801329044156.png?w=1000&q=90]

          * 텍스트 [b]55[/b]자 [tn]공백 제외[/tn]
          * 이미지 [b]5[/b]장
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
        profile_url: "https://www.postype.com/profile/@gbv1wt",
        profile_urls: %w[https://www.postype.com/@jadedrop https://www.postype.com/profile/@gbv1wt],
        display_name: "제이드",
        username: "gbv1wt",
        published_at: Time.parse("2022-03-08T07:03:37.000000Z"),
        updated_at: nil,
        tags: [
          ["도로헤도로", "https://www.postype.com/search?options_tags=1&keyword=도로헤도로"],
          ["팬창작", "https://www.postype.com/search?options_tags=1&keyword=팬창작"],
        ],
        dtext_artist_commentary_title: "도로헤도로 로그 모음 - 6",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          2021년

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
        profile_url: nil,
        profile_urls: %w[https://www.postype.com/@somebody],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
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
        profile_url: "https://www.postype.com/profile/@17hzi5",
        profile_urls: %w[https://www.postype.com/@dee0333 https://www.postype.com/profile/@17hzi5],
        display_name: "ㄷ1",
        username: "17hzi5",
        published_at: Time.parse("2025-12-31T15:56:36.000000Z"),
        updated_at: nil,
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

    context "The Postype site credential" do
      setup do
        @url = "https://www.postype.com/@rottenmustard/post/21814822"
      end

      should "be marked as valid when the cookie is logged in" do
        skip "Postype credentials not configured" if Danbooru.config.postype_session_cookie.blank?

        credential = create(:site_credential, site: "Postype", credential: { session_cookie: Danbooru.config.postype_session_cookie })
        extractor = Source::Extractor.find(@url)
        extractor.stubs(:site_credentials).returns([credential])

        assert_equal(2, extractor.image_urls.size)
        assert_equal("valid", credential.reload.status)
      end

      should "be marked as expired when the cookie is logged out" do
        credential = create(:site_credential, site: "Postype", credential: { session_cookie: "invalid" })
        extractor = Source::Extractor.find(@url)
        extractor.stubs(:site_credentials).returns([credential])

        assert_equal([], extractor.image_urls)
        assert_equal("expired", credential.reload.status)
      end
    end
  end
end
