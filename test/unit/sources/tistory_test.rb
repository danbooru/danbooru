# frozen_string_literal: true

require "test_helper"

module Sources
  class TistoryTest < ActiveSupport::TestCase
    context "Tistory:" do
      context "A daumcdn.net/thumb sample image URL" do
        strategy_should_work(
          "https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FRA1tu%2FbtsFf2xGLbg%2FVzHK4tqMEWkeqUgDBxSkkK%2Fimg.jpg ",
          image_urls: %w[https://blog.kakaocdn.net/dn/RA1tu/btsFf2xGLbg/VzHK4tqMEWkeqUgDBxSkkK/img.jpg],
          media_files: [{ file_size: 12_774_450 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: nil,
          dtext_artist_commentary_desc: nil
        )
      end

      context "A daumcdn.net/cfile/tistory/:id sample image URL" do
        strategy_should_work(
          "https://t1.daumcdn.net/cfile/tistory/99EE76395C27CAF80B",
          image_urls: %w[https://t1.daumcdn.net/cfile/tistory/99EE76395C27CAF80B?original],
          media_files: [{ file_size: 74_214 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: nil,
          dtext_artist_commentary_desc: nil
        )
      end

      context "A blog.kakaocdn.net full image URL" do
        strategy_should_work(
          "https://blog.kakaocdn.net/dn/biaXrk/btsFefq3Y8k/YYadjg46g5ui1xzeY06GKk/img.jpg",
          image_urls: %w[https://blog.kakaocdn.net/dn/biaXrk/btsFefq3Y8k/YYadjg46g5ui1xzeY06GKk/img.jpg],
          media_files: [{ file_size: 383_245 }],
          page_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          tags: [],
          dtext_artist_commentary_title: nil,
          dtext_artist_commentary_desc: nil
        )
      end

      context "A name.tistory.com/:id post URL" do
        strategy_should_work(
          "https://primemeeting.tistory.com/25",
          image_urls: %w[
            https://blog.kakaocdn.net/dn/RA1tu/btsFf2xGLbg/VzHK4tqMEWkeqUgDBxSkkK/img.jpg
            https://blog.kakaocdn.net/dn/b5fPW7/btsFhqq2c9M/ZdcOTRjDgWkDnvfnxDdJs0/img.jpg
            https://blog.kakaocdn.net/dn/EL36z/btsFhUlfexR/NB1A8zauC7nD1QspTuuiIK/img.jpg
            https://blog.kakaocdn.net/dn/cfg4nc/btsFeuaCJXw/P2iOOIblO6g0mYtezXBE61/img.jpg
            https://blog.kakaocdn.net/dn/edGUOT/btsFeGaSAGv/MhON8iSYOQj28LVKU02hxk/img.jpg
            https://blog.kakaocdn.net/dn/bN0IZK/btsFg4hsH0k/HPQu7VKzcc76ZcKGe9uI00/img.jpg
            https://blog.kakaocdn.net/dn/wvnz7/btsFeDebtSp/3zkC1EBrtnufPbGTfp2D90/img.jpg
            https://blog.kakaocdn.net/dn/biaXrk/btsFefq3Y8k/YYadjg46g5ui1xzeY06GKk/img.jpg
            https://blog.kakaocdn.net/dn/c0eTqX/btsFhrwKq7f/019A9D6UCmkzcG1hgZN7l1/img.jpg
          ],
          media_files: [
            { file_size: 12_774_450 },
            { file_size: 5_361_382 },
            { file_size: 4_582_347 },
            { file_size: 3_125_796 },
            { file_size: 2_077_755 },
            { file_size: 1_498_246 },
            { file_size: 485_715 },
            { file_size: 383_245 },
            { file_size: 12_816_286 },
          ],
          page_url: "https://primemeeting.tistory.com/25",
          profile_urls: %w[https://primemeeting.tistory.com],
          display_name: "-G9",
          username: "primemeeting",
          tags: [],
          dtext_artist_commentary_title: "[눈물을 마시는 새] 트위터 백업 012",
          dtext_artist_commentary_desc: <<~EOS.chomp
            이것저것 섞여있습니다

            "[image]":[https://blog.kakaocdn.net/dn/RA1tu/btsFf2xGLbg/VzHK4tqMEWkeqUgDBxSkkK/img.jpg]

            "[image]":[https://blog.kakaocdn.net/dn/b5fPW7/btsFhqq2c9M/ZdcOTRjDgWkDnvfnxDdJs0/img.jpg]

            운넬 / 발탄궁에는 노란장미가 핀다

            "[image]":[https://blog.kakaocdn.net/dn/EL36z/btsFhUlfexR/NB1A8zauC7nD1QspTuuiIK/img.jpg]

            여닐칼

            "[image]":[https://blog.kakaocdn.net/dn/cfg4nc/btsFeuaCJXw/P2iOOIblO6g0mYtezXBE61/img.jpg]

            닐여칼

            "[image]":[https://blog.kakaocdn.net/dn/edGUOT/btsFeGaSAGv/MhON8iSYOQj28LVKU02hxk/img.jpg]

            펫시루리 컬러연습

            "[image]":[https://blog.kakaocdn.net/dn/bN0IZK/btsFg4hsH0k/HPQu7VKzcc76ZcKGe9uI00/img.jpg]

            유영하는 하늘치

            "[image]":[https://blog.kakaocdn.net/dn/wvnz7/btsFeDebtSp/3zkC1EBrtnufPbGTfp2D90/img.jpg]

            young핸

            "[image]":[https://blog.kakaocdn.net/dn/biaXrk/btsFefq3Y8k/YYadjg46g5ui1xzeY06GKk/img.jpg]

            아실과 정우

            "[image]":[https://blog.kakaocdn.net/dn/c0eTqX/btsFhrwKq7f/019A9D6UCmkzcG1hgZN7l1/img.jpg]

            (이하생략)
          EOS
        )
      end

      context "A name.tistory.com/entry/:title post URL" do
        strategy_should_work(
          "https://caswac1.tistory.com/entry/용사의-선택지가-이상하다",
          image_urls: %w[
            https://blog.kakaocdn.net/dn/b8iLMZ/btsHBTMBxvX/zv0Hdk0nHkqlg9J41JrOa0/img.jpg
            https://blog.kakaocdn.net/dn/cNbA4f/btsHBR88Bl0/0tUxQg0CUsHuMJJmzM5gvk/img.jpg
            https://blog.kakaocdn.net/dn/cm7NI7/btsHEalnR5R/nkQqHPJtPbxSwCZf2Z2jaK/img.jpg
            https://blog.kakaocdn.net/dn/bN01v2/btsHD7a68lq/T2DfJjRr6IEoyVjN7gszEK/img.jpg
            https://blog.kakaocdn.net/dn/dWEPvQ/btsHDOiy486/sgyjspMvSRI0di52xGKwvK/img.jpg
            https://blog.kakaocdn.net/dn/W04yO/btsHDxOU7Qx/yEMRxeEkzCFIS6lmIUylm0/img.jpg
          ],
          media_files: [
            { file_size: 50_909 },
            { file_size: 48_738 },
            { file_size: 35_795 },
            { file_size: 43_798 },
            { file_size: 52_490 },
            { file_size: 39_534 },
          ],
          page_url: "https://caswac1.tistory.com/385",
          profile_urls: %w[https://caswac1.tistory.com],
          display_name: "caswc",
          username: "caswac1",
          tags: [],
          dtext_artist_commentary_title: "용사의 선택지가 이상하다",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://blog.kakaocdn.net/dn/b8iLMZ/btsHBTMBxvX/zv0Hdk0nHkqlg9J41JrOa0/img.jpg]

            "[image]":[https://blog.kakaocdn.net/dn/cNbA4f/btsHBR88Bl0/0tUxQg0CUsHuMJJmzM5gvk/img.jpg]

            "[image]":[https://blog.kakaocdn.net/dn/cm7NI7/btsHEalnR5R/nkQqHPJtPbxSwCZf2Z2jaK/img.jpg]

            "[image]":[https://blog.kakaocdn.net/dn/bN01v2/btsHD7a68lq/T2DfJjRr6IEoyVjN7gszEK/img.jpg]

            "[image]":[https://blog.kakaocdn.net/dn/dWEPvQ/btsHDOiy486/sgyjspMvSRI0di52xGKwvK/img.jpg]

            "[image]":[https://blog.kakaocdn.net/dn/W04yO/btsHDxOU7Qx/yEMRxeEkzCFIS6lmIUylm0/img.jpg]

            원문판 : <https://www.freem.ne.jp/win/game/29845>
            한국어판 : <https://drive.google.com/file/d/1y9qVEkSFg4i12CW_sZZ12WDP8COhqzZt/view?usp=sharing>

            테스트 : 유리프, 엔코돌리, 우두둑, 마력이 없어

            본 게임은 전7화 예정으로 현재까지 공개된 5화만 번역됐습니다.

            많은 선택지(이상한 것도 있음)를 선택하여 앞으로 향하는 어드벤처 게임!

            『어떤 붉은 달이 빛나는 세상의 이야기』

            이건 다양한 선택지 중에서 행동을 선택하고
            앞으로 나아가는 어드벤처 게임입니다.

            현재 5화까지 공개 중입니다.
            총 7화 예정입니다.

            6화로 가는 길 : 1
            노멀 엔딩 수 : 24

            ーーーーーーーーーーーーーーーー
            조작방법
            ■결정：Z키 or 탭
            ■취소：X키 or 윈도우 바깥을 탭

            아래는 화면에 표시된 문자를 클릭하는 것만으로도 같은 조작을 할 수 있습니다.
            ■세이브：shift 키 or 오른쪽 클릭 or 두 손가락 탭
            ■로드…ctrl키
            ■스킵…S키
            ■오토…A키
            ■옵션…tab키
            ■게임 종료…Q키

            세이브는 언제든지 원할 때 할 수 있습니다.
            ※세이브 타이밍에 따라서는 막히는 경우가 있습니다. 선택지가 표시된 타이밍에 세이브하거나 세이브를 자주 나누길 권장합니다.

            ーーーーーーーーーーーーーーーー
            갤러리에 대해서:
            갤러리 일러스트가 추가되는 타이밍은 우측 하단에 세이브 된 표시가 나왔을 때 or 주도적으로 세이브 했을 때입니다.(추가되는 타이밍에 다소의 렉이 발생할 수 있습니다.)
            ーーーーーーーーーーーーーーーー

            ☆실황·생방송에 대해
            자유롭게 하세요! 특별한 금지사항은 없습니다. (동영상의 수익화 등도 가능) 보고도 필요 없습니다.
            ※비방중상은 삼가주세요.

            ☆ 2차 창작, SNS 등을 통한 게임 내 스크린샷 이미지 공개에 대해
            자유롭게 하세요! 특별한 금지사항은 없습니다. 보고도 필요 없습니다.
            ※ 비방중상은 삼가주세요.

            ☆ 뭔가 의문점, 용건 등이 있는 분은 이쪽으로 부탁드립니다.

            mail：3710.nezumi@gmail.com

            갱신 정보
            2023/2/3 ver0.3.08 SE 데이터의 영향으로 에러가 출현하는 버그를 수정.
            2023/1/24 ver0.3.07 『용사의 선택지가 이상하다』 ver0.3.07 공개.
          EOS
        )
      end

      context "A post with external embedded images" do
        strategy_should_work(
          "https://stella-krysmas.tistory.com/6",
          image_urls: %w[https://t1.daumcdn.net/cfile/tistory/99EE76395C27CAF80B?original],
          media_files: [{ file_size: 74_214 }],
          page_url: "https://stella-krysmas.tistory.com/6",
          profile_urls: %w[https://stella-krysmas.tistory.com],
          display_name: "딤라이트",
          username: "stella-krysmas",
          tags: [
            ["COLOURFUL", "https://stella-krysmas.tistory.com/tag/COLOURFUL"],
            ["창작", "https://stella-krysmas.tistory.com/tag/창작"],
          ],
          dtext_artist_commentary_title: "[창작 애니메이션] COLOURFUL",
          dtext_artist_commentary_desc: <<~EOS.chomp
            <https://www.youtube.com/embed/CmW8zXZzBKk>

            졸업작품 《컬러풀》.

            나에 대해서

            나의 색깔에 대해서

            조금쯤은 생각해볼 수 있다면 참 좋겠구나.

            같은 이유로 고민하는 사람들에게,

            작은 위로가 될 수 있다면 참 좋겠구나.

            의미가 참 많다. 나라는 사람을 되돌아보던 시간.

            울기도 참 많이 울었고 화내기도 참 많이 화냈고

            내가 제일 좋아하는 건 나였고 내가 제일 싫어하던 것도 나였던 그 때.

            많이도 상처 입고 상처를 입혔지만 그래도 나는 내가 제일 좋아하는 쓰레기야.

            "[image]":[https://pbs.twimg.com/media/DFVrVsXVYAA7CwJ.jpg:orig]

            목소리 아쉽다. 보이스 넣고 싶었는데 댓글에는 보이스 없어서 오히려 좋다는 게 많이 보여서

            싱숭생숭.

            내용을 이해 못하겠다는 댓글도. 뭐 이것저것 많았는데. 첫작이니까요.

            적어도 구리다고 욕은 안해줘서 기쁘고. 이만큼 사랑받는 것도 기쁘고. 아무튼 그래.

            "[image]":[https://t1.daumcdn.net/cfile/tistory/99EE76395C27CAF80B?original]

            그리고 아무리 생각해도 RMIT 애니과는 참 좆같다.

            유이한 의의는 TVP를 쓸 줄 알게 되었다는 것과

            후르같은 이쁜 애와 함께 울고 웃었다는 것.
          EOS
        )
      end

      context "A post with t1.daumcdn.net/cfile/tistory/:id images" do
        strategy_should_work(
          "https://stella-krysmas.tistory.com/13",
          image_urls: %w[
            https://t1.daumcdn.net/cfile/tistory/99A3CF4B5C2AFDF806?original
            https://t1.daumcdn.net/cfile/tistory/99C3F84B5C2AFDFD05?original
            https://t1.daumcdn.net/cfile/tistory/999DE84B5C2AFE113F?original
            https://t1.daumcdn.net/cfile/tistory/99FF764B5C2AFE1D0C?original
            https://t1.daumcdn.net/cfile/tistory/995C07345C2B069613?original
            https://t1.daumcdn.net/cfile/tistory/99059F405C2B078014?original
            https://t1.daumcdn.net/cfile/tistory/9938B1485C2B0CA223?original
          ],
          media_files: [
            { file_size: 168_309 },
            { file_size: 545_674 },
            { file_size: 5_873_963 },
            { file_size: 1_886_370 },
            { file_size: 9_851_352 },
            { file_size: 2_049_491 },
            { file_size: 5_371_728 },
          ],
          page_url: "https://stella-krysmas.tistory.com/13",
          profile_urls: %w[https://stella-krysmas.tistory.com],
          display_name: "딤라이트",
          username: "stella-krysmas",
          tags: [
            ["나루토", "https://stella-krysmas.tistory.com/tag/나루토"],
            ["리그오브레전드", "https://stella-krysmas.tistory.com/tag/리그오브레전드"],
            ["마법진구루구루", "https://stella-krysmas.tistory.com/tag/마법진구루구루"],
            ["신데렐라걸즈", "https://stella-krysmas.tistory.com/tag/신데렐라걸즈"],
            ["아이돌마스터", "https://stella-krysmas.tistory.com/tag/아이돌마스터"],
            ["우에키의법칙", "https://stella-krysmas.tistory.com/tag/우에키의법칙"],
            ["팬아트", "https://stella-krysmas.tistory.com/tag/팬아트"],
            ["헌터X헌터", "https://stella-krysmas.tistory.com/tag/헌터X헌터"],
            ["혈계전선", "https://stella-krysmas.tistory.com/tag/혈계전선"],
          ],
          dtext_artist_commentary_title: "[팬아트] 이것저것 움짤들",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://t1.daumcdn.net/cfile/tistory/99A3CF4B5C2AFDF806?original]

            지옥의 크오충은 좋아하는 초록이들을 한 화면에 넣고싶었나봐요

            "[image]":[https://t1.daumcdn.net/cfile/tistory/99C3F84B5C2AFDFD05?original]

            내사랑 공기쨩에게 리퀘받았던 것.

            당시의 공기쨩: 가위바위보 하는 키르곤 그려주세요!

            나: 내 ^^ (움짤쪄옴)

            공기쨩: ?????????

            "[image]":[https://t1.daumcdn.net/cfile/tistory/999DE84B5C2AFE113F?original]

            티모트리는..."찐"이다...

            이거 헌사이클로피디아 패러디 맞음

            "[image]":[https://t1.daumcdn.net/cfile/tistory/99FF764B5C2AFE1D0C?original]

            놀랍게도 빛무리쨩은 느즈막히 나루터도 판 적이 있는 것이다

            그때는 지라이야를 참 좋아했었다 ㅠㅠ

            "[image]":[https://t1.daumcdn.net/cfile/tistory/995C07345C2B069613?original]

            ※이 사람은 이거 만들 때 과제의 노예였습니다.

            지금도 크라우스 죽도록 사랑해

            "[image]":[https://t1.daumcdn.net/cfile/tistory/99059F405C2B078014?original]

            쿠쿠리쨩 내새꾸

            "[image]":[https://t1.daumcdn.net/cfile/tistory/9938B1485C2B0CA223?original]
          EOS
        )
      end

      context "A password-protected post" do
        strategy_should_work(
          "http://lamoncandy1248.tistory.com/16",
          image_urls: [],
          page_url: "https://lamoncandy1248.tistory.com/16",
          profile_urls: %w[https://lamoncandy1248.tistory.com],
          display_name: "래몬사탕",
          username: "lamoncandy1248",
          tags: [],
          dtext_artist_commentary_title: "세리카 성장 뭐 그런거",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent post" do
        strategy_should_work(
          "https://primemeeting.tistory.com/9999",
          image_urls: [],
          page_url: "https://primemeeting.tistory.com/9999",
          profile_urls: %w[https://primemeeting.tistory.com],
          display_name: nil,
          username: "primemeeting",
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "For a custom domain:" do
        context "A page URL" do
          strategy_should_work(
            "https://panchokworkshop.com/520",
            image_urls: %w[https://blog.kakaocdn.net/dn/S2xgM/btsdPLPqB9a/dE5Z7C9TuybOkAUOL0btf0/img.jpg],
            media_files: [{ file_size: 160_368 }],
            page_url: "https://panchokworkshop.com/520",
            profile_urls: %w[https://panchokworkshop.com],
            display_name: "거친펜촉",
            username: nil,
            tags: [
              ["panchokworkshop", "https://panchokworkshop.com/tag/panchokworkshop"],
              ["거친펜촉", "https://panchokworkshop.com/tag/거친펜촉"],
              ["그림방송", "https://panchokworkshop.com/tag/그림방송"],
              ["일러스트", "https://panchokworkshop.com/tag/일러스트"],
              ["포토샵", "https://panchokworkshop.com/tag/포토샵"],
            ],
            dtext_artist_commentary_title: "202110 Mask",
            dtext_artist_commentary_desc: <<~EOS.chomp
              "[image]":[https://blog.kakaocdn.net/dn/S2xgM/btsdPLPqB9a/dE5Z7C9TuybOkAUOL0btf0/img.jpg]

              2023
            EOS
          )
        end

        context "A daumcdn.net image URL with a referer" do
          strategy_should_work(
            "https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FS2xgM%2FbtsdPLPqB9a%2FdE5Z7C9TuybOkAUOL0btf0%2Fimg.jpg",
            referer: "https://panchokworkshop.com/520",
            image_urls: %w[https://blog.kakaocdn.net/dn/S2xgM/btsdPLPqB9a/dE5Z7C9TuybOkAUOL0btf0/img.jpg],
            media_files: [{ file_size: 160_368 }],
            page_url: "https://panchokworkshop.com/520",
            profile_urls: %w[https://panchokworkshop.com],
            display_name: "거친펜촉",
            username: nil,
            tags: [
              ["panchokworkshop", "https://panchokworkshop.com/tag/panchokworkshop"],
              ["거친펜촉", "https://panchokworkshop.com/tag/거친펜촉"],
              ["그림방송", "https://panchokworkshop.com/tag/그림방송"],
              ["일러스트", "https://panchokworkshop.com/tag/일러스트"],
              ["포토샵", "https://panchokworkshop.com/tag/포토샵"],
            ],
            dtext_artist_commentary_title: "202110 Mask",
            dtext_artist_commentary_desc: <<~EOS.chomp
              "[image]":[https://blog.kakaocdn.net/dn/S2xgM/btsdPLPqB9a/dE5Z7C9TuybOkAUOL0btf0/img.jpg]

              2023
            EOS
          )
        end

        context "A kakaocdn.net image URL with a referer" do
          strategy_should_work(
            "https://blog.kakaocdn.net/dn/S2xgM/btsdPLPqB9a/dE5Z7C9TuybOkAUOL0btf0/img.jpg",
            referer: "https://panchokworkshop.com/520",
            image_urls: %w[https://blog.kakaocdn.net/dn/S2xgM/btsdPLPqB9a/dE5Z7C9TuybOkAUOL0btf0/img.jpg],
            media_files: [{ file_size: 160_368 }],
            page_url: "https://panchokworkshop.com/520",
            profile_urls: %w[https://panchokworkshop.com],
            display_name: "거친펜촉",
            username: nil,
            tags: [
              ["panchokworkshop", "https://panchokworkshop.com/tag/panchokworkshop"],
              ["거친펜촉", "https://panchokworkshop.com/tag/거친펜촉"],
              ["그림방송", "https://panchokworkshop.com/tag/그림방송"],
              ["일러스트", "https://panchokworkshop.com/tag/일러스트"],
              ["포토샵", "https://panchokworkshop.com/tag/포토샵"],
            ],
            dtext_artist_commentary_title: "202110 Mask",
            dtext_artist_commentary_desc: <<~EOS.chomp
              "[image]":[https://blog.kakaocdn.net/dn/S2xgM/btsdPLPqB9a/dE5Z7C9TuybOkAUOL0btf0/img.jpg]

              2023
            EOS
          )
        end
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://t1.daumcdn.net/cfile/tistory/99A3CF4B5C2AFDF806"))
        assert(Source::URL.image_url?("https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FRA1tu%2FbtsFf2xGLbg%2FVzHK4tqMEWkeqUgDBxSkkK%2Fimg.jpg"))
        assert(Source::URL.image_url?("https://blog.kakaocdn.net/dn/RA1tu/btsFf2xGLbg/VzHK4tqMEWkeqUgDBxSkkK/img.jpg"))
        assert(Source::URL.image_url?("http://cfile9.uf.tistory.com/image/1935713C4E8B51B0165990"))
        assert(Source::URL.image_url?("http://cfs7.tistory.com/original/33/tistory/2008/09/17/19/46/48d0dfec46aca"))
        assert(Source::URL.image_url?("http://cfs2.tistory.com/upload_control/download.blog?fhandle=YmxvZzQ2ODg4QGZzMi50aXN0b3J5LmNvbTovYXR0YWNoLzAvMjkuanBn"))

        assert(Source::URL.page_url?("https://primemeeting.tistory.com/25"))
        assert(Source::URL.page_url?("https://primemeeting.tistory.com/m/25"))
        assert(Source::URL.page_url?("https://caswac1.tistory.com/entry/용사의-선택지가-이상하다"))
        assert(Source::URL.page_url?("https://caswac1.tistory.com/m/entry/용사의-선택지가-이상하다"))

        assert(Source::URL.profile_url?("https://primemeeting.tistory.com"))
        assert(Source::URL.profile_url?("https://primemeeting.tistory.com/m"))
      end
    end
  end
end
