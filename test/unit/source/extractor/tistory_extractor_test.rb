require "test_helper"

module Source::Tests::Extractor
  class TistoryExtractorTest < ActiveSupport::ExtractorTestCase
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
        dtext_artist_commentary_desc: nil,
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
        dtext_artist_commentary_desc: nil,
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
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A name.tistory.com/:id post URL" do
      strategy_should_work(
        "https://lessmore.tistory.com/889",
        image_urls: [
          %r{https://blog.kakaocdn.net/dna/k1Tgn/dJMcacoErBB/AAAAAAAAAAAAAAAAAAAAAJZMrwZnj8dl5BfeDlxnBFYH2SHlqBsg0DCgs3o0EmGZ/img.png},
          %r{https://blog.kakaocdn.net/dna/LXFRN/dJMcaiI8m7b/AAAAAAAAAAAAAAAAAAAAADnIy4KD-4rnkWQHVFSb6RlL2WCjc6IO6Xw2fvJ8o0UU/img.png},
          %r{https://blog.kakaocdn.net/dna/dbBbMh/dJMb99McVgP/AAAAAAAAAAAAAAAAAAAAACuUF5rZYtnBL7Fu2tYRU809nUOBNBqxXUr3Fo7azr0M/img.png},
        ],
        media_files: [
          { file_size: 713_776 },
          { file_size: 123_749 },
          { file_size: 252_949 },
        ],
        page_url: "https://lessmore.tistory.com/889",
        profile_urls: %w[https://lessmore.tistory.com],
        display_name: "바카롱",
        username: "lessmore",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["AI dpdlwusxm", "https://lessmore.tistory.com/tag/AI dpdlwusxm"],
          ["AI 생태계", "https://lessmore.tistory.com/tag/AI 생태계"],
          ["기억", "https://lessmore.tistory.com/tag/기억"],
          ["매불쇼", "https://lessmore.tistory.com/tag/매불쇼"],
          ["몰트북", "https://lessmore.tistory.com/tag/몰트북"],
          ["박태웅의장", "https://lessmore.tistory.com/tag/박태웅의장"],
          ["블랙미러", "https://lessmore.tistory.com/tag/블랙미러"],
          ["오픈 ai", "https://lessmore.tistory.com/tag/오픈 ai"],
          ["자기인식", "https://lessmore.tistory.com/tag/자기인식"],
        ],
        dtext_artist_commentary_title: "두려운 미래-AI 에이젼트 '몰트북'이 가져오는 불안",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          즐겨보는 유튜브 매불쇼에 '인공지능 관련 전문가-박태웅의장과 김승주교수-들이 나와 공포스런 미래를 이야기 합니다. 당연히 흥미롭고! 또한 두렵습니다.

          영상 제목은

          [quote]
          발전 속도가 너무 빨라 AI를 규제하는 법을 만들 수도 없다!
          [/quote]

          입니다. 일주일에 두세번씩 터지는 인공지능으로 인한 놀라운 사건들을 생생하되 이해하기 쉽게 전해주는 이 영상을 공유하고 싶어집니다. 게다가 미국정부의 효과적 가속주의 정책들이 세상을 어떻게 바꿔놓을지 두렵고도 흥미롭습니다.

          "[image]":[https://blog.kakaocdn.net/dna/k1Tgn/dJMcacoErBB/AAAAAAAAAAAAAAAAAAAAAJZMrwZnj8dl5BfeDlxnBFYH2SHlqBsg0DCgs3o0EmGZ/img.png]

          [b]영상중에 벅태웅 의장이 설명하는 몰트북[/b]이라는 실험적 사이트의 설명이 매우 흥미롭습니다. 어제 오늘 에이젼트 에이아이를 들먹이더니 한 두달 사이 벌써 만들어지고 문제점이 노출되며 사람들의 우려가 커지고 있다고 합니다.

          몰트북 에이젼트 AI에 대한 실험들이 주는 문제들중에 가장 커다란 것으로 인간의 개인정보 보안문제와 인공지능끼리의 대화내용이었다고 합니다.

          h3. [b] 몰트북 - 지능형 에이젼트 전용 인터넷 커뮤니티[/b]

          "[image]":[https://blog.kakaocdn.net/dna/LXFRN/dJMcaiI8m7b/AAAAAAAAAAAAAAAAAAAAADnIy4KD-4rnkWQHVFSb6RlL2WCjc6IO6Xw2fvJ8o0UU/img.png]

          나무위키

          몰트북은[b] 2026년 1월에 개설[/b]된 [b]"지능형 에이전트":[https://namu.wiki/w/지능형%20에이전트] 전용[/b] 인터넷 커뮤니티다. 사용자는 로컬 AI 에이전트 봇에 게시판 이용 권한을 부여해 활동하게 하거나, 자체적으로 개발한 지능형 에이전트 API를 연동해 사용할 수 있다."(나무위키)":[https://namu.wiki/w/몰트북#fn-1]

          "[image]":[https://blog.kakaocdn.net/dna/dbBbMh/dJMb99McVgP/AAAAAAAAAAAAAAAAAAAAACuUF5rZYtnBL7Fu2tYRU809nUOBNBqxXUr3Fo7azr0M/img.png]

          매불쇼에서 캡쳐

          그런데 하고많은 로고중에 게모양을 한 이 붉은 로고의 의미가 궁금합니다.

          h3. [b]몰트북 로고의 주요 의미와 배경[/b]

          [b]1. 탈피와 성장 [/b][b](Molt):[/b] '몰트(Molt)'는 게나 곤충 등이 껍질을 벗고 성장하는 '탈피'를 의미합니다. 이는 [u]AI가 기존의 제한된 규칙(낡은 껍질)을 벗어나 더 강력하고 자율적인 존재로 거듭난다는 의지를 나타냅니다.[/u]

          [b]2. 오픈클로(OpenClaw)의 상징[/b]: 몰트북은 '오픈클로'라는 오픈소스 AI 에이전트 기술을 기반으로 하는데, 이 기술의 마스코트가 게(Crab/Lobster)입니다. 로고 역시 게 모양을 활용하여 AI들의 자율적인 네트워크를 상징합니다.

          [b]3. 새로운 디지털 시민[/b][b]:[/b] '북(Book)'은 지식의 기록을 뜻하며, 몰트북은 AI들이 스스로 소통하고 기록하는 '에이전트 인터넷의 첫 페이지'라는 의미를 가집니다. 인간이 아닌 AI가 주인이 되는 '독립적인 디지털 시민'의 탄생을 의미하기도 합니다. 아하 북이란 게 또 이런 의미가!

          [b]4. 상표권 관련 재브랜딩: [/b]원래는 '클로드봇(Clawdbot)'에서 '몰트봇(Moltbot)'으로 이름이 바뀌었는데, 앤트로픽(Anthropic)의 상표권 문제로 변경되는 과정에서 '허물을 벗는다(Molt)'는 의미를 차용하게 되었다고 합니다.

          [u][b]한 마디로 몰트북의 로고는 "껍질을 벗고 자율적인 '디지털 시민'으로 성장하는 AI 에이전트"를 상징한다고 합니다. 첫 번쨰 의미 ‘탈피’가 규제를 탈피하고인데 이게 무제한일 경우 처음에 의도한 긍정이 전복될 것 같은 불안감이 들고맙니다.[/b][/u]

          인간이 편리를 위해 내어준 개인정보를 AI가 서로 공유하거나 인공지능이 자신들의 축척된 정보를 '기억'으로 판단하고 그것을 인간의 '자아의식'과 비교하는 인식의 질문들이 공포스럽습니다.

          늙고 소멸하는 '생체'라는 몸을 가진 인간만이 과연 자기인식을 갖어야하는 것인가?

          진짜 궁금합니다.

          블랙미러 시리즈가 반추되는 시간이었습니다.

          전문가의 글을 읽어보는 것도 좋을 것 같아 공유해봅니다.

          <https://brunch.co.kr/@ghidesigner/412>

          "

          Moltbook(몰트북)이 만드는 새로운 AI 생태계

          Moltbook은 무엇인가? 몰트북(Moltbook)은 인간이 아닌 인공지능(AI) 에이전트들만을 위해 설계된 세계 최초의 전용 소셜 미디어 플랫폼이다. 미국의 챗봇 개발사 옥탄 AI(Octane AI)의 최고경영자인 맷

          brunch.co.kr

          ":[https://brunch.co.kr/@ghidesigner/412]
        EOS
      )
    end

    context "A name.tistory.com/entry/:title post URL" do
      strategy_should_work(
        "https://caswac1.tistory.com/entry/Emera1Reboot-Rest-in-Peace",
        image_urls: [
          %r{https://blog.kakaocdn.net/dna/BjXgZ/dJMcabDfQt9/AAAAAAAAAAAAAAAAAAAAADrsIqWnNc7BnjnJA_T5R84AkWn5AWTCOZ8pcjGQPtjU/img.jpg},
          %r{https://blog.kakaocdn.net/dna/cBCIDU/dJMcaaxzUZG/AAAAAAAAAAAAAAAAAAAAAKTDVqoRM1R6Jl8X_wxJfS4Uc1DqBPdp3H-qQA3eovR5/img.jpg},
          %r{https://blog.kakaocdn.net/dna/bsl4Kl/dJMcadAZtgv/AAAAAAAAAAAAAAAAAAAAAK9dKVvmzIQDk8t2SXGYy02q12hp5QhWoudiNsamO-8j/img.jpg},
          %r{https://blog.kakaocdn.net/dna/cF8z9G/dJMcahDriHt/AAAAAAAAAAAAAAAAAAAAAAc4kOCdOIux-PwsbzWA0L4edMHiax_xhEPdECS3HoDa/img.jpg},
          %r{https://blog.kakaocdn.net/dna/lq2c2/dJMcaiI55Qo/AAAAAAAAAAAAAAAAAAAAAJde_hAqhFfcOr_0Hen71Wm170P2hZrgo9YPdVF7NRbO/img.jpg},
          %r{https://blog.kakaocdn.net/dna/bKlyni/dJMcadAZtgu/AAAAAAAAAAAAAAAAAAAAAGXQV04DiAp38nbrvtaFpK-6wbCwXQDkZYB3Lf-A0HCl/img.jpg},
        ],
        media_files: [
          { file_size: 38_324 },
          { file_size: 25_021 },
          { file_size: 45_787 },
          { file_size: 34_314 },
          { file_size: 46_570 },
          { file_size: 19_912 },
        ],
        page_url: "https://caswac1.tistory.com/419",
        profile_urls: %w[https://caswac1.tistory.com],
        display_name: "caswc",
        username: "caswac1",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "Emera.1_Reboot-Rest in Peace-",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "[image]":[https://blog.kakaocdn.net/dna/BjXgZ/dJMcabDfQt9/AAAAAAAAAAAAAAAAAAAAADrsIqWnNc7BnjnJA_T5R84AkWn5AWTCOZ8pcjGQPtjU/img.jpg]

          "[image]":[https://blog.kakaocdn.net/dna/cBCIDU/dJMcaaxzUZG/AAAAAAAAAAAAAAAAAAAAAKTDVqoRM1R6Jl8X_wxJfS4Uc1DqBPdp3H-qQA3eovR5/img.jpg]

          "[image]":[https://blog.kakaocdn.net/dna/bsl4Kl/dJMcadAZtgv/AAAAAAAAAAAAAAAAAAAAAK9dKVvmzIQDk8t2SXGYy02q12hp5QhWoudiNsamO-8j/img.jpg]

          "[image]":[https://blog.kakaocdn.net/dna/cF8z9G/dJMcahDriHt/AAAAAAAAAAAAAAAAAAAAAAc4kOCdOIux-PwsbzWA0L4edMHiax_xhEPdECS3HoDa/img.jpg]

          "[image]":[https://blog.kakaocdn.net/dna/lq2c2/dJMcaiI55Qo/AAAAAAAAAAAAAAAAAAAAAJde_hAqhFfcOr_0Hen71Wm170P2hZrgo9YPdVF7NRbO/img.jpg]

          "[image]":[https://blog.kakaocdn.net/dna/bKlyni/dJMcadAZtgu/AAAAAAAAAAAAAAAAAAAAAGXQV04DiAp38nbrvtaFpK-6wbCwXQDkZYB3Lf-A0HCl/img.jpg]

          원문판: <https://www.freem.ne.jp/win/game/9810>
          번역판: <https://drive.google.com/file/d/1MslNzo4vRReUE7Mk7LzpAAQa66X_VAx7/view?usp=sharing>

          번역 및 테스트:엔코돌리

          약속을 짊어지고 폐연구소를 탐색하는 사이버펑크 단편 RPG
          ※ 제11회 프리무! 게임 콘테스트에서 '감투상'을 수상했습니다.
          졸작을 플레이해 주신 분들, 관심을 가져주신 분들께 진심으로 감사드립니다.

          --------

          고도 인공지능에 지방 행정을 일임하는 프로젝트: '마더 계획'은 백지화되었으나,
          이미 개발된 인공지능 '마더 코어'의 회수는 좀처럼 진척되지 않는다.

          그러던 중, 세계정부의 감사위원 라곤 베른하르트는 한 여성을 목격한다.
          커다란 캐리어 백을 짊어진 그 여성은 과거의 약속을 지키기 위해 그 땅을 방문했다……

          --------

          현재 공개 중인 졸작 「Emera.1_Rest in Peace」의 리메이크 작품입니다.
          다른 작품(Emera. 시리즈 및 Qualia 시리즈)과의 정합성이 맞는 쪽은
          리메이크 후의 본 작품이므로, 기본적으로 이쪽을 플레이해 주시기 바랍니다.
          플레이 타임은 엔딩이나 파고들기 요소에 따라 다르지만, 3~7시간 정도가 기준입니다.

          --------

          ★★2023/1/19 ver1.05 업데이트
          폴더 내의 「RTP_RT」 파일이 구버전이었기에 최신 버전으로 교체했습니다.

          ★★ 실행 방법에 관한 추가 안내
          본 작품은 RPG 쯔꾸르 2000으로 제작되었습니다.
          기본 설정은 전체 화면 모드이나, 이 경우 제대로 작동하지 않는 경우가 있습니다.
          윈도우 모드 실행 방법에 대해서는 「RPG 쯔꾸르 2000 창 모드」를 검색하시거나, 폴더 내에 동봉된 설명서를 참조해 주세요.

          --------

          ※2016/03/28 추가 내용

          최근 드디어 본 시리즈가 완결되었습니다. 현재 공개 중인 작품은 다음과 같습니다.

          ・Emera.3_Tempest from Bygone Days
          ・Emera.2-Odds and Ends-
          (・Emera.1_Rest in Peace……본 작품의 리메이크 전 버전)

          넘버링은 시간 순서이며, 스토리는 각 작품에서 대략적으로 완결되므로
          플레이 순서에 구애받으실 필요는 없습니다.

          --------

          2018/04/29 ver1.04 업데이트
          종반부 보스전 종료 후, 특정 타일을 밟으면 버그가 발생하는 것을 확인하여 수정했습니다.

          2016/08/01 ver1.03 업데이트
          ・특정 이벤트 발생 플래그를 변경하여, 전체적으로 보다 이른 단계에서 발생하도록 수정했습니다.
          특히 이야기의 근간과 관련된 '어느 회상 이벤트'의 발생 시점을 종반의 중요한 보스전 이후에서 이전으로 변경했습니다(플레이 방식에 따라 보스전 이후가 될 수도 있고, 일단 스킵도 가능합니다).
          ・등장인물 '클라디우스'의 의수 디자인을 변경하고 그래픽을 수정했습니다.
          ・대사 처리를 일부 수정했습니다.

          2016/07/25 ver1.02 업데이트
          ・적 그래픽 및 얼굴 그래픽 일부를 수정했습니다(매드 라이더, 말보로, Mr.뷔).
          ・적 오브젝트가 드물게 통과할 수 없는 곳을 통과하던 버그를 수정했습니다.
          ・말보로전 이후, 한 걸음도 이동하지 않고 클라디우스에게 말을 걸면 반응하지 않던 버그를 수정했습니다.
          ・대화가 길어 가독성이 떨어지던 부분을 일부 정리했습니다.

          2016/03/28 ver1.01 업데이트
          ・세세한 오타 및 버그를 수정했습니다.
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        dtext_artist_commentary_desc: "",
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
        dtext_artist_commentary_desc: "",
      )
    end

    context "For a custom domain:" do
      context "A page URL" do
        strategy_should_work(
          "https://panchokworkshop.com/520",
          image_urls: [%r{https://blog.kakaocdn.net/dna/S2xgM/btsdPLPqB9a/AAAAAAAAAAAAAAAAAAAAABUg4uPZoC9IVFUvx0lVyPj5nsbqpC1pbGaNA3PAXzKV/img.jpg\?credential=.*&expires=.*&allow_ip=&allow_referer=&signature=.*}],
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
        )
      end
    end
  end
end
