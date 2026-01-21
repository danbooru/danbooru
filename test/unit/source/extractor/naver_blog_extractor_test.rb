require "test_helper"

module Source::Tests::Extractor
  class NaverBlogExtractorTest < ActiveSupport::ExtractorTestCase
    context "A blogthumb.pstatic.net sample image URL" do
      strategy_should_work(
        "https://blogthumb.pstatic.net/MjAyMzA3MTFfMjkz/MDAxNjg5MDQ2NTMwMTkw.2bAkaa4r8P5vcbpyyNH3X5ysDig6q_sJ2llYrNHQ_3Ag.7b3Pxl-DcaqTAM69oiYsGHGWKOlgwWXp5BbOpVDZ98Ag.PNG.kkid9624/230623%C6%F7%B5%F0%BE%C6%B4%D4.PNG?type=w2",
        image_urls: %w[http://blogfiles.naver.net/MjAyMzA3MTFfMjkz/MDAxNjg5MDQ2NTMwMTkw.2bAkaa4r8P5vcbpyyNH3X5ysDig6q_sJ2llYrNHQ_3Ag.7b3Pxl-DcaqTAM69oiYsGHGWKOlgwWXp5BbOpVDZ98Ag.PNG.kkid9624/230623%C6%F7%B5%F0%BE%C6%B4%D4.PNG],
        media_files: [{ file_size: 69_205 }],
        page_url: nil,
      )
    end

    context "A postfiles.pstatic.net sample image URL" do
      strategy_should_work(
        "https://postfiles.pstatic.net/MjAyNDA0MjBfMzQg/MDAxNzEzNjIyMjM5MjY1.bA-t3pRhCcZ6t4TJKGCChhTFaO-ddv9m1tyLcdMW-4Ug.KvTzrwFNrFuB9AgQYuk0dBIGwAzeg1c3QVSrXC7TeB0g.PNG/240420%ED%91%B8%EB%A5%B4%EB%8A%AC%EB%8B%98_2.png?type=w966",
        image_urls: %w[http://blogfiles.naver.net/MjAyNDA0MjBfMzQg/MDAxNzEzNjIyMjM5MjY1.bA-t3pRhCcZ6t4TJKGCChhTFaO-ddv9m1tyLcdMW-4Ug.KvTzrwFNrFuB9AgQYuk0dBIGwAzeg1c3QVSrXC7TeB0g.PNG/240420푸르늬님_2.png],
        media_files: [{ file_size: 8_644_035 }],
        page_url: nil,
      )
    end

    context "A blogpfthumb-phinf.pstatic.net sample image URL" do
      strategy_should_work(
        "https://blogpfthumb-phinf.pstatic.net/MjAyMzAzMThfMzIg/MDAxNjc5MDY4MjkxNzUz.ODdLT6VGaauXq9_jT-TpO878xZ--5lv0llIDclJvvTYg.yqLsxucKuBCz-auOTjpX2RRyLV_0WLCcBwb206KeCSIg.PNG.kkid9624/%EC%A0%9C%EB%B3%B8.PNG/%25EC%25A0%259C%25EB%25B3%25B8.PNG?type=s1",
        image_urls: %w[https://blogpfthumb-phinf.pstatic.net/MjAyMzAzMThfMzIg/MDAxNjc5MDY4MjkxNzUz.ODdLT6VGaauXq9_jT-TpO878xZ--5lv0llIDclJvvTYg.yqLsxucKuBCz-auOTjpX2RRyLV_0WLCcBwb206KeCSIg.PNG.kkid9624/제본.PNG/%25EC%25A0%259C%25EB%25B3%25B8.PNG],
        media_files: [{ file_size: 1_104_897 }],
        page_url: nil,
      )
    end

    context "A blogfiles.pstatic.net full image URL" do
      strategy_should_work(
        "http://blogfiles.pstatic.net/MjAyNDA0MjBfMzQg/MDAxNzEzNjIyMjM5MjY1.bA-t3pRhCcZ6t4TJKGCChhTFaO-ddv9m1tyLcdMW-4Ug.KvTzrwFNrFuB9AgQYuk0dBIGwAzeg1c3QVSrXC7TeB0g.PNG/240420푸르늬님_2.png",
        image_urls: %w[http://blogfiles.naver.net/MjAyNDA0MjBfMzQg/MDAxNzEzNjIyMjM5MjY1.bA-t3pRhCcZ6t4TJKGCChhTFaO-ddv9m1tyLcdMW-4Ug.KvTzrwFNrFuB9AgQYuk0dBIGwAzeg1c3QVSrXC7TeB0g.PNG/240420푸르늬님_2.png],
        media_files: [{ file_size: 8_644_035 }],
        page_url: nil,
      )
    end

    context "A blog post with editorversion = 4" do
      strategy_should_work(
        "https://blog.naver.com/sjhsh352/223378243886",
        image_urls: %w[
          http://blogfiles.naver.net/MjAyNDAzMDlfNTMg/MDAxNzA5OTc3NjgzNTY0.cERosGA8-6Wp9ckDJtEJJk06c7tKyNwAJHCV-KMU-Gkg.15_fCdaYCdvOy0BB6VF1wRdNgM0bL_TBTDFhJbI-khsg.JPEG/%EC%97%B0%EC%8A%B528.jpg
          http://blogfiles.naver.net/MjAyNDAzMDlfNTkg/MDAxNzA5OTc3Njg0MDMy.rSUlPdyMwdYUbyxUJSJ6gESkqOQWSUNlxM7V3Dlw_o8g.0Q6WK14Lg2V0ivNlcgp2kPJeadxaLAbnuuZhIDLQSckg.JPEG/%EC%97%B0%EC%8A%B531.jpg
          http://blogfiles.naver.net/MjAyNDAzMDlfNTIg/MDAxNzA5OTc3Njg1NTY0.UoxFqWOvNEhiuxJJ0kpktgnEPczFRKZ3E-xMeExhSl0g.1l6HuoTh6rkYT36CiP0x56LMj6-HJM_GxFuLbaOZ6UUg.JPEG/%EC%97%B0%EC%8A%B532.jpg
          http://blogfiles.naver.net/MjAyNDAzMDlfMjY1/MDAxNzA5OTc3Njg1NzI1.eQaPrGAoYEdCxMlWHGcAjZH9rTM24kOoWJgiikfYY1wg.Oj61aX8tU6_54BS04VVK5urafrspm5cnppquFzD3n4Eg.JPEG/%EC%97%B0%EC%8A%B534.jpg
          http://blogfiles.naver.net/MjAyNDAzMDlfMTkz/MDAxNzA5OTc3Njg2NDU2.CGICUTf88WpAqi6DnfmtJT3sYDQQRHapm6nsqY4SYLQg.CdTTYxY6Toz65HYk037NRq2EDMS4l5E1Ia1PxWjbA9Ug.JPEG/%EC%97%B0%EC%8A%B536.jpg
          http://blogfiles.naver.net/MjAyNDAzMDlfNzYg/MDAxNzA5OTc3Njg2MDg4.rll_jkQwm_24YCJqVUHE0Zpacyp4_TAxa2xNHwWJZUIg.hz4H_aQR6QqoRlVfN9AgZZZ39ivSbYFqtDKGwEf-sFUg.JPEG/%EC%97%B0%EC%8A%B537.jpg
          http://blogfiles.naver.net/MjAyNDAzMDlfMjE2/MDAxNzA5OTc3Njg0MDA5.RWY_LhMRCmOa5kM5QuGkf59yNKisiuzkGXuBj3mQjucg.IiNYEXqPu1J2h7Z0yfdi0SKE8o72QcS-KM8DrhUXEFog.JPEG/%EC%97%B0%EC%8A%B544.jpg
          http://blogfiles.naver.net/MjAyNDAzMDlfMjY1/MDAxNzA5OTc3Njg0NTUx.Zt4eTkzKl7M_aTsQbpIponQIUy_nU5xU8fN7nDp707Qg.w10y2YZMvZAaQK3ZMnPMFRFA-eyCvWfLfi60TcDXqFQg.JPEG/%EC%97%B0%EC%8A%B546.jpg
          http://blogfiles.naver.net/MjAyNDAzMDlfMTI4/MDAxNzA5OTc3Njg0MDEy.etXEuAgtEzw04lOJUbRSkHRqACI2xgQRtD6QS1b8N6gg.PuHzL2Y-KAI6InFndlreP0Agome18u1_SFgZdIui4lcg.JPEG/%EC%97%B0%EC%8A%B547.jpg
          http://blogfiles.naver.net/MjAyNDAzMDlfMTgz/MDAxNzA5OTc3NjgzNjEx.WUzEcrR0ry36cLbxZ-30O8Z__tK_g7sazURXQuPVLL4g.drL8-weVjKSy89aTGxlU-Cn-UwzJK2sD3y9qvV7_Ev0g.JPEG/%EC%97%B0%EC%8A%B550.jpg
        ],
        media_files: [
          { file_size: 7_920_147 },
          { file_size: 9_977_752 },
          { file_size: 7_086_628 },
          { file_size: 5_158_991 },
          { file_size: 10_780_827 },
          { file_size: 10_374_931 },
          { file_size: 8_402_893 },
          { file_size: 12_838_088 },
          { file_size: 12_049_574 },
          { file_size: 7_355_991 },
        ],
        page_url: "https://blog.naver.com/sjhsh352/223378243886",
        profile_url: "https://blog.naver.com/sjhsh352",
        profile_urls: %w[https://blog.naver.com/sjhsh352],
        display_name: "비얌Biyam",
        username: "sjhsh352",
        tag_name: "sjhsh352",
        other_names: ["비얌Biyam", "sjhsh352"],
        tags: [
          ["대문", "https://blog.naver.com/PostList.naver?blogId=sjhsh352&categoryName=대문"],
        ],
        dtext_artist_commentary_title: "대문",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "[image]":[http://blogfiles.naver.net/MjAyNDAzMDlfNTMg/MDAxNzA5OTc3NjgzNTY0.cERosGA8-6Wp9ckDJtEJJk06c7tKyNwAJHCV-KMU-Gkg.15_fCdaYCdvOy0BB6VF1wRdNgM0bL_TBTDFhJbI-khsg.JPEG/연습28.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNDAzMDlfNTkg/MDAxNzA5OTc3Njg0MDMy.rSUlPdyMwdYUbyxUJSJ6gESkqOQWSUNlxM7V3Dlw_o8g.0Q6WK14Lg2V0ivNlcgp2kPJeadxaLAbnuuZhIDLQSckg.JPEG/연습31.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNDAzMDlfNTIg/MDAxNzA5OTc3Njg1NTY0.UoxFqWOvNEhiuxJJ0kpktgnEPczFRKZ3E-xMeExhSl0g.1l6HuoTh6rkYT36CiP0x56LMj6-HJM_GxFuLbaOZ6UUg.JPEG/연습32.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNDAzMDlfMjY1/MDAxNzA5OTc3Njg1NzI1.eQaPrGAoYEdCxMlWHGcAjZH9rTM24kOoWJgiikfYY1wg.Oj61aX8tU6_54BS04VVK5urafrspm5cnppquFzD3n4Eg.JPEG/연습34.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNDAzMDlfMTkz/MDAxNzA5OTc3Njg2NDU2.CGICUTf88WpAqi6DnfmtJT3sYDQQRHapm6nsqY4SYLQg.CdTTYxY6Toz65HYk037NRq2EDMS4l5E1Ia1PxWjbA9Ug.JPEG/연습36.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNDAzMDlfNzYg/MDAxNzA5OTc3Njg2MDg4.rll_jkQwm_24YCJqVUHE0Zpacyp4_TAxa2xNHwWJZUIg.hz4H_aQR6QqoRlVfN9AgZZZ39ivSbYFqtDKGwEf-sFUg.JPEG/연습37.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNDAzMDlfMjE2/MDAxNzA5OTc3Njg0MDA5.RWY_LhMRCmOa5kM5QuGkf59yNKisiuzkGXuBj3mQjucg.IiNYEXqPu1J2h7Z0yfdi0SKE8o72QcS-KM8DrhUXEFog.JPEG/연습44.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNDAzMDlfMjY1/MDAxNzA5OTc3Njg0NTUx.Zt4eTkzKl7M_aTsQbpIponQIUy_nU5xU8fN7nDp707Qg.w10y2YZMvZAaQK3ZMnPMFRFA-eyCvWfLfi60TcDXqFQg.JPEG/연습46.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNDAzMDlfMTI4/MDAxNzA5OTc3Njg0MDEy.etXEuAgtEzw04lOJUbRSkHRqACI2xgQRtD6QS1b8N6gg.PuHzL2Y-KAI6InFndlreP0Agome18u1_SFgZdIui4lcg.JPEG/연습47.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNDAzMDlfMTgz/MDAxNzA5OTc3NjgzNjEx.WUzEcrR0ry36cLbxZ-30O8Z__tK_g7sazURXQuPVLL4g.drL8-weVjKSy89aTGxlU-Cn-UwzJK2sD3y9qvV7_Ev0g.JPEG/연습50.jpg]

          [b]비얌Biyam[/b]

          블로그에 오신 것을 환영합니다.

          * 주인장은 뭐 하는 인간인가?

          기본적으로 웹툰작가 지망생으로, 현재는 (언젠가 있을지도 모를 공모전에 대비하며) 원고를 작업 중이며 동시에 틈틈이 그림을 그려 올리는 중. 한때 스타워즈를 사랑했으나 라스트 제다이에게 싸다구를 후려쳐맞고 현재는 애정이 끊겼다.

          2. 뭘 그리는가?

          주로 고증을 맞춘 역사 그림을 많이 그리지만 좋아하는 만화, 게임 등의 팬아트, 갑자기 삘 꽂혀서 그리는 캐릭터 디자인 등등을 그리는 중. 최근에 든 생각인데 특히 좋아하는 건 '고증에 맞으면서도 현대인에게 낯선 비주얼의 과거의 복식' 인 듯하다.

          기타 잡다한 링크들

          트위터 : <https://twitter.com/sjhsh352>

          <https://twitter.com/sjhsh352>

          픽시브 : <https://www.pixiv.net/users/41156437>

          <https://www.pixiv.net/users/41156437>

          인스타 : <https://www.instagram.com/biyamoftwitter>

          <https://www.instagram.com/biyamoftwitter>

          포스타입 : <https://www.postype.com/profile/@39cusc>

          <https://www.postype.com/profile/@39cusc>

          아트스테이션 : <https://www.artstation.com/biyam>

          <https://www.artstation.com/biyam>

          [b]환영합니다[/b]
        EOS
      )
    end

    context "A blog post with editorversion = 3" do
      strategy_should_work(
        "https://blog.naver.com/sungho5080/220871847587",
        image_urls: %w[
          http://blogfiles.naver.net/MjAxNjExMjdfMTg2/MDAxNDgwMjI1MjI1Mzk0.b2KjST5v_26westngs51Ll-TiHhlPnWANbPOpNv5ekMg.hax7WxI_Ho8VQmS3CClqIz_2pqCtiLoeSlIEe4qmnGsg.JPEG.sungho5080/57671419_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMjY4/MDAxNDgwMjI1MjI1Mzkz.QvU-_Ll-QABOLTUsDqlncg7TJHAEAUGCzNE_T1JQWnsg.Kp1FJn1DSrjHEIi5KcrLwvegpwgjc8FHtHjWiYsv2ywg.JPEG.sungho5080/60118026_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMjkz/MDAxNDgwMjI1MjI1ODEz.2rYcG9oqRcz9AmKP0W7Xt6ocdeJfdtT2O98RS2iEXI0g.ojLNS3Epz0c9_awLSkuKUs09qeP5RsfnXZrPPAlAbYYg.JPEG.sungho5080/57518544_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMjMw/MDAxNDgwMjI1MjI1ODc1.i2ys9dU2ssxFXRKPPPq5ySG67EVt3MbITs1s5CK82Ggg.mxZvWPIbv2loOxzlZS79H5WMtfv6IZtoJ-3OGgGwWqUg.JPEG.sungho5080/57885150_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMTM3/MDAxNDgwMjI1MjI2MDUw.NVh7NskVX6gAFAGUFL27tCCccSsETWp7XYPKcKFAc8og.bKbfMXB0h7OCaqnL2vg3_htH6_fklPaTcHaUFjgExd8g.JPEG.sungho5080/57987813_p2_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMTg2/MDAxNDgwMjI1MjI2MTk2.6iPrdpGj6BFSDadu1euGxz-myw8RLh20gELOF4EJ1NUg.R3QBCIBpKdShAKBYPdvDIN6tAs2BlUG05lLP91HxmRog.JPEG.sungho5080/58158478_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMjQ1/MDAxNDgwMjI1MjI2ODgz.8Kj1833acdXksj23ay936Eu5IWXq4U4H8khr_jFUziEg.A9uq_EQRMHKB2itWyIiro2HqzJ5CeBHVDcC19Immansg.JPEG.sungho5080/58277608_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfNiAg/MDAxNDgwMjI1MjI2OTY3.nO8de1eSNXJ8iSgvM5gV_cTXah8VvPOh7wArP2Wgilgg.zMvIj3QbRyVtTVK8FA_ZtNJW8iyZJClrZ8Ucuz2XImwg.JPEG.sungho5080/58293696_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMjcx/MDAxNDgwMjI1MjI3MzI5.3Z6shxTIrtKzVN8ku34jzItQcEj_Qi-_Bh1UqkXXAjwg.iJP5ec1P2wwKtdZhJuNDwZJ44ZpsGz0azGhapw8ei3og.JPEG.sungho5080/58905301_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfOTcg/MDAxNDgwMjI1MjI3MzM1.YZjyZcNco021SgHGU1DxCeGC6RYmPDAAbeLbb3PBWIgg.CcTjcEuX9ka8GKUvaogCizS2btDe8rKJkhvAMfMu4wog.JPEG.sungho5080/59048962_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMTgx/MDAxNDgwMjI1MjI3NzIz.J54y9KvIb6QzBzGG62L1_qu9kLAppQG7xkfdBvSeaKAg.GU0cqi2y3j4k1H7H3oM7vPsq2AvRaC6KQ_GbIJJ_9_cg.JPEG.sungho5080/59286714_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfODkg/MDAxNDgwMjI1MjI3Nzc0.oi2lTTKuNsC0npyG_--xapxeerpEKkm3tSjczZDs_lcg.bUOEYsZ07K_ZcsH61W0vcxbeIj8d6pCQse3HIEDXwfwg.JPEG.sungho5080/59701847_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMTQ2/MDAxNDgwMjI1MjI4MzY5.rREisqA3oL47biN-fLB8z3qFixGYPJ3U5q-N9osbrjwg.wT3WvOs_fckV0oyyjyDXl2-kbFo8R9Je9ouzcZD2DVkg.JPEG.sungho5080/59725554_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfOTEg/MDAxNDgwMjI1MjI4NDY5.9H105GNvOhzojXjoIurS1RXOTuR04Ofb5UxS04M5FwUg.v4rHN7PF-kLBK-SwLwrNwha0f20uz6dRqBd5w-XVySMg.JPEG.sungho5080/59579167_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMzYg/MDAxNDgwMjI1MjI4NjU1.esRN9GPP1mFmhtCC55YH3OfU1han-xzYwbKSOeSVOeUg.CLBmIlR0c3VISEHkLoZhw42uZC6-At_Ofj9UCJYm1Zcg.JPEG.sungho5080/59991417_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMjI3/MDAxNDgwMjI1MjI4ODAy.K5p8OMNt1qbYYxISCyL0zYLQgxxtmVwExz_P9aEm_Lsg.xdgtX4cXG9Et5Hmleg9V6-zzLPNkfe1CDUG1ZX8AShkg.JPEG.sungho5080/59940835_p0_master1200.jpg
          http://blogfiles.naver.net/MjAxNjExMjdfMjU0/MDAxNDgwMjI1MjI5MDI1.jH7NXwlwkPO_HOenCunmO2y54vCXRPmgGtx4xyw25I4g.r7Y-zvWDuEbZrntJw2BCbn1xHAdr6eLWUNjbwhI-Acwg.JPEG.sungho5080/59922235_p0_master1200.jpg
        ],
        media_files: [
          { file_size: 280_815 },
          { file_size: 461_997 },
          { file_size: 218_445 },
          { file_size: 225_495 },
          { file_size: 123_434 },
          { file_size: 326_623 },
          { file_size: 203_337 },
          { file_size: 172_514 },
          { file_size: 198_182 },
          { file_size: 121_814 },
          { file_size: 380_448 },
          { file_size: 247_747 },
          { file_size: 370_763 },
          { file_size: 516_589 },
          { file_size: 373_987 },
          { file_size: 457_192 },
          { file_size: 150_465 },
        ],
        page_url: "https://blog.naver.com/sungho5080/220871847587",
        profile_url: "https://blog.naver.com/sungho5080",
        profile_urls: %w[https://blog.naver.com/sungho5080],
        display_name: "쌍둥이 큐레무",
        username: "sungho5080",
        tag_name: "sungho5080",
        other_names: ["쌍둥이 큐레무", "sungho5080"],
        tags: [
          ["ANI「일러스트」", "https://blog.naver.com/PostList.naver?blogId=sungho5080&categoryName=ANI「일러스트」"],
        ],
        dtext_artist_commentary_title: "포켓몬 일러스트 - (SM2)",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMTg2/MDAxNDgwMjI1MjI1Mzk0.b2KjST5v_26westngs51Ll-TiHhlPnWANbPOpNv5ekMg.hax7WxI_Ho8VQmS3CClqIz_2pqCtiLoeSlIEe4qmnGsg.JPEG.sungho5080/57671419_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMjY4/MDAxNDgwMjI1MjI1Mzkz.QvU-_Ll-QABOLTUsDqlncg7TJHAEAUGCzNE_T1JQWnsg.Kp1FJn1DSrjHEIi5KcrLwvegpwgjc8FHtHjWiYsv2ywg.JPEG.sungho5080/60118026_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMjkz/MDAxNDgwMjI1MjI1ODEz.2rYcG9oqRcz9AmKP0W7Xt6ocdeJfdtT2O98RS2iEXI0g.ojLNS3Epz0c9_awLSkuKUs09qeP5RsfnXZrPPAlAbYYg.JPEG.sungho5080/57518544_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMjMw/MDAxNDgwMjI1MjI1ODc1.i2ys9dU2ssxFXRKPPPq5ySG67EVt3MbITs1s5CK82Ggg.mxZvWPIbv2loOxzlZS79H5WMtfv6IZtoJ-3OGgGwWqUg.JPEG.sungho5080/57885150_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMTM3/MDAxNDgwMjI1MjI2MDUw.NVh7NskVX6gAFAGUFL27tCCccSsETWp7XYPKcKFAc8og.bKbfMXB0h7OCaqnL2vg3_htH6_fklPaTcHaUFjgExd8g.JPEG.sungho5080/57987813_p2_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMTg2/MDAxNDgwMjI1MjI2MTk2.6iPrdpGj6BFSDadu1euGxz-myw8RLh20gELOF4EJ1NUg.R3QBCIBpKdShAKBYPdvDIN6tAs2BlUG05lLP91HxmRog.JPEG.sungho5080/58158478_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMjQ1/MDAxNDgwMjI1MjI2ODgz.8Kj1833acdXksj23ay936Eu5IWXq4U4H8khr_jFUziEg.A9uq_EQRMHKB2itWyIiro2HqzJ5CeBHVDcC19Immansg.JPEG.sungho5080/58277608_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfNiAg/MDAxNDgwMjI1MjI2OTY3.nO8de1eSNXJ8iSgvM5gV_cTXah8VvPOh7wArP2Wgilgg.zMvIj3QbRyVtTVK8FA_ZtNJW8iyZJClrZ8Ucuz2XImwg.JPEG.sungho5080/58293696_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMjcx/MDAxNDgwMjI1MjI3MzI5.3Z6shxTIrtKzVN8ku34jzItQcEj_Qi-_Bh1UqkXXAjwg.iJP5ec1P2wwKtdZhJuNDwZJ44ZpsGz0azGhapw8ei3og.JPEG.sungho5080/58905301_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfOTcg/MDAxNDgwMjI1MjI3MzM1.YZjyZcNco021SgHGU1DxCeGC6RYmPDAAbeLbb3PBWIgg.CcTjcEuX9ka8GKUvaogCizS2btDe8rKJkhvAMfMu4wog.JPEG.sungho5080/59048962_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMTgx/MDAxNDgwMjI1MjI3NzIz.J54y9KvIb6QzBzGG62L1_qu9kLAppQG7xkfdBvSeaKAg.GU0cqi2y3j4k1H7H3oM7vPsq2AvRaC6KQ_GbIJJ_9_cg.JPEG.sungho5080/59286714_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfODkg/MDAxNDgwMjI1MjI3Nzc0.oi2lTTKuNsC0npyG_--xapxeerpEKkm3tSjczZDs_lcg.bUOEYsZ07K_ZcsH61W0vcxbeIj8d6pCQse3HIEDXwfwg.JPEG.sungho5080/59701847_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMTQ2/MDAxNDgwMjI1MjI4MzY5.rREisqA3oL47biN-fLB8z3qFixGYPJ3U5q-N9osbrjwg.wT3WvOs_fckV0oyyjyDXl2-kbFo8R9Je9ouzcZD2DVkg.JPEG.sungho5080/59725554_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfOTEg/MDAxNDgwMjI1MjI4NDY5.9H105GNvOhzojXjoIurS1RXOTuR04Ofb5UxS04M5FwUg.v4rHN7PF-kLBK-SwLwrNwha0f20uz6dRqBd5w-XVySMg.JPEG.sungho5080/59579167_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMzYg/MDAxNDgwMjI1MjI4NjU1.esRN9GPP1mFmhtCC55YH3OfU1han-xzYwbKSOeSVOeUg.CLBmIlR0c3VISEHkLoZhw42uZC6-At_Ofj9UCJYm1Zcg.JPEG.sungho5080/59991417_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMjI3/MDAxNDgwMjI1MjI4ODAy.K5p8OMNt1qbYYxISCyL0zYLQgxxtmVwExz_P9aEm_Lsg.xdgtX4cXG9Et5Hmleg9V6-zzLPNkfe1CDUG1ZX8AShkg.JPEG.sungho5080/59940835_p0_master1200.jpg]

          "[image]":[http://blogfiles.naver.net/MjAxNjExMjdfMjU0/MDAxNDgwMjI1MjI5MDI1.jH7NXwlwkPO_HOenCunmO2y54vCXRPmgGtx4xyw25I4g.r7Y-zvWDuEbZrntJw2BCbn1xHAdr6eLWUNjbwhI-Acwg.JPEG.sungho5080/59922235_p0_master1200.jpg]
        EOS
      )
    end

    context "A blog post with editorversion = 2" do
      strategy_should_work(
        "https://m.blog.naver.com/mazingcaizer/40199782739",
        image_urls: %w[
          http://blogfiles.naver.net/20131028_63/mazingcaizer_13829653348023Lofl_JPEG/%EC%97%94%EC%BF%A4%EC%8A%A4%ED%83%80_(1).jpg
          http://blogfiles.naver.net/20131028_173/mazingcaizer_13829653351091drVF_JPEG/%EC%97%94%EC%BF%A4%EC%8A%A4%ED%83%80_(2).jpg
          http://blogfiles.naver.net/20131028_284/mazingcaizer_13829653354772FnCs_JPEG/%EC%97%94%EC%BF%A4%EC%8A%A4%ED%83%80_(3).jpg
          http://blogfiles.naver.net/20131028_259/mazingcaizer_1382965335948e61kQ_JPEG/%EC%97%94%EC%BF%A4%EC%8A%A4%ED%83%80_(4).jpg
          http://blogfiles.naver.net/20131028_216/mazingcaizer_1382965336298MiSMk_JPEG/%EC%97%94%EC%BF%A4%EC%8A%A4%ED%83%80_(5).jpg
        ],
        media_files: [
          { file_size: 81_136 },
          { file_size: 118_583 },
          { file_size: 90_793 },
          { file_size: 104_815 },
          { file_size: 101_310 },
        ],
        page_url: "https://blog.naver.com/mazingcaizer/40199782739",
        profile_urls: %w[https://blog.naver.com/mazingcaizer],
        display_name: "마신황제",
        username: "mazingcaizer",
        tags: [
          ["메카무스메", "https://m.blog.naver.com/BlogTagView.naver?tagName=메카무스메"],
          ["모바일게임", "https://m.blog.naver.com/BlogTagView.naver?tagName=모바일게임"],
          ["라인제타", "https://m.blog.naver.com/BlogTagView.naver?tagName=라인제타"],
          ["엔쿤스타", "https://m.blog.naver.com/BlogTagView.naver?tagName=엔쿤스타"],
          ["메이첸아머", "https://m.blog.naver.com/BlogTagView.naver?tagName=메이첸아머"],
          ["파우스트아머", "https://m.blog.naver.com/BlogTagView.naver?tagName=파우스트아머"],
          ["비리디안라이", "https://m.blog.naver.com/BlogTagView.naver?tagName=비리디안라이"],
          ["레디언트리펄서", "https://m.blog.naver.com/BlogTagView.naver?tagName=레디언트리펄서"],
          ["슈페리얼랜서", "https://m.blog.naver.com/BlogTagView.naver?tagName=슈페리얼랜서"],
          ["클라인라이터", "https://m.blog.naver.com/BlogTagView.naver?tagName=클라인라이터"],
          ["메카관련 일러스트", "https://blog.naver.com/PostList.naver?blogId=mazingcaizer&categoryName=메카관련 일러스트"],
        ],
        dtext_artist_commentary_title: "모바일게임 <라인제타> 메이첸 아머",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "[image]":[http://blogfiles.naver.net/20131028_63/mazingcaizer_13829653348023Lofl_JPEG/%BF%A3%C4%EF%BD%BA%C5%B8_(1).jpg]
          "[image]":[http://blogfiles.naver.net/20131028_173/mazingcaizer_13829653351091drVF_JPEG/%BF%A3%C4%EF%BD%BA%C5%B8_(2).jpg]
          "[image]":[http://blogfiles.naver.net/20131028_284/mazingcaizer_13829653354772FnCs_JPEG/%BF%A3%C4%EF%BD%BA%C5%B8_(3).jpg]
          "[image]":[http://blogfiles.naver.net/20131028_259/mazingcaizer_1382965335948e61kQ_JPEG/%BF%A3%C4%EF%BD%BA%C5%B8_(4).jpg]
          "[image]":[http://blogfiles.naver.net/20131028_216/mazingcaizer_1382965336298MiSMk_JPEG/%BF%A3%C4%EF%BD%BA%C5%B8_(5).jpg]

          [b]<라인제타>[/b]

          메이첸 아머 5인방

          .

          .

          .

          엔쿤스타 메카닉 모바일게임 라인제타에 들어간 기체들입니다.

          저 모습은 개조가 완료된 상위기체 모습들이고

          하위기체 모습들은 업데이트 기간에 맞추기 위해 급조된 녀석들인지라

          조만간 정식 이미지로 교체될 예정입니다.

          오래간만에 그리는 메카무스메 타입의 그림이었던지라

          즐겁게 그렸던 기억이 나네요.

          시간나시면 한번쯤 플레이해주시길~~
        EOS
      )
    end

    context "A deleted or nonexistent blog post" do
      strategy_should_work(
        "https://blog.naver.com/nobody/999999999",
        image_urls: [],
        media_files: [],
        page_url: "https://blog.naver.com/nobody/999999999",
        profile_url: "https://blog.naver.com/nobody",
        profile_urls: %w[https://blog.naver.com/nobody],
        display_name: nil,
        username: "nobody",
        other_names: ["nobody"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
