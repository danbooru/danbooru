# frozen_string_literal: true

require "test_helper"

module Sources
  class NaverCafeTest < ActiveSupport::TestCase
    context "Naver Cafe:" do
      context "A cafeptthumb-phinf.pstatic.net sample image URL" do
        strategy_should_work(
          "https://cafeptthumb-phinf.pstatic.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png?type=w800",
          image_urls: %w[http://cafefiles.naver.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png],
          media_files: [{ file_size: 898_434 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A cafefiles.pstatic.net full image URL" do
        strategy_should_work(
          "https://cafefiles.pstatic.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png",
          image_urls: %w[http://cafefiles.naver.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png],
          media_files: [{ file_size: 898_434 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "An article with embedded images" do
        strategy_should_work(
          "https://cafe.naver.com/ca-fe/cafes/29314033/articles/28725",
          image_urls: %w[
            http://cafefiles.naver.net/MjAyMzAyMjFfMjc5/MDAxNjc2OTgzOTExNzU5.YYaPrDAzzkhA0VoElNIsI737wctswE-QmnUHainnzkEg.gdLlSp7sNY9my0d8Qg5G_ZL0eKtDdxybQ_kN5M2dIc8g.PNG/공_지_사_항.png
            http://cafefiles.naver.net/MjAyMzAyMjJfMTMg/MDAxNjc3MDMzMjM3Njgy.38c3ZDeVUidpV_C21ocwayyTdL_KgQAbHOksjwMJ4Ogg.Cn9q8PqHJruMosGUE3eDpLAz7JxGNF6aqovBC4GnhaIg.PNG/아미_교관_등장.png
            http://cafefiles.naver.net/MjAyMzAyMjFfMjgy/MDAxNjc2OTg1MDM4MTI1.gzfwZIwpFEQ9WluRXW9pp7AC8DT0LN3Td1UruzQhqU8g.n8eU78CICqSGK_wXiB_F3iIR5oc8dXDsUlfkAc9C4mkg.PNG/KakaoTalk_20230221_215041401.png
          ],
          media_files: [
            { file_size: 168_376 },
            { file_size: 8_532_043 },
            { file_size: 1_649_911 },
          ],
          page_url: "https://cafe.naver.com/ca-fe/cafes/29314033/articles/28725",
          profile_url: "https://cafe.naver.com/ca-fe/cafes/29314033/members/4vIbbomOH8CTZ_G1UeT4VA",
          profile_urls: %w[https://cafe.naver.com/ca-fe/cafes/29314033/members/4vIbbomOH8CTZ_G1UeT4VA https://cafe.naver.com/masterofeternity],
          display_name: "화이트유키s",
          username: "hahazx12",
          tags: [
            ["MOE", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=29314033&search.tagName=MOE"],
            ["2023", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=29314033&search.tagName=2023"],
            ["신규", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=29314033&search.tagName=신규"],
            ["일러스트", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=29314033&search.tagName=일러스트"],
            ["아미", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=29314033&search.tagName=아미"],
            ["교관", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=29314033&search.tagName=교관"],
            ["등장", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=29314033&search.tagName=등장"],
          ],
          dtext_artist_commentary_title: "M.O.E. 2023 신규 일러스트 공개 - 아미 교관 등장!",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[http://cafefiles.naver.net/MjAyMzAyMjFfMjc5/MDAxNjc2OTgzOTExNzU5.YYaPrDAzzkhA0VoElNIsI737wctswE-QmnUHainnzkEg.gdLlSp7sNY9my0d8Qg5G_ZL0eKtDdxybQ_kN5M2dIc8g.PNG/공_지_사_항.png]

            [b]안녕하세요.[/b]

            [b]미소녀X메카닉XSRPG![/b][b]M.O.E. 커뮤니티 카페[/b]

            [b]부 매니저 화이트유키s입니다.[/b]

            [b]2023년 M.O.E. 신규 일러스트 공개![/b]

            "[image]":[https://storep-phinf.pstatic.net/ogq_57f943581ff20/original_16.png]

            [b]이번에 새롭게 공개된 M.O.E. 일러스트의 주제는[/b]

            [b]드디어 일러스트를 통해 등장한 [/b][b]아미[/b][b] 교관과[/b]

            [b]아미의 특훈을 받고 있는 [/b][b]루시[/b][b], [/b][b]로시난테[/b][b], [/b][b]라일라[/b][b]가[/b]

            [b]서로 통신을 주고 받으며 대화를 나누고 있는 모습을 담았습니다.[/b]

            [b]올해도 어김없이 M.O.E.를 사랑해주시는 함장님들을 위해[/b]

            [b]신경써서 소중한 선물 준비해주신 [/b][b]M.O.E.팀 원화가 일동 분들[/b][b]께 진심으로 감사드립니다![/b]

            [b]2023년 M.O.E.의 신규 일러스트 [/b][b]'아미 교관 등장!'[/b]

            [b]함장님들의 많은 관심 부탁드립니다~^^[/b]

            [b]▶ M.O.E. 2023 신규 일러스트 - 아미 교관 등장![/b]

            "[image]":[http://cafefiles.naver.net/MjAyMzAyMjJfMTMg/MDAxNjc3MDMzMjM3Njgy.38c3ZDeVUidpV_C21ocwayyTdL_KgQAbHOksjwMJ4Ogg.Cn9q8PqHJruMosGUE3eDpLAz7JxGNF6aqovBC4GnhaIg.PNG/아미_교관_등장.png]

            [b]▶ 이미지를 클릭하시면 자료실로 이동합니다.[/b]

            [b]아미 : 드디어... 아미 교관 등장...! 출격합니다~![/b]

            [b]루시, 로시난테, 라일라 : 아미 교관님, 올 때 메로ㄴ...! 아, 아니... 잘 다녀오세요.[/b]

            "[image]":[http://cafefiles.naver.net/MjAyMzAyMjFfMjgy/MDAxNjc2OTg1MDM4MTI1.gzfwZIwpFEQ9WluRXW9pp7AC8DT0LN3Td1UruzQhqU8g.n8eU78CICqSGK_wXiB_F3iIR5oc8dXDsUlfkAc9C4mkg.PNG/KakaoTalk_20230221_215041401.png]

            [b]아미 : 뭐?! 다 들었거든! 교관은 너희들에게 실망했다.[/b]

            [b]루시, 로시난테, 라일라 : (머쓱)[/b]
          EOS
        )
      end

      context "An article with images as attachments" do
        strategy_should_work(
          "https://cafe.naver.com/ca-fe/cafes/29767250/articles/785",
          image_urls: %w[
            http://cafefiles.naver.net/MjAyMDA3MDZfMTg4/MDAxNTk0MDA2MjkzNTI5.tux9ktf-odR_xPVnwpBwSveI4Bmew4U9HoKXj0-Vycgg.omzS2hv2ZEegEkUaTZs1UH59xowhrbBUom6XTgP8TSAg.PNG/웹툰타이틀_시즌410.png
            http://cafefiles.naver.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png
            http://cafefiles.naver.net/MjAyMDA3MDZfMjk3/MDAxNTk0MDA2Mjk0Njgw.I2vsONa1Lm22VV-iuBeBYHsgPOlTcnWNduh1-B6bHF4g.cQlEze-0g2M9n93tgltTwkzI--TIDbcixrPDTYPGmnsg.PNG/2.png
            http://cafefiles.naver.net/MjAyMDA3MDZfNyAg/MDAxNTk0MDA2Mjk1MjQ4.TujS8tNWfV0i2cx-IxgGYG-B0snXvZGaJ-F2oJXs3p8g.c8pP5A_HiVxhNhsYox5EMtm-CxAi7MIn8QKqv8eLpy0g.PNG/3.png
            http://cafefiles.naver.net/MjAyMDA3MDZfMTcy/MDAxNTk0MDA2Mjk1Nzgz.IPccwzQNzZaa9YjZcgdRMfIrDeZnvjg-KqlrO-PsJsIg.8CfFtALwcV3gOr3yaHLwOtXmUJSsjcr4HA46MUHEOukg.PNG/4.png
            http://cafefiles.naver.net/MjAyMDA3MDZfMTEw/MDAxNTk0MDA2Mjk2Mzg3.E_JUESXYWNhT5uwzF6kyVRKT8Oa9all_ap3SS4pfWy0g.oN8lcXGpC6QlcsxQn8sKX_2aGX9dmS9LP6q-ecGAJbYg.PNG/5.png
          ],
          media_files: [
            { file_size: 49_364 },
            { file_size: 898_434 },
            { file_size: 663_726 },
            { file_size: 964_938 },
            { file_size: 823_627 },
            { file_size: 820_348 },
          ],
          page_url: "https://cafe.naver.com/ca-fe/cafes/29767250/articles/785",
          profile_url: "https://cafe.naver.com/ca-fe/cafes/29767250/members/hgoxi0a3Zv2O7xQinIz4yw",
          profile_urls: %w[https://cafe.naver.com/ca-fe/cafes/29767250/members/hgoxi0a3Zv2O7xQinIz4yw https://cafe.naver.com/nexonmoe],
          display_name: "GM 크리스틴",
          username: "hahazxy123",
          tags: [
            ["MOE", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=29767250&search.tagName=MOE"],
            ["웹툰", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=29767250&search.tagName=웹툰"],
            ["시즌4", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=29767250&search.tagName=시즌4"],
          ],
          dtext_artist_commentary_title: "시즌4 #10 (완결)",
          dtext_artist_commentary_desc: ""
        )
      end

      context "An article with .NHN_Writeform_Main commentary" do
        strategy_should_work(
          "https://cafe.naver.com/ca-fe/cafes/10947985/articles/204011",
          image_urls: %w[http://cafefiles.naver.net/20150603_254/qleleldhcks_1433308613966az8y9_PNG/%BC%A8%B4%ED2.png],
          media_files: [{ file_size: 1_001_221 }],
          page_url: "https://cafe.naver.com/ca-fe/cafes/10947985/articles/204011",
          profile_url: "https://cafe.naver.com/ca-fe/cafes/10947985/members/UXlF5_JnP6V8TthTFy5WXA",
          profile_urls: %w[https://cafe.naver.com/ca-fe/cafes/10947985/members/UXlF5_JnP6V8TthTFy5WXA https://cafe.naver.com/ohwow],
          display_name: "Chyan1",
          username: "qleleldhcks",
          tags: [],
          dtext_artist_commentary_title: "섀도우댄서 그려봤어요!",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[http://cafefiles.naver.net/20150603_254/qleleldhcks_1433308613966az8y9_PNG/%BC%A8%B4%ED2.png]

            안녕하세요!

            던공카에는 처음 글올리네요!

            어제 새벽에 섀도우댄서 그려보고싶어져서 슥슥 그렸습니다!

            커미션 받고있는데 혹시 관심있으시면 블로그 많이 들러주세요!

            감사합니담 :D !

            [b][출처][/b] "섀댄 그려봤습니다 (던파카페 -던카(던전앤파이터 커뮤니티 &아트스킨 &아이템거래))":[http://cafe.naver.com/dfither/10843674] |[b]작성자[/b] "Chyan":[http://cafe.naver.com/dfither.cafe?iframe_url=/CafeMemberNetworkView.nhn%3Fm=view%26memberid=qleleldhcks]

            [b]<던전앤파이터 아트게시판 공지>[/b]

            - 아트게시판에서 [b]19금 아트를 공유하면 활정/영정 [/b]됩니다.

            - 타인의 아트를 올릴 경우 만든이의 [b]닉네임을 기입하여 도용의 오해[/b]를 받지마시기 바랍니다.

            - [b]적용되는 직업 및 적용되는 아바타 등을[/b] 되도록 적어주시기 바랍니다.
          EOS
        )
      end

      context "A https://cafe.naver.com/:club_name/:article_id URL" do
        strategy_should_work(
          "https://cafe.naver.com/honkaistarrail/229677",
          image_urls: %w[
            http://cafefiles.naver.net/MjAyNDAyMjZfMTg4/MDAxNzA4OTMxMTMzMTYy.7C2pXoQ4RVHMD9_aoGpuHp9Lhr0lEUuSgYMoPF1hk1Yg.oIVfTUGlodwvIjDqBwOZwiN6Ei2yjjFK65X8bTJFFOwg.PNG/活动-姬子.png
            http://cafefiles.naver.net/MjAyNDAyMjZfMjYw/MDAxNzA4OTMxMTg5MDU4.NbiO_pqX7S346wbDIhMp8M8X1SBoVhUeTl7iSXqqN5Ag.WF1-AZ31U-aeHJPlgOjfMvgFkf2c-o1inSyDAUNx1n8g.PNG/삼성-강남-티징이미지__v1.4.png
            http://cafefiles.naver.net/MjAyNDAyMjZfNjYg/MDAxNzA4OTMxNDAzODYw._6czjQqLbjSb7ySygaGChHrQLUxoofn2NLpfacIKrbIg.0TpiGDtNCWueB_lG-XLqVAqLNmis0-ul1RBnkKNKiREg.JPEG/삼성_-애디션-티징이미지.jpg
          ],
          media_files: [
            { file_size: 262_117 },
            { file_size: 1_721_885 },
            { file_size: 464_062 },
          ],
          page_url: "https://cafe.naver.com/honkaistarrail/229677",
          profile_url: "https://cafe.naver.com/ca-fe/cafes/30487825/members/Vto2qFWaBkptLlqVHADCbw",
          profile_urls: %w[https://cafe.naver.com/ca-fe/cafes/30487825/members/Vto2qFWaBkptLlqVHADCbw https://cafe.naver.com/honkaistarrail],
          display_name: "GM폼폼",
          username: "honkaistarrail",
          tags: [
            ["페나코니꿈의상점", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=30487825&search.tagName=페나코니꿈의상점"],
            ["은랑에디션", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=30487825&search.tagName=은랑에디션"],
            ["GalaxyS24plus", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=30487825&search.tagName=GalaxyS24plus"],
            ["삼성강남", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=30487825&search.tagName=삼성강남"],
            ["스타레일", "https://cafe.naver.com/CafeTagArticleList.nhn?search.clubId=30487825&search.tagName=스타레일"],
          ],
          dtext_artist_commentary_title: "「다음역, 삼성 강남 - 페나코니 꿈의 상점」 팝업 &  「Galaxy S24+ Accessory 붕괴: 스타레일 - 은랑 에디션」 출시 예고",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[http://cafefiles.naver.net/MjAyNDAyMjZfMTg4/MDAxNzA4OTMxMTMzMTYy.7C2pXoQ4RVHMD9_aoGpuHp9Lhr0lEUuSgYMoPF1hk1Yg.oIVfTUGlodwvIjDqBwOZwiN6Ei2yjjFK65X8bTJFFOwg.PNG/活动-姬子.png]

            안녕 개척자!

            오늘은 개척자가 좋아할 굉장한 소식을 가져왔어.

            바로 "삼성 강남":[https://www.samsung.com/sec/samsungstore/gangnam/]에서 [b]「다음역, 삼성 강남 - 페나코니 꿈의 상점」[/b] 팝업 이벤트가 개최될 예정이라는 소식이야!

            이벤트에 대한 더 자세한 정보는 추후 공지를 통해 알려줄게!

            "[image]":[http://cafefiles.naver.net/MjAyNDAyMjZfMjYw/MDAxNzA4OTMxMTg5MDU4.NbiO_pqX7S346wbDIhMp8M8X1SBoVhUeTl7iSXqqN5Ag.WF1-AZ31U-aeHJPlgOjfMvgFkf2c-o1inSyDAUNx1n8g.PNG/삼성-강남-티징이미지__v1.4.png]

            [b]「다음역, 삼성 강남 - 페나코니 꿈의 상점」[/b] 이벤트 개요

            ▪ 장소: 삼성 강남

            ▪ 기간: 2024.03.28 ~ 2024.04.10.

            [hr]

            그리고 주목해야 할 또 다른 소식!

            무려 [b]Galaxy S24+ Accessory 붕괴: 스타레일 - 은랑 에디션[/b]이 출시될 예정이라는 말씀!

            자세한 출시 일정과 제품에 대한 더 자세한 안내도 추후 공지를 통해서 알려줄게.

            "[image]":[http://cafefiles.naver.net/MjAyNDAyMjZfNjYg/MDAxNzA4OTMxNDAzODYw._6czjQqLbjSb7ySygaGChHrQLUxoofn2NLpfacIKrbIg.0TpiGDtNCWueB_lG-XLqVAqLNmis0-ul1RBnkKNKiREg.JPEG/삼성_-애디션-티징이미지.jpg]

            그럼 많은 기대 부탁해 개척자!

            [quote]
            여정의 끝이 뭇별에 닿길
            [/quote]
          EOS
        )
      end

      context "A members-only article" do
        strategy_should_work(
          "https://cafe.naver.com/feveraca/544",
          image_urls: [],
          page_url: "https://cafe.naver.com/feveraca/544",
          profile_url: "https://cafe.naver.com/feveraca",
          profile_urls: %w[https://cafe.naver.com/feveraca],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent article" do
        strategy_should_work(
          "https://cafe.naver.com/bad/9999999999",
          image_urls: [],
          page_url: "https://cafe.naver.com/bad/9999999999",
          profile_urls: %w[https://cafe.naver.com/bad],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://cafeptthumb-phinf.pstatic.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png?type=w800"))
        assert(Source::URL.image_url?("https://cafeskthumb-phinf.pstatic.net/MjAyNDA0MDFfMjkw/MDAxNzExOTQ5MTg5NzY2.8DmwoaPifD-0oadfU7t1_lKnvdamYMrnLy54eMrN9vAg.za-YKoWgxbO1dTr4Zql6sZH0FmdOsirmo3WobhB2kJgg.JPEG/maxresdefault.jpg?type=w1080"))
        assert(Source::URL.image_url?("https://cafefiles.pstatic.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png"))
        assert(Source::URL.image_url?("https://cafefiles.pstatic.net/MjAyNDA0MDFfMjkw/MDAxNzExOTQ5MTg5NzY2.8DmwoaPifD-0oadfU7t1_lKnvdamYMrnLy54eMrN9vAg.za-YKoWgxbO1dTr4Zql6sZH0FmdOsirmo3WobhB2kJgg.JPEG/maxresdefault.jpg"))
        assert(Source::URL.image_url?("http://cafefiles.naver.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png"))
        assert(Source::URL.image_url?("http://cafefiles.naver.net/MjAyNDA0MDFfMjkw/MDAxNzExOTQ5MTg5NzY2.8DmwoaPifD-0oadfU7t1_lKnvdamYMrnLy54eMrN9vAg.za-YKoWgxbO1dTr4Zql6sZH0FmdOsirmo3WobhB2kJgg.JPEG/maxresdefault.jpg"))
        assert(Source::URL.image_url?("http://cafefiles.naver.net/20160912_57/lioneva_1473691969811MBqn4_JPEG/%BF%A1%B5%E0%C4%C9%C0%CC%C5%CD.jpg"))

        assert_not(Source::URL.image_url?("https://m.cafe.naver.com/ImageView.nhn?imageUrl=https://cafeptthumb-phinf.pstatic.net/MjAyMDEwMjFfMjIz/MDAxNjAzMjc1MTg3NjM5.waVrxNtSEW261INoEfGXuebgU4-q-IcNCg2oE7PfQ2Ug.vzDeHTJOcain0rNrITE80ulrN21UjiSEeU3X22qAEuUg.GIF/5sopu.gif"))
        assert_not(Source::URL.image_url?("https://cafe.naver.com/common/storyphoto/viewer.html?src=https%3A%2F%2Fcafeptthumb-phinf.pstatic.net%2FMjAyMzA3MDZfMzIg%2FMDAxNjg4NjM3NzcyNDg3.CrtekTl5XiXEJCFy9532vabMKo0CaWwryTMM0Up77Jgg.8ppf2Q3uiVWUlIP6jckYwYSe5Ys-erSsd7yf8XoHECIg.PNG%2F%25EC%259C%25A0%25EC%259A%25B0%25EC%25B9%25B4_%25EC%2597%2585%25EB%25A1%259C%25EB%2593%259C%25EC%259A%25A9.png"))

        assert(Source::URL.page_url?("https://cafe.naver.com/ca-fe/cafes/29767250/articles/785"))
        assert(Source::URL.page_url?("https://m.cafe.naver.com/ca-fe/web/cafes/29767250/articles/785"))
        assert(Source::URL.page_url?("https://cafe.naver.com/ArticleRead.nhn?clubid=29767250&articleid=793"))
        assert(Source::URL.page_url?("https://m.cafe.naver.com/ArticleRead.nhn?clubid=29767250&articleid=793"))
        assert(Source::URL.page_url?("https://cafe.naver.com/nexonmoe?iframe_url=%2FArticleRead.nhn%3Fclubid%3D29767250%26articleid%3D793"))
        assert(Source::URL.page_url?("https://cafe.naver.com/nexonmoe?iframe_url_utf8=%2FArticleRead.nhn%3Fclubid%3D29767250%26articleid%3D793"))
        assert(Source::URL.page_url?("https://cafe.naver.com/masterofeternity/793"))
        assert(Source::URL.page_url?("https://m.cafe.naver.com/masterofeternity/793"))

        assert(Source::URL.profile_url?("https://cafe.naver.com/masterofeternity"))
        assert(Source::URL.profile_url?("https://m.cafe.naver.com/masterofeternity"))
        assert(Source::URL.profile_url?("https://cafe.naver.com/masterofeternity?iframe_url=/MyCafeIntro.nhn%3Fclubid=29314033"))
        assert(Source::URL.profile_url?("https://cafe.naver.com/MyCafeIntro.nhn?clubid=29314033"))
        assert(Source::URL.profile_url?("https://cafe.naver.com/ArticleList.nhn?search.clubid=29767250&search.menuid=19"))
        assert(Source::URL.profile_url?("https://cafe.naver.com/ca-fe/cafes/27842958/members/Iep9BEdfIxd759MU7JgtSg"))
      end
    end
  end
end
