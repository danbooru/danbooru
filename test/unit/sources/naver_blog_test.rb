# frozen_string_literal: true

require "test_helper"

module Sources
  class NaverBlogTest < ActiveSupport::TestCase
    context "Naver Blog:" do
      context "A blogthumb.pstatic.net sample image URL" do
        strategy_should_work(
          "https://blogthumb.pstatic.net/MjAyMzA3MTFfMjkz/MDAxNjg5MDQ2NTMwMTkw.2bAkaa4r8P5vcbpyyNH3X5ysDig6q_sJ2llYrNHQ_3Ag.7b3Pxl-DcaqTAM69oiYsGHGWKOlgwWXp5BbOpVDZ98Ag.PNG.kkid9624/230623%C6%F7%B5%F0%BE%C6%B4%D4.PNG?type=w2",
          image_urls: %w[http://blogfiles.naver.net/MjAyMzA3MTFfMjkz/MDAxNjg5MDQ2NTMwMTkw.2bAkaa4r8P5vcbpyyNH3X5ysDig6q_sJ2llYrNHQ_3Ag.7b3Pxl-DcaqTAM69oiYsGHGWKOlgwWXp5BbOpVDZ98Ag.PNG.kkid9624/230623%C6%F7%B5%F0%BE%C6%B4%D4.PNG],
          media_files: [{ file_size: 69_223 }],
          page_url: nil
        )
      end

      context "A postfiles.pstatic.net sample image URL" do
        strategy_should_work(
          "https://postfiles.pstatic.net/MjAyNDA0MjBfMzQg/MDAxNzEzNjIyMjM5MjY1.bA-t3pRhCcZ6t4TJKGCChhTFaO-ddv9m1tyLcdMW-4Ug.KvTzrwFNrFuB9AgQYuk0dBIGwAzeg1c3QVSrXC7TeB0g.PNG/240420%ED%91%B8%EB%A5%B4%EB%8A%AC%EB%8B%98_2.png?type=w966",
          image_urls: %w[http://blogfiles.naver.net/MjAyNDA0MjBfMzQg/MDAxNzEzNjIyMjM5MjY1.bA-t3pRhCcZ6t4TJKGCChhTFaO-ddv9m1tyLcdMW-4Ug.KvTzrwFNrFuB9AgQYuk0dBIGwAzeg1c3QVSrXC7TeB0g.PNG/240420푸르늬님_2.png],
          media_files: [{ file_size: 8_644_053 }],
          page_url: nil
        )
      end

      context "A blogpfthumb-phinf.pstatic.net sample image URL" do
        strategy_should_work(
          "https://blogpfthumb-phinf.pstatic.net/MjAyMzAzMThfMzIg/MDAxNjc5MDY4MjkxNzUz.ODdLT6VGaauXq9_jT-TpO878xZ--5lv0llIDclJvvTYg.yqLsxucKuBCz-auOTjpX2RRyLV_0WLCcBwb206KeCSIg.PNG.kkid9624/%EC%A0%9C%EB%B3%B8.PNG/%25EC%25A0%259C%25EB%25B3%25B8.PNG?type=s1",
          image_urls: %w[https://blogpfthumb-phinf.pstatic.net/MjAyMzAzMThfMzIg/MDAxNjc5MDY4MjkxNzUz.ODdLT6VGaauXq9_jT-TpO878xZ--5lv0llIDclJvvTYg.yqLsxucKuBCz-auOTjpX2RRyLV_0WLCcBwb206KeCSIg.PNG.kkid9624/제본.PNG/%25EC%25A0%259C%25EB%25B3%25B8.PNG],
          media_files: [{ file_size: 1_104_915 }],
          page_url: nil
        )
      end

      context "A blogfiles.pstatic.net full image URL" do
        strategy_should_work(
          "http://blogfiles.pstatic.net/MjAyNDA0MjBfMzQg/MDAxNzEzNjIyMjM5MjY1.bA-t3pRhCcZ6t4TJKGCChhTFaO-ddv9m1tyLcdMW-4Ug.KvTzrwFNrFuB9AgQYuk0dBIGwAzeg1c3QVSrXC7TeB0g.PNG/240420푸르늬님_2.png",
          image_urls: %w[http://blogfiles.naver.net/MjAyNDA0MjBfMzQg/MDAxNzEzNjIyMjM5MjY1.bA-t3pRhCcZ6t4TJKGCChhTFaO-ddv9m1tyLcdMW-4Ug.KvTzrwFNrFuB9AgQYuk0dBIGwAzeg1c3QVSrXC7TeB0g.PNG/240420푸르늬님_2.png],
          media_files: [{ file_size: 8_644_053 }],
          page_url: nil
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
          dtext_artist_commentary_desc: <<~EOS.chomp
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
          dtext_artist_commentary_desc: <<~EOS.chomp
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
          "https://blog.naver.com/goam2/221647025085",
          image_urls: %w[
            http://blogfiles.naver.net/MjAxOTA5MTNfMjQ4/MDAxNTY4MzAzNTg2MDEz.f5aL5tvfgCQ8861BLXT4zdlVZtIBm6s1rsI0-EPEuo8g.HGoozlzX15QDEkTAgwpo1CJoP3bf87IuAKrfve7prEkg.JPEG.goam2/EERhklgU4AELySe-ranga_2st_-_20190913_0024_1172169096957284352.jpg
            http://blogfiles.naver.net/MjAxOTA5MTNfMjcg/MDAxNTY4MzAzODA4NTM4.bkoxLvqiCwpUz1_9hT6aTaN0lDcgnVY244XUxZOAm2Ug.XPScZ34-4aACLs-Ala-D0kYR1Rs_UCJ6nUNu9YjH_J0g.PNG.goam2/%EB%AC%B4%EB%9D%BC%EC%B9%B4%EB%AF%B8_%EC%BD%94%EC%9A%B0%ED%97%A4%EC%9D%B4_%ED%8A%B8%EC%9C%97_1.png
            http://blogfiles.naver.net/MjAxOTA5MTNfMTA2/MDAxNTY4MzAzODA4ODEw.JM1a_hko_v89BGC3odi3K1vrnTmhmF9WfURvHWaf73wg.DrrdMB9HatEYU5_UV9RE6zD92J3fah0Rs7IuB1YFhWAg.PNG.goam2/%EB%AC%B4%EB%9D%BC%EC%B9%B4%EB%AF%B8_%EC%BD%94%EC%9A%B0%ED%97%A4%EC%9D%B4_%ED%8A%B8%EC%9C%97_2.png
            http://blogfiles.naver.net/MjAxOTA5MTNfMjc3/MDAxNTY4MzA0NDMxNTA5.HX-OEYzhBlFCSw7o3n410LwbUavYfIaf_0cKX8-wHKog.QGNzkHr5QvOrPDShWguI5E1QHZsTPP9okCloydfP4iAg.JPEG.goam2/EERf-C1UcAA4TrV-thewatchertmk_-_20190913_0017_1172167329209208837.jpg
            http://blogfiles.naver.net/MjAxOTA5MTNfNDUg/MDAxNTY4MzA0NDMxNzk4.SFvrsqc89__egiyc6Cuhqryc1M8HLJmSw_-jUa3f5H0g.R25vrS61zCepYnOx-WoxA65pnpIpZ2Vp8Btl3i0aoZAg.JPEG.goam2/EERN5p1UwAEiYeY-HitorinoNight_-_20190913_0000_1172162955728711680.jpg
            http://blogfiles.naver.net/MjAxOTA5MTNfODYg/MDAxNTY4MzA0NDMyMDk5.bM8rqyvx5kcNEKSfPZtIYcMlamQYFi9RDCmdiQTBqgwg.cewHm07h_rHzCbeDC4aY3oyPPE415P_54Ui_jr8DaDog.JPEG.goam2/EERjUBeUEAAIN7x-HatikouDx_-_20190913_0032_1172171005487284230.jpg
            http://blogfiles.naver.net/MjAxOTA5MTNfNzUg/MDAxNTY4MzA0NDMyMzMy.9rxAyvY1bydYFHBzRqVA1vjhS_4HtakjDt-iwn7GXjog.YGzRn0gXJWt6hFR3ERSO69hy43COxAAoRB2PfZ_8CTsg.JPEG.goam2/EERdFpuU4AAV1_a-tozimeteyauyu_-_20190913_0004_1172164158898372609.jpg
            http://blogfiles.naver.net/MjAxOTA5MTNfMTE3/MDAxNTY4MzA0NDMyNjMy.m95WyCF2OIEs-Yss_z5O5ZeZQIzH3m2CaKwF7bXA2pUg.8x37IVYn1oP82LlvBw0vXTwvy7xEDvZ5le_LQG--1pwg.JPEG.goam2/EEQZcm1U4AABZSx-AwaraChikuwa_-_20190912_1909_1172089788465201152.jpg
            http://blogfiles.naver.net/MjAxOTA5MTNfNyAg/MDAxNTY4MzA0NDMyOTEy.716JwQiel3SiDiIhN3AfkpyMb5gh6-SjqUm45YmRlr8g.6HOZVMt7XpKBLCWEr7tY7ina31BP_pmG_KZ1A5rdGtkg.JPEG.goam2/42232.jpg
          ],
          media_files: [
            { file_size: 1_143_156 },
            { file_size: 207_173 },
            { file_size: 72_428 },
            { file_size: 182_998 },
            { file_size: 149_359 },
            { file_size: 380_839 },
            { file_size: 215_862 },
            { file_size: 636_123 },
            { file_size: 69_285 },
          ],
          page_url: "https://blog.naver.com/goam2/221647025085",
          profile_url: "https://blog.naver.com/goam2",
          profile_urls: %w[https://blog.naver.com/goam2],
          display_name: "애쉬",
          username: "goam2",
          tag_name: "goam2",
          other_names: ["애쉬", "goam2"],
          tags: [
            ["기념일", "https://m.blog.naver.com/BlogTagView.naver?tagName=기념일"],
            ["기념일모음", "https://m.blog.naver.com/BlogTagView.naver?tagName=기념일모음"],
            ["가면라이더파이즈", "https://m.blog.naver.com/BlogTagView.naver?tagName=가면라이더파이즈"],
            ["가면라이더카이자", "https://m.blog.naver.com/BlogTagView.naver?tagName=가면라이더카이자"],
            ["카이자의날", "https://m.blog.naver.com/BlogTagView.naver?tagName=카이자의날"],
            ["생일", "https://m.blog.naver.com/BlogTagView.naver?tagName=생일"],
            ["아이돌마스터", "https://m.blog.naver.com/BlogTagView.naver?tagName=아이돌마스터"],
            ["아이돌마스터신데렐라걸즈", "https://m.blog.naver.com/BlogTagView.naver?tagName=아이돌마스터신데렐라걸즈"],
            ["신데마스", "https://m.blog.naver.com/BlogTagView.naver?tagName=신데마스"],
            ["난죠히카루", "https://m.blog.naver.com/BlogTagView.naver?tagName=난죠히카루"],
            ["각주", "https://m.blog.naver.com/BlogTagView.naver?tagName=각주"],
            ["각주_괄호", "https://m.blog.naver.com/BlogTagView.naver?tagName=각주_괄호"],
            ["신데마스", "https://blog.naver.com/PostList.naver?blogId=goam2&categoryName=신데마스"],
          ],
          dtext_artist_commentary_title: "2019년 카이자(913)의 날 기념 배우 무라카미 코우헤이 트윗 + 난죠 히카루(신데마스) 2019년 생일 기념 팬 축전 모음",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[http://blogfiles.naver.net/MjAxOTA5MTNfMjQ4/MDAxNTY4MzAzNTg2MDEz.f5aL5tvfgCQ8861BLXT4zdlVZtIBm6s1rsI0-EPEuo8g.HGoozlzX15QDEkTAgwpo1CJoP3bf87IuAKrfve7prEkg.JPEG.goam2/EERhklgU4AELySe-ranga_2st_-_20190913_0024_1172169096957284352.jpg]

            (트위터의 "嵐牙("@ranga_2st":[https://twitter.com/ranga_2st/status/1172169096957284352])"님 코스프레)

            ※출처와 연결된 트윗에서 1장의 사진을 더 볼 수 있습니다. ("링크":[https://twitter.com/border_less_/status/1172169702925160449?s=19])

            오늘은 2003년작 <가면라이더 파이즈>의 2호 라이더, 가면라이더 카이자를 상징하는 날입니다.

            이에 카이자의 주요 장착자 쿠사카 마사토의 배우 무라카미 코우헤이 씨가 기념 트윗들을 올려주셨길래 한번 번역해봤습니다.

            평소 자신의 배역에 애정이 많은 무라카미 씨 다워서 좋았습니다.

            더불어 오늘은 추석 + 카이자의 날 + 난죠 히카루 생일 + 13일의 금요일이라는 여러모로 혼파망적인 날이기도(...)

            이 글이 올라갈 때쯤이면 저는 가족들과 함께 시골로 향하고 있겠네요.

            모두 좋은 추석 되시길 바랍니다.

            "[image]":[http://blogfiles.naver.net/MjAxOTA5MTNfMjcg/MDAxNTY4MzAzODA4NTM4.bkoxLvqiCwpUz1_9hT6aTaN0lDcgnVY244XUxZOAm2Ug.XPScZ34-4aACLs-Ala-D0kYR1Rs_UCJ6nUNu9YjH_J0g.PNG.goam2/무라카미_코우헤이_트윗_1.png]

            [quote]
            9월 13일은 카이자의 날!

            평상시에는 조금 말하기 힘든 비뚤어진 성격의 히어로, 카이자에 대한, 쿠사카 마사토에 대한 사랑을 마음껏 털어놓을 수 있는 날!

            올해는 일 관계상, 오전 9시 13분에 "카이자" 콜 합니다!

            블로그 업데이트 했습니다!

            "http://blog.koheimurakami.com/?eid=2179":[https://t.co/aoi1gcMwuv?amp=1]

            <http://blog.koheimurakami.com/?eid=2179>
            [/quote]

            (트윗 출처 → "링크":[https://twitter.com/kohei__murakami/status/1172164271427293189])

            ※이하 번역은 모두 필자가 직접 했습니다. [s]오랜만에 보는 쿠쎀커 썩소[/s]

            "[image]":[http://blogfiles.naver.net/MjAxOTA5MTNfMTA2/MDAxNTY4MzAzODA4ODEw.JM1a_hko_v89BGC3odi3K1vrnTmhmF9WfURvHWaf73wg.DrrdMB9HatEYU5_UV9RE6zD92J3fah0Rs7IuB1YFhWAg.PNG.goam2/무라카미_코우헤이_트윗_2.png]

            [quote]
            드디어! 그 캐릭터 송을 무라카미 코헤이가 부른다!

            무라카미 코헤이

            「existence~KAIXA-nized dice / Red Rock」

            돌체스터 레코드를 통해

            2019년 9월 13일 오늘 출시!

            "amazon.co.jp/dp/B07XMNLQ7Z?...":[https://t.co/q4X6b98jMK?amp=1]

            (뮤직비디오) 시청은 이쪽!

            <https://youtu.be/m0yrbR_m7VY>
            [/quote]

            (트윗 출처 → "링크":[https://twitter.com/kohei__murakami/status/1172166797887340545])

            ※가면라이더 카이자의 테마곡을 무라카미 코헤이 씨가 부른 버전으로 새로 녹음해 당일 출시했다고 합니다. 정말이지 대단한 애정 ㅋㅋㅋ

            "[image]":[http://blogfiles.naver.net/MjAxOTA5MTNfMjc3/MDAxNTY4MzA0NDMxNTA5.HX-OEYzhBlFCSw7o3n410LwbUavYfIaf_0cKX8-wHKog.QGNzkHr5QvOrPDShWguI5E1QHZsTPP9okCloydfP4iAg.JPEG.goam2/EERf-C1UcAA4TrV-thewatchertmk_-_20190913_0017_1172167329209208837.jpg]

            (트위터의 "マッタマッタ/・ワ・("@thewatchertmk":[https://twitter.com/thewatchertmk/status/1172167329209208837])"님 작품)

            [s]깨알 같은 겐무[/s]

            "[image]":[http://blogfiles.naver.net/MjAxOTA5MTNfNDUg/MDAxNTY4MzA0NDMxNzk4.SFvrsqc89__egiyc6Cuhqryc1M8HLJmSw_-jUa3f5H0g.R25vrS61zCepYnOx-WoxA65pnpIpZ2Vp8Btl3i0aoZAg.JPEG.goam2/EERN5p1UwAEiYeY-HitorinoNight_-_20190913_0000_1172162955728711680.jpg]

            (트위터의 "ものろーぐ("@HitorinoNight":[https://twitter.com/HitorinoNight/status/1172162955728711680])"님 작품)

            ※벨트는 가면라이더 지오의 시공 드라이버 오마쥬

            "[image]":[http://blogfiles.naver.net/MjAxOTA5MTNfODYg/MDAxNTY4MzA0NDMyMDk5.bM8rqyvx5kcNEKSfPZtIYcMlamQYFi9RDCmdiQTBqgwg.cewHm07h_rHzCbeDC4aY3oyPPE415P_54Ui_jr8DaDog.JPEG.goam2/EERjUBeUEAAIN7x-HatikouDx_-_20190913_0032_1172171005487284230.jpg]

            (트위터의 "はちこう😈カラマス9/29("@HatikouDx":[https://twitter.com/HatikouDx/status/1172171005487284230])"님 작품)

            "[image]":[http://blogfiles.naver.net/MjAxOTA5MTNfNzUg/MDAxNTY4MzA0NDMyMzMy.9rxAyvY1bydYFHBzRqVA1vjhS_4HtakjDt-iwn7GXjog.YGzRn0gXJWt6hFR3ERSO69hy43COxAAoRB2PfZ_8CTsg.JPEG.goam2/EERdFpuU4AAV1_a-tozimeteyauyu_-_20190913_0004_1172164158898372609.jpg]

            (트위터의 "作画傭兵ヤウユ("@tozimeteyauyu":[https://twitter.com/tozimeteyauyu/status/1172164158898372609])"님 작품)

            ※가면라이더 쿠우가 변신 포즈

            "[image]":[http://blogfiles.naver.net/MjAxOTA5MTNfMTE3/MDAxNTY4MzA0NDMyNjMy.m95WyCF2OIEs-Yss_z5O5ZeZQIzH3m2CaKwF7bXA2pUg.8x37IVYn1oP82LlvBw0vXTwvy7xEDvZ5le_LQG--1pwg.JPEG.goam2/EEQZcm1U4AABZSx-AwaraChikuwa_-_20190912_1909_1172089788465201152.jpg]

            (트위터의 "芦原ちくわ("@AwaraChikuwa":[https://twitter.com/AwaraChikuwa/status/1172089788465201152])"님 작품)

            ※코스튬은 신데마스 오리지널이지만, 일러스트 컨셉은 가면라이더 크로즈 마그마로 추정

            "[image]":[http://blogfiles.naver.net/MjAxOTA5MTNfNyAg/MDAxNTY4MzA0NDMyOTEy.716JwQiel3SiDiIhN3AfkpyMb5gh6-SjqUm45YmRlr8g.6HOZVMt7XpKBLCWEr7tY7ina31BP_pmG_KZ1A5rdGtkg.JPEG.goam2/42232.jpg]

            오늘은 <아이돌 마스터 신데렐라 걸즈>에 등장하는 특촬물 매니아 아이돌 난죠 히카루의 생일입니다.

            특촬물 매니아라는 설정에 9월 13일이라...새삼스레 제작진이 뭔가 여러모로 노렸다[1]는 것을 깨닫게 되네요. (...)

            생일 축하합니다!

            1. (각주) 실제로 히카루는 데레스테 슈로대 이벤트에서 슈로대 OG의 기체 컴패터블 카이저에 탑승하고 등장한 전적이 있습니다. 컴패터블 카이저의 색상 등이 히카루의 코스튬과 닮긴 했지만 하필 '카이저'라 아무리 봐도 노린 것 같습니다. (...)
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
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.page_url?("https://blog.naver.com/kkid9624/223421884109"))
        assert(Source::URL.page_url?("https://m.blog.naver.com/goam2/221647025085"))
        assert(Source::URL.page_url?("https://m.blog.naver.com/PostView.naver?blogId=fishtailia&logNo=223434964582"))

        assert(Source::URL.profile_url?("https://blog.naver.com/yanusunya"))
        assert(Source::URL.profile_url?("https://m.blog.naver.com/goam2?tab=1"))
        assert(Source::URL.profile_url?("https://m.blog.naver.com/rego/BlogUserInfo.naver?blogId=fishtailia"))
        assert(Source::URL.profile_url?("https://blog.naver.com/PostList.naver?blogId=yanusunya&categoryNo=86&skinType=&skinId=&from=menu&userSelectMenu=true"))
        assert(Source::URL.profile_url?("https://blog.naver.com/NBlogTop.naver?isHttpsRedirect=true&blogId=mgrtt3132003"))
        assert(Source::URL.profile_url?("https://blog.naver.com/prologue/PrologueList.nhn?blogId=tobsua"))
        assert(Source::URL.profile_url?("https://blog.naver.com/profile/intro.naver?blogId=rlackswnd58"))
        assert(Source::URL.profile_url?("https://rss.blog.naver.com/yanusunya.xml"))
        assert(Source::URL.profile_url?("https://mirun2.blog.me"))
      end
    end
  end
end
