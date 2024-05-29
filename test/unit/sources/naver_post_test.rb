# frozen_string_literal: true

require "test_helper"

module Sources
  class NaverPostTest < ActiveSupport::TestCase
    context "Naver Post:" do
      context "A post-phinf.pstatic.net image URL" do
        strategy_should_work(
          "https://post-phinf.pstatic.net/MjAyMDAyMTVfMjQy/MDAxNTgxNzE2NTY5Njg0.ozzkHtgYHjePRKofX6NbJ_f4gA_4xha9OuLFELr9iAIg.Dm3x5uVIUY0DMlL2vf2JvT3hIucI8gE2lKnTIXcf3Awg.JPEG/%EB%8F%8C1.jpg?type=w1200",
          image_urls: %w[https://post-phinf.pstatic.net/MjAyMDAyMTVfMjQy/MDAxNTgxNzE2NTY5Njg0.ozzkHtgYHjePRKofX6NbJ_f4gA_4xha9OuLFELr9iAIg.Dm3x5uVIUY0DMlL2vf2JvT3hIucI8gE2lKnTIXcf3Awg.JPEG/돌1.jpg],
          media_files: [{ file_size: 3_762_840 }],
          page_url: nil
        )
      end

      context "A blog.kakaocdn.net image URL" do
        strategy_should_work(
          "https://blog.kakaocdn.net/dn/cJSXhs/btqHBRGLYvT/uJXMz48vCSKHMWs4aN8ytK/img.jpg",
          image_urls: %w[https://blog.kakaocdn.net/dn/cJSXhs/btqHBRGLYvT/uJXMz48vCSKHMWs4aN8ytK/img.jpg],
          media_files: [{ file_size: 86_963 }],
          page_url: nil
        )
      end

      context "A image.nhn?src=<url> URL" do
        strategy_should_work(
          "https://post.naver.com/viewer/image.nhn?src=https://post-phinf.pstatic.net/MjAxODEyMjZfMiAg/MDAxNTQ1NzgzMzAwMDkz.uFFOHZ8HeFnn-9_qpr3kl4QAt4pvMBi1O1evmSIp8Y4g.PMJ-2dLbfuqMxzEg62Bc84vUn7v0Cjttfaxd8HaY9TIg.JPEG/%25EA%25B0%259C%25EC%259D%25B8%25EC%259E%2591_%25EB%25B8%2594%25EC%2586%258C%25EB%25A6%25B0%25EC%25A1%25B1.jpg",
          image_urls: %w[https://post-phinf.pstatic.net/MjAxODEyMjZfMiAg/MDAxNTQ1NzgzMzAwMDkz.uFFOHZ8HeFnn-9_qpr3kl4QAt4pvMBi1O1evmSIp8Y4g.PMJ-2dLbfuqMxzEg62Bc84vUn7v0Cjttfaxd8HaY9TIg.JPEG/개인작_블소린족.jpg],
          media_files: [{ file_size: 3_696_520 }],
          page_url: nil
        )
      end

      context "A blog.kakaocdn.net image URL with a Naver Post referer" do
        strategy_should_work(
          "https://blog.kakaocdn.net/dn/cOHAHD/btqE562vL5q/y07jEFcA4KijDg57EY44c0/img.png",
          referer: "https://post.naver.com/viewer/postView.naver?volumeNo=28956950&memberNo=23461945",
          image_urls: %w[https://blog.kakaocdn.net/dn/cOHAHD/btqE562vL5q/y07jEFcA4KijDg57EY44c0/img.png],
          media_files: [{ file_size: 14_347 }],
          page_url: "https://post.naver.com/viewer/postView.naver?volumeNo=28956950&memberNo=23461945",
          profile_urls: %w[https://post.naver.com/my.naver?memberNo=23461945]
        )
      end

      context "A postView.naver page with a complex commentary" do
        strategy_should_work(
          "https://post.naver.com/viewer/postView.naver?volumeNo=28956950&memberNo=23461945",
          image_urls: %w[
            https://blog.kakaocdn.net/dn/cOHAHD/btqE562vL5q/y07jEFcA4KijDg57EY44c0/img.png
            https://blog.kakaocdn.net/dn/Srum3/btqE7BmKN9E/ZWetKqrFIJlbkhVxj7EgkK/img.png
            https://blog.kakaocdn.net/dn/d7u5Ke/btqE6L4rYxi/bKEFA48hyByRGHJ0TuMRfK/img.png
            https://blog.kakaocdn.net/dn/bbjMwU/btqE56g8Ra2/02V58j0MfyjcKHIBMzQn50/img.png
            https://blog.kakaocdn.net/dn/bJ2YCX/btqE7ogRbSO/iSxHUnUU3PrzeHZPOclKx1/img.png
            https://blog.kakaocdn.net/dn/bU6zui/btqE8xYfUrs/J9nBhqnrK4KXmpvGqyjhRK/img.png
            https://blog.kakaocdn.net/dn/bfyPL8/btqE7AIcA2D/ETK2SIqJWZ6xkMswLcvnWK/img.png
            https://blog.kakaocdn.net/dn/bd6xuo/btqE6MI3vEY/I3p3PYLO9urwAdLFnTcHlK/img.jpg
            https://blog.kakaocdn.net/dn/c0fJV0/btqE7oaaO8k/0N7GeTrbU4d8H6szlzwKf0/img.jpg
          ],
          media_files: [
            { file_size: 14_347 },
            { file_size: 15_833 },
            { file_size: 13_685 },
            { file_size: 16_056 },
            { file_size: 14_619 },
            { file_size: 14_836 },
            { file_size: 14_248 },
            { file_size: 290_723 },
            { file_size: 309_002 },
          ],
          page_url: "https://post.naver.com/viewer/postView.naver?volumeNo=28956950&memberNo=23461945",
          profile_url: "https://post.naver.com/my.naver?memberNo=23461945",
          profile_urls: %w[https://post.naver.com/my.naver?memberNo=23461945],
          artist_name: "시프리스트",
          tag_name: nil,
          other_names: ["시프리스트"],
          tags: [
            ["옥토패스트래블러", "https://post.naver.com/tag/overView.naver?tag=옥토패스트래블러"],
            ["도전과제", "https://post.naver.com/tag/overView.naver?tag=도전과제"],
            ["업적", "https://post.naver.com/tag/overView.naver?tag=업적"],
            ["공략", "https://post.naver.com/tag/overView.naver?tag=공략"],
          ],
          dtext_artist_commentary_title: "옥토패스 트래블러 도전과제 팁과 자료 모음",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://blog.kakaocdn.net/dn/cOHAHD/btqE562vL5q/y07jEFcA4KijDg57EY44c0/img.png]

            [b]1. 전략가 - 모든 적의 모든 약점을 알아낸다[/b]

            옥토패스 트래블러 도전과제의 끝판왕이자 가장 쓰레기같은 업적입니다. "옥토패스 리뷰":[http://naver.me/GkEr1v9U]에서도 언급했듯이 본 작품에는 도감 시스템이 없습니다. 즉, 게임을 하며 만난 모든 적을 일일히 수동으로 기록해가며 해야만 깰 수 있는 어처구니없는 업적입니다. 만나거나 쓰러뜨리는걸로도 부족해 모든 적의 모든 약점을 알아내야 하기에 학자의 조사하기(しらべる, Analyze)를 부스트하는걸 습관적으로 해야만 합니다. 당연히 이 업적을 작업하는 동안에는 전투 템포가 엄청나게 느려지고 엑셀 창을 켰다 껐다 하는걸 반복하다 보면 심각한 자괴감이 듭니다(...)

            다행히 여러 필드에서 중복으로 나오는 몬스터들도 꽤나 존재하고 약점이 1~2가지 뿐인 적도 많이 존재하지만 그게 전부입니다. 출현율이 심각하게 낮은 몬스터를 만나기 위해 인카운터를 토 나오도록 반복하고, 만나고 나면 학자 BP를 쌓아 조사하기를 쓰는 과정이 계속됩니다. 패시브부터 약점을 하나 알려주고 기본 직업까지 학자인 사이러스가 파티에 존재한다면 정말 많이 쾌적해지니 이 업적을 노리시는 분들은 시작 캐릭터를 사이러스로 하는걸 [b]강력하게[/b] 권장드립니다.

            이 업적의 악랄함은 여기서 끝나지 않습니다. 옥토패스 트래블러는 특이하게도 파티의 수준에 따라 필드에서 등장하는 몬스터가 달라지는데, 이 때문에 일부 몬스터는 파티가 강해지면 그 세이브 파일에서는 [b]영원히 만날 수 없습니다.[/b] 이는 정말 중요한 사항으로 도전과제를 노린다면 반드시 해당 몬스터들 만큼은 약점을 채워놔야 합니다.

            [b](추가) 다른 세이브 파일에서 알아낸 약점도 도전과제에는 공유되기 때문에 만약 놓쳤다면 새로 세이브 파일을 만들어 알아내면 됩니다. 또한 각 챕터 보스는 이 도전과제에 영향이 없는 것으로 추정됩니다.[/b]

            강해지기 전에 무조건 약점을 알아내야 하는 몹은 총 4마리 입니다.

            [b]1) 선인장구리 - 남쪽,동쪽 선셰이드 사막길 출현 파티 멤버가 4명이 될 경우 안나옴[/b]
            [b]2) 비프 - 동쪽,북쪽 아틀라스담 평원 출현 파티 멤버가 4명이 될 경우 안나옴[/b]
            [b]3) 바다의 버디언 4 - 달빛에 가려진 해안길, 서쪽 골드쇼어 해안길 출현  위험도가 34가 될 경우 안나옴[/b]
            [b]4) 해적(곡검) 1 - 달빛에 가려진 해안길, 서쪽 골드쇼어 해안길 출현 위험도가 34가 될 경우 안나옴[/b]

            위 4마리 만큼은 무슨 일이 있어도 먼저 작업해야 합니다. 그 외에는 엑셀로 기록만 착실히 한다면 문제될 부분 없습니다. 오로지 근성 또 근성 뿐입니다. 아래는 한글로 번역된 전략가 작업 시트입니다. 사용하면 정말 편리합니다.

            [b]원본 글 : [/b]"[b]https://gall.dcinside.com/mgallery/board/view/?id=octopathtraveler&no=2382[/b]":[https://gall.dcinside.com/mgallery/board/view/?ctopathtraveler&no=2382]

            <https://gall.dcinside.com/mgallery/board/view/?id=octopathtraveler&no=2382>

            [b]구글 문서 : [/b]"[b]https://docs.google.com/spreadsheets/d/118kF1rbm15L5HLWf2uw6xbiYCtOIcvBZN0YbIoqqd1k/edit#gid=1856552299[/b]":[https://docs.google.com/spreadsheets/d/118kF1rbm15L5HLWf2uw6xbiYCtOIcvBZN0YbIoqqd1k/edit#g856552299]

            <https://docs.google.com/spreadsheets/d/118kF1rbm15L5HLWf2uw6xbiYCtOIcvBZN0YbIoqqd1k/edit#gid=1856552299>

            [hr]

            "[image]":[https://blog.kakaocdn.net/dn/Srum3/btqE7BmKN9E/ZWetKqrFIJlbkhVxj7EgkK/img.png]

            [b]2. 수집가 - 모든 아이템을 모은다.[/b]

            심플합니다. 옥토패스 트래블러에 존재하는 모든 아이템을 한번씩이라도 얻어보면 됩니다. 물론 전략가와 마찬가지로 본 작품에는 [b]도감이 없기에[/b] 알아서 웹상에 존재하는 아이템 목록과 대조해보며 해야합니다. 게임 자체가 돈이 상당히 여유로운 편이라 트레사 매입에 과도하게 돈을 쓰는게 아니라면 상점에 소지수가 0인 아이템이 있다면 틈틈히 모두 구입해놓는게 좋습니다.

            수집가도 전략가와 마찬가지로 [b]한번 놓치면 영원히 얻지 못하는 아이템[/b]이 존재합니다. 딱 세가지만 주의하시면 됩니다.

            [b]1) 흑요회의 의복 - 프림로제 챕터3 보스전 30% 확률로 드랍 or 보스와 함께 나오는 흑요회 간부에게서 훔치기[/b]

            무조건 해당 보스전에서 훔치기를 사용하는게 좋습니다.

            [b]2) 변옥의 서 - 사일러스 챕터4 보스전을 깬 후, 주변을 조사해서 3가지 책을 얻을때 보스 시체에 있는 책을 마지막에 얻을 경우 버그로 인벤토리에 들어오지 않음.[/b]

            저도 이 버그 때문에 보스 한번 더 깼습니다...무조건 조심하세요

            [b]3) 조슈아/아치볼트/구스타프의 약점 - 올베릭 챕터2에서 매 대전 경기 전에 반대편 대기실에 가서 사이러스나 알핀으로 얻어내시면 됩니다.[/b]

            그리고 언제든지 얻을 수 있지만 공략 없이는 얻기 까다로운 물건들이 몇가지 있습니다. 루리웹에 어떤 분이 한글로 잘 정리해주신게 있습니다.

            [b]링크 : [/b]"[b]https://bbs.ruliweb.com/game/84783/read/924[/b]":[https://bbs.ruliweb.com/game/84783/read/924]

            <https://bbs.ruliweb.com/game/84783/read/924>

            [b]1. 오필리아 챕터 3 해안 동굴의 흑염교 신자 1/2 훔치기 : 마물의 향수 (챕터 4 마티아스 부하에게서도 얻을수있습니다)[/b]
            [b]2. 이본의 저택 연구원 1 훔치기or 드랍 : 한숨의 보틀[/b]
            [b]3. 이본의 저택 연구원 2[/b][b]훔치기or 드랍 [/b][b]: 하이바드링크[/b]
            [b]4. 이본의 저택 연구원 3[/b][b]훔치기or 드랍 [/b][b]: 루나리크드의 열매[/b]
            [b]5. 북쪽 시왈키 숲길 방랑 학자 시합으로 드랍 : 메이스[/b]
            [b]6. 선셰이드 마을 동쪽 모래에 뒤섞인 남성 시합으로 드랍 : 아리의 빵[/b]
            [b]7. 서쪽 클리어브룩 하천길 생선 장수 시합으로 드랍 : 힙 플라스크[/b]
            [b]8. 아틀라스담 마을 입구 남쪽 전직 귀족의 하인 시합으로 드랍 : 먼지떨이[/b]
            [b]9. 클리어브룩 왼쪽 시합으로 들어가는 집 노인에게서 훔치기/매입 : 금도끼[/b]

            대전을 걸고 걸고 걸고 또 걸어도 정말 더럽게 안나오지만 나오긴 나옵니다(...) 인내심을 가지고 여러번 도전해보시길 바랍니다. 그 외에 금단/역전 아이템들 역시 루리웹에 잘 정리된 글이 있습니다.

            [b]링크 : [/b]"[b]https://bbs.ruliweb.com/nin/game/84783/read/479[/b]":[https://bbs.ruliweb.com/nin/game/84783/read/479]

            <https://bbs.ruliweb.com/nin/game/84783/read/479>

            [hr]

            "[image]":[https://blog.kakaocdn.net/dn/d7u5Ke/btqE6L4rYxi/bKEFA48hyByRGHJ0TuMRfK/img.png]

            [b]3. 보물 사냥꾼 - 모든 상자를 열어본다.[/b]

            역시나 말은 간단합니다. 게임상에 존재하는 모든 상자를 열어보면 됩니다. 옥토패스 자체가 맵이 복잡한 편이 아니라서 대다수의 보물상자는 발견하는게 어렵지 않습니다. 물론 그렇다고 해도 길을 찾기 어려운 상자도 많고 중간중간 인카운터도 매우 짜증나는건 변하지 않습니다(...) 진최종보스 클리어 후 인카운터를 없애주는 악세사리를 얻은 다음에 작업하는 것도 괜찮습니다.

            놓칠 수 있는 보물상자는 딱 한개 입니다. 사이러스 챕터3에서 저택의 함정에 떨어진 후 [b]옆에 있는 상자를 반드시 여세요.[/b] 해당 상자만 열었다면 나머지 상자들은 언제든지 작업 가능합니다.

            영어지만 해외 유저들이 만든 보물상자 시트에 기록하면서 작업하면 매우 편리합니다. 대략적인 상자의 위치도 모두 적혀있으니 활용해보세요.

            [b]구글 시트 : [/b]"[b]https://docs.google.com/spreadsheets/d/1w22OtuNrq3L4ToqBp4QGK3BGtQ3qJj5VQpTN9uUV-mY/edit#gid=1123329992[/b]":[https://docs.google.com/spreadsheets/d/1w22OtuNrq3L4ToqBp4QGK3BGtQ3qJj5VQpTN9uUV-mY/edit#g123329992]

            <https://docs.google.com/spreadsheets/d/1w22OtuNrq3L4ToqBp4QGK3BGtQ3qJj5VQpTN9uUV-mY/edit#gid=1123329992>

            [hr]

            "[image]":[https://blog.kakaocdn.net/dn/bbjMwU/btqE56g8Ra2/02V58j0MfyjcKHIBMzQn50/img.png]

            [b]4. 독수리의 눈 - 모든 숨겨진 아이템을 찾았다.[/b]

            일단 이 도전과제에서 말하는 '숨겨진 아이템'이란 알핀이나 사이러스로 '숨겨진 아이템에 대한 정보'를 얻었을 때 필드에 등장하는 아이템들을 말합니다. 즉, 무슨 뜻이냐? 알핀이나 사이러스로 모든 NPC를 한 명 한 명 캐묻고 다녀야 합니다. 심지어 너무나 당연하게도 이 도전과제 역시 [b]한번 놓치면 영원히 얻을 수 없는 숨겨진 아이템들[/b]이 존재합니다. 이쯤되면 개발진의 악의마저 느껴집니다(...)

            [b]1) 클리어브룩의 제프 - 모든 캐릭터의 챕터 4를 클리어하면 사라짐[/b]
            [b]2) 클리어브룩의 메릴 - 메릴의 사이드 퀘스트를 완료하면 사라짐[/b]
            [b]3) 올베릭 챕터 3 웰스프링의 베일 - 올베릭 챕터 4를 클리어하면 사라짐[/b]
            [b]4) 더스크배로우의 문장을 달고 있는 사기꾼 - 결투에서 승리하면 사라짐[/b]

            그나마 이 도전과제는 모든 NPC를 꼼꼼하게 말 걸고, 훔치고, 매입하고, 질문하는 플레이어라면 어렵지 않게 깰 수 있습니다. 그렇지 않다면 위의 4명이라도 반드시 해두시길 바랍니다.

            [hr]

            "[image]":[https://blog.kakaocdn.net/dn/bJ2YCX/btqE7ogRbSO/iSxHUnUU3PrzeHZPOclKx1/img.png]

            [b]5. 가장 강력한 체류자 - 최대 데미지를 입혔다.[/b]

            이번엔 쉬어가는 시간입니다. 99999 데미지를 한 번이라도 입히면 됩니다. 가장 쉽게 달성하는 방법은 올베릭에게 약사 직업과 후반부의 강력한 도끼를 쥐어준 후 한번 죽인다던지 해서 피를 1로 만듭니다. 그다음 사중활격참 (死中活撃断, Last Stand)을 사용하면 됩니다. 도적의 방어력 감소가 있다면 더욱 쉽게 달성 가능합니다.

            참고로 이 방법은 진최종보스전에서도 매우 매우 유효합니다. 사중활격참이 적 전체 대상이라 최종 보스의 신체 부위들이 도끼질에 두 동강이 나는 모습을 볼 수 있습니다. 최종 보스가 너무 어렵다면 한 번쯤 해보시길.

            [hr]

            "[image]":[https://blog.kakaocdn.net/dn/bU6zui/btqE8xYfUrs/J9nBhqnrK4KXmpvGqyjhRK/img.png]

            [b]6. 빠른 발 - 전광석화로 여정을 마쳤다.[/b]

            도전과제 설명만 보면 무슨 소리인가 싶지만 알고보면 단순합니다. 플레이 타임 4시간 이내로 한 캐릭터의 챕터 4를 완료하면 달성됩니다. 즉, [b]스피드런 도전과제[/b]입니다. 이 업적은 따로 설명하기보단 아래의 [b]'고독한 여행자' 업적[/b]과 함께 설명 하겠습니다.

            [hr]

            "[image]":[https://blog.kakaocdn.net/dn/bfyPL8/btqE7AIcA2D/ETK2SIqJWZ6xkMswLcvnWK/img.png]

            [b]7. 고독한 여행자 - 다른 사람의 도움 없이 여정을 보았다.[/b]

            [b]파티원을 한 명도 구하지 않은 상태로 챕터 4를 클리어하면 됩니다.[/b] 즉 시작 캐릭터로 챕터 4까지 쭈~욱 진행하면 달성됩니다. 4명으로도 보스한테 후드득 쓸려나가는 게임에서 이게 무슨 헛소리인가 싶지만 사실 모든 캐릭터로 달성 가능한 도전과제입니다. 실제로 해외에는 8명 모두의 1인 클리어 공략이 존재합니다.

            [b]8 캐릭터 1인 클리어 공략 : [/b]"[b]https://steamcommunity.com/sharedfiles/filedetails/?id=1768718723[/b]":[https://steamcommunity.com/sharedfiles/filedetails/?768718723]

            <https://steamcommunity.com/sharedfiles/filedetails/?id=1768718723>

            물론 대부분의 캐릭터는 1인 클리어가 끔찍하게 어려운 관계로 가장 무난하게 권장되는 캐릭터는 '트레사'입니다. 트레사는 다른 캐릭터들과 차별화되는 독보적인 장점이 몇 가지 있습니다.

            [b]1) 필드액션 '매입'의 우월함[/b]

            시작하자마자 냅다 학자 얻고 인카운터 반감 달고 챕터 4 도시로 달려가면 최종 템 무장이 다이렉트로 가능합니다. 장비 스펙이 압도적인 만큼 당연히 다른 캐릭터보다 몇 배는 성장이 빨라집니다. 거기에 매입으로 스텟을 영구적으로 올려주는 넛츠까지 구입한다면 다른 캐릭터와의 격차는 더더욱 벌어집니다.

            [b]2) 챕터 3 보스의 호구성[/b]

            챕터3 보스가 정말 날먹 수준으로 쉽습니다. 적절한 레벨에 독 무효 악세사리, 약사 직업 정도만 준비해도 프리패스입니다.

            [b]3) 상인 직업의 강력함[/b]

            본편에서도 준수한 상인이 1인클, 스피드런에서는 최강의 효율을 보여줍니다. 자힐과 상태이상 치료를 제공하는 [b]'휴식'[/b]부터 물리 피해를 무효화하는 [b]'긴급회피'[/b], 단일기와 광역기 모두 존재하는 바람 마법, 거기에 옥토패스 최고의 가성비 스킬 [b]'용병 부르기'[/b]까지 버릴게 하나 없습니다. 특히 이 [b]'용병 부르기'[/b]는 레벨 대비 데미지가 터무니없는 수준이라 위의 스피드런 업적에서도 최고로 애용되는 기술입니다.

            이런 이유로 따로 '나는 정말 애정 하는 캐릭터가 있다!'하시는 분이 아니라면 해당 업적들은 트레사로 진행하시는걸 강력하게 권장드립니다.

            "[image]":[https://blog.kakaocdn.net/dn/bd6xuo/btqE6MI3vEY/I3p3PYLO9urwAdLFnTcHlK/img.jpg]

            [b]* 이하 공략은 트레사 기준으로 marcv666님의 허락을 받고 위의 공략을 참고했습니다.[/b]

            스피드런과 1인클에서 공통적으로 가장 중요한 것은 [b]'인카운트 반감을 최대한 빨리 확보하는 것'[/b] 입니다. 스피드런과 1인클의 파티는 매우매우 연약하기 때문에 챕터 2~4 구간의 흉악한 필드 몹들을 버틸 수가 없습니다. 따라서 무조건 JP를 아낀채 학자의 사당을 빠르게 방문해 서포트 어빌리티로 인카운트 반감을 얻어야만 합니다.

            챕터1을 기존과 동일하게 진행하고 저장을 하며 빠르게 북쪽 아틀라스담 평원에 갑니다. 이제부터가 중요합니다. 북쪽 아틀라스담 평원에서 맵 남동쪽의 학자의 사당으로 달려가는데 이걸 [b]성공할 때까지[/b] 해야합니다. 레벨 5 트레사로는 도망가기 정말 어렵지만 반복하고 반복하고 또 반복하다보면 결국 도달할 수 있습니다. 학자 잡을 획득했다면 [b]뇌격 마법, 대뇌격 마법[/b] 정도를 습득해 주시면 됩니다.

            인카운트 반감을 얻었다면 이제는 돈을 모을 차례입니다. 스피드런과 1인클 모두 매입과 용병 부르기로 돈을 뿌리듯이(...) 플레이해서 클리어하는 방식이기 때문에 상당한 자금 확보가 필수적입니다. 대표적인 방법은 두가지 입니다.

            [b]1) 상위 맵에서 돈이 들어있는 보물상자만 먹고 다니기(보물 사냥꾼 시트 참고)[/b]

            <https://www.youtube.com/embed/NaBDRCMd2Ng?wmode=transparent>

            Lone Traveler Getting Subclass, most TownTeleport and MoneyChest

            [b]2) 트레사의 패시브를 이용해 던전을 뛰어다니며 돈 먹기[/b]

            <https://www.youtube.com/embed/Y2yhS1NOLvA?wmode=transparent>

            06-Lone Traveler: Farming money in Marsalim Catacomb

            [b]* 지금 공략은 스피드런과 병행하고 있기 때문에 1번 방법을 권장드립니다.[/b]

            돈이 충분히 확보되었다면 이제 장비를 맞출 시간입니다. 방패등은 공략마다 의견이 갈리지만 트레사의 창 만큼은 모두가 '룬 글레이브'를 최고로 뽑습니다. 트레사 챕터4 도시인 그란포트로 달려가서 매입으로 구매하시면 됩니다. 그외의 아이템은 다음 정도로 구입하시면 충분합니다.

            [b]그란포트 - 금단의 방패, 수호의 목걸이[/b]
            [b]세인트브릿지 - 엘리멘탈 햇[/b]
            [b]노블코트 or 에버홀드 - 마법사의 로브[/b]
            [b]스톤가드 - 엘리멘탈 부스터[/b]

            여기까지 왔다면 대망의 경험치 겸 JP 노가다 시간입니다. 경험치 파밍을 위한 장소는 서쪽 스톤가드 산길에 위치한 [b]'왕가의 무덤'[/b] 입니다. 만약 그랑포트에서 금단의 활을 매입했다면 인카운트 반감을 풀고 금단의 활을 장비하면 조금 더 노가다가 빨라집니다. 방법은 간단합니다. 학자의 마법으로 끊임없이 몹들은 순살하면서 렙업하시면 됩니다.

            [hr]

            "[image]":[https://blog.kakaocdn.net/dn/c0fJV0/btqE7oaaO8k/0N7GeTrbU4d8H6szlzwKf0/img.jpg]

            스피드런 클리어 당시 파티

            여기서 20레벨 정도로 적당히 강해졌다면 세이브 파일을 하나 별도로 만듭니다. 그리고 하닛, 사이러스, 테리온 정도를 영입하고 사냥꾼, 검사, 상인 사당을 방문해 해당 직업을 얻습니다. 사이러스(검사), 하닛(상인), 테리온(사냥꾼) 정도 직업 배치면 충분합니다.

            트레사의 장비가 터무니없이 강력하기 때문에 동료들을 방패로 삼고 소울스톤을 조금 활용하면 챕터2 보스는 쉽게 넘길 수 있습니다. 그 뒤로는 오로지 돈입니다. 상자를 까서 비싼 장비를 얻어 팔던, 돈을 얻던 하세요. 챕터3 보스는 창과 활 약점이라 검사의 [b]'천본창'[/b]과 사냥꾼의 [b]'애로우스톰'[/b]이면 빠르게 브레이크가 가능합니다. 그 다음엔 부스터 용병 부르기면 순식간에 녹여버릴 수 있습니다.

            챕터4는 조금 신경써야 합니다. 브레이크에 따라 창-활-창으로 약점이 바뀝니다. 역시 마찬가지로 천본창과 애로우 스톰을 잘 활용하고 보스가 브레이크 상태가 되면 상인이 아닌 멤버는 트레사와 하닛의 BP를 BP 전체 회복 석류로 채워줍니다. 파티원들이 워낙 연약하기 때문에 검사의 '도발'과 사냥꾼의 '점착실'을 잘 활용하는 편이 좋습니다. 브레이크 상태일때 x4 풀부스트 상인 부르기를 4번 정도 박으면 잡을 수 있습니다. 어차피 세이브 파일에 적혀있는 플레이 타임 기준이니 잘 안풀려도 세이브 로드 신공을 활용하세요. BP 전체회복석류는 상자를 통해 구하면 됩니다. [b]Energizing Pomegranate (L)[/b]를 "보물 사냥꾼 시트":[https://docs.google.com/spreadsheets/d/1w22OtuNrq3L4ToqBp4QGK3BGtQ3qJj5VQpTN9uUV-mY/edit#g123329992]에 검색하면 위치가 나옵니다.

            위 방법만 조금 서둘러서 따라하면 빠른 발 업적은 생각보다 손쉽게 딸 수 있습니다.

            [hr]

            다시 1인클 공략으로 돌아오자면 1인클의 경우는 확보해야 하는 서포터 어빌리티가 [b]매우[/b] 많습니다. 보스전마다 필요한 서포트 어빌리티가 다르기 때문에 정말 살인적인 JP를 요구합니다. 일단 왕가의 무덤에서는 다음 정도만 확보하면 됩니다.

            [b]SP 자동회복 - 무희 3번째 서포트 어빌리티 *1순위[/b]
            [b]HP 자동회복 - 학자 4번째 서포트 어빌리티[/b]
            [b]천본창 - 검사 스킬[/b]
            [b]소비 SP 다운 - 상인 4번째 서포트 어빌리티(나중에 얻어도 ok)[/b]

            전부 확보하면 대략 레벨이 29~34정도 됩니다. 이제 챕터2 보스에 갈 시간입니다.

            [hr]

            [b]<챕터2 보스>[/b]
            [b]직업 : 학자[/b]
            [b]서포트 어빌리티 : 속성 공격력+50, SP 자동회복, HP 자동회복, 반격[/b]

            이정도 세팅에 기존에 구입했던 장비면 충분히 클리어 가능합니다. 보스 옆에 쫄들은 번개 약점이기 때문에 보스를 브레이크 시키고 풀부스트 대뇌격마법을 사용하는 식이면 무난하게 진행됩니다. 어렵다면 소울스톤을 활용하는 것도 괜찮습니다.

            [hr]

            챕터 2를 클리어 했다면 새로운 노가다를 하기 전에 능력치를 영구적으로 올려주는 소모 아이템인 넛츠를 확보하는게 좋습니다. 트레사는 매입 스킬 덕분에 타 캐릭터의 몇배에 해당하는 넛츠를 확보할 수 있습니다. 상자에 있는 넛츠는 역시나 보물 사냥꾼 시트로 확인하면 됩니다. 그 외에 매입으로 얻는 너츠는 지역별로 다음과 같이 있습니다.

            [b]리플타이트 - 3개[/b]
            [b]그란포트 - 6개[/b]
            [b]스톤가드 - 3개[/b]
            [b]에버홀드 - 3개[/b]
            [b]선셰이드 - 2개[/b]
            [b]마르살림 - 3개[/b]
            [b]리버포드 - 4개[/b]
            [b]보더폴 - 1개[/b]
            [b]캐리크레스트 - 1개[/b]
            [b]빅터스호로우 - 5개[/b]
            [b]더스크배로우 - 1개[/b]
            [b]노스리치 - 3개[/b]
            [b]노블코트 - 1개[/b]
            [b]플레임그레이스 - 1개[/b]
            [b]버려진 유적 - 1개(사이드퀘스트 진행중에만 가능)[/b]

            추가로 리플타이드, 스틸스노우, 노스리치, 캐리크레스트에는 보상으로 너츠를 주는 사이드퀘스트를 수행 가능합니다. 모든 넛츠를 먹는다면 당연히 좋겠지만 그럴 필요 까지는 없고 적당히 드시면 됩니다. 그리고 넛츠를 구입한 다음엔 반드시 사용해야 적용됩니다. 잊지마시길.

            이제 다음 파밍입니다. 앞으로 목표로 해야 할 서포트 어빌리티는 다음과 같습니다.

            [b]소비 SP 다운 - 상인 4번째 서포트 어빌리티(위에서 얻지 않았다면)[/b]
            [b]애로우 스톰 - 사냥꾼 스킬[/b]
            [b]회복한계돌파 - 신관 4번째 서포트 어빌리티[/b]
            [b]회복효과 업 - 약사 4번째 서포트 어빌리티[/b]
            [b]라스트 액트 - 사냥꾼 4번째 서포트 어빌리티[/b]
            [b]철벽 - 검사 스킬[/b]

            추가로 '허무의 옥좌'에서 상자를 까서 맹독 내성 스톤을 확보해두세요. 챕터 3 보스에서 수호의 목걸이 대신 필수로 껴야합니다.

            이번 파밍 장소는 트레사 챕터 3 던전입니다. 다만 [b]'빙룡의 입'[/b]에서 노가다 하는 효율이 훨씬 좋기 때문에 소비 SP 다운이랑 애로우 스톰 정도 확보했고 어느정도 강하다 싶으면 바로 빙룡의 입으로 가셔도 됩니다. 빙룡의 입이 최종 파밍 장소입니다. 빙룡의 입 내부에 있는 상자에서 수면 내성 스톤을 얻어 수호의 목걸이 대신 끼고 애로우 스톰과 상인의 광역 바람 마법으로 사냥하시면 됩니다.

            [hr]

            챕터3 보스는 세팅만 마쳤다면 정말로 쉬운 사실상 넘어가는 구간입니다. 맹독 내성 스톤을 꼈다면 상태이상도 오지 않고 보스의 약점도 변하지 않아 브레이크 상태로 만들기도 매우 쉽습니다.

            [b]<챕터3 보스>[/b]
            [b]직업 : 약사[/b]
            [b]서포트 어빌리티 : 반격, HP 자동회복, SP 자동회복, 회복한계돌파[/b]
            [b]장비 : 수호의 목걸이 → 맹독 내성 스톤[/b]

            공략은 정말 쉽습니다. 창 약점이기 때문에 창과 반격으로 브레이크 만들고 바람 마법으로 때리면 끝입니다. 가끔 체력이 부족해진다면 약사의 우월한 단일힐로 오버체력을 만들면 됩니다. 더 이상 설명이 필요없는 수준으로 쉽습니다.

            [hr]

            위에 언급한 서포트 어빌리티와 스킬을 모두 얻었다면 이제 대망의 챕터4 보스를 준비할 차례입니다. 챕터4 보스의 공격력은 정말 무식한 수준이기 때문에 온갖 고급 회복 아이템, 용병 부르기, 소울스톤(특대)등 가능한 모든 수단을 동원하는게 좋습니다. 그리고 더 이상 여기까지 온 시점에선 더 이상 마법 데미지가 필요 없고 챕터4 보스는 물리 데미지 공격만을 하기 때문에 지금까지 써온 방어구를 팔고 물리 방어력 위주로 챙기는게 좋습니다.

            [b]마르살림 매입 - 드래곤스케일 아머[/b]
            [b]유사의 동굴 상자 or 위스퍼밀 상점 - 수호의 팔찌[/b]
            [b]용영의 신전 상자 - 크리스탈 헬름[/b]
            [b]+ 용병 부르기용 충분한 돈[/b]

            [b] Refreshing Jam, Revitalizing Jam, Soulstones (L), Energizing Pomegranate (L)[/b]은 보물 사냥꾼 시트에 검색해 최대한 많이 비축하는게 좋습니다. 특히 잼은 많으면 많을수록 좋습니다. 1인 클리어 최강의 회복 아이템입니다. 돈 역시 지금까지 모아왔던 아이템 중 쓸데없는건 팔아 부족하지 않게 확보해야 합니다. 너무나 당연하게도 본 보스전의 메인 딜링은 역시 x4 부스트 용병 부르기 입니다.

            [b]<챕터4 보스>[/b]
            [b]직업 : 검사[/b]
            [b]서포트 어빌리티 : 회복한계돌파, 반격, 회복효과 업, 라스트 액트[/b]
            [b]장비 : 룬 글레이브, 금단의 활, 금단의 방패, 크리스탈 헬름, 드래곤스케일 아머, 수호의 목걸이, 수호의 팔찌[/b]

            스피드런 파트에서 말했듯이 트레사 챕터4 보스의 약점은 창-활-창 순서로 바뀝니다. 따라서 반격과 천본창을 잘 활용하면 손쉽게 브레이크 유발이 가능합니다. 브레이크 이후에는 당연히 풀부스트 용병 부르기로 때리면 됩니다. 가끔 보스가 거는 방어력 감소 디버프는 검사의 철벽으로 지울 수 있습니다. 사전에 말했듯이 보스의 공격은 물리 공격이기 때문에 상인의 긴급회피 역시 유용합니다. 그리고 아무리 물리 방어력 세팅을 했어도 매우 아프기 때문에 회복한계돌파를 믿고 잼은 아낌없이 사용하세요.

            <https://www.youtube.com/embed/YecCbJKL-Ck?wmode=transparent>

            Lone Traveler, Tressa last boss

            [b]* marcv666님의 챕터 4 보스 트레사 클리어 영상입니다. 참고하면 매우 도움됩니다.[/b]

            [hr]

            잘못된 부분이나 누락된 부분은 언제나 댓글 환영합니다~
          EOS
        )
      end

      context "A deleted or nonexistent post" do
        strategy_should_work(
          "https://post.naver.com/viewer/postView.naver?volumeNo=999999999&memberNo=999999999",
          image_urls: [],
          media_files: [],
          page_url: "https://post.naver.com/viewer/postView.naver?volumeNo=999999999&memberNo=999999999",
          profile_url: "https://post.naver.com/my.naver?memberNo=999999999",
          profile_urls: %w[https://post.naver.com/my.naver?memberNo=999999999],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.page_url?("https://m.post.naver.com/viewer/postView.naver?volumeNo=33304944&memberNo=7662880"))
        assert(Source::URL.page_url?("https://post.naver.com/viewer/postView.nhn?volumeNo=33304944&memberNo=7662880"))

        assert(Source::URL.profile_url?("https://m.post.naver.com/author/board.naver?memberNo=7662880"))
        assert(Source::URL.profile_url?("https://post.naver.com/my.nhn?memberNo=6072169"))
        assert(Source::URL.profile_url?("https://post.naver.com/my/followingList.naver?memberNo=6072169&navigationType=push"))
        assert(Source::URL.profile_url?("https://post.naver.com/my/like/list.naver?memberNo=6072169&navigationType=push"))
        assert(Source::URL.profile_url?("https://post.naver.com/my/followerList.naver?followNo=6072169&navigationType=push"))
        assert(Source::URL.profile_url?("https://post.naver.com/dltkdrlf92"))
      end
    end
  end
end
