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
          http://blogfiles.naver.net/MjAyNjAxMDhfMjM1/MDAxNzY3ODYzMTQ1NzE3.X1uhHyomt-NFXliaDTrfSXRd6U1iRjyng5EH9xCd8PYg.b_ke3PbhwYdz1ONXIDJNpvSX_-GmUmAkJMgLVziZXBog.JPEG/%EA%B0%80%EC%95%BC%EB%B3%B4%EC%A0%95.jpg
          http://blogfiles.naver.net/MjAyNjAxMDhfMTUy/MDAxNzY3ODYzMTQ3MzA3.kl7YVWYrh6jfo8cHu-Xrw2buhVl1HinMQl_Zrr_7zFQg.abPpK-w_V_IRVjMx0jlFrXf4InuiecgbU1-O6qF3I0sg.JPEG/%EC%97%B0%EC%8A%B5239.jpg
          http://blogfiles.naver.net/MjAyNjAxMDhfOTcg/MDAxNzY3ODYzMTQ3NTAy.MmEFeHnY4mbiq8ApPO_0jlV0-UzvFd5wL79TYWdSYCUg.m6b_L9B4ihohWRGdOcImiwQ3SPPM8H6VtyA8Htz1S3Ag.JPEG/%EC%97%B0%EC%8A%B5241.jpg
          http://blogfiles.naver.net/MjAyNjAxMDhfMTU0/MDAxNzY3ODYzMTQ1NjE2.S0qnZOgri3vqcPpecDiwY9S6r3wUt2UnVFSoq230-Jwg.wz6uC8zC-hrSyPPNjD7UfWXFuvtSccdjBTZOCWiLl6wg.JPEG/%EC%97%B0%EC%8A%B5242.jpg
          http://blogfiles.naver.net/MjAyNjAxMDhfMTAz/MDAxNzY3ODYzMTQ1Mzc2.kH6_J10yDymCxwJ_0rnKLMGwA81_Zt8hDK00z9ehZRAg.fcfqg2temrCmRvEvhl3KNVQ9IZjELnk5Me0ITD7gzPEg.JPEG/%EC%97%B0%EC%8A%B5244.jpg
          http://blogfiles.naver.net/MjAyNjAxMDhfOTIg/MDAxNzY3ODYzMTQ1NTQ0.pWRM-ISlqiwevgyOA5uXffYBvaG_Iwmk00JmOeCywUcg.eZq4AqyunK-bTsm0ibCOx7VzflNmC-pw5kyHE-UNWMog.JPEG/%EC%97%B0%EC%8A%B5245.jpg
          http://blogfiles.naver.net/MjAyNjAxMDhfMjI1/MDAxNzY3ODYzMTQ1ODQx.0arV7saoekVZI8s7Js_pHJRrwhoy0ncu4R-FqSC7nlAg.tUzfdP_Mrcco1YM7DUAzodVrt3SRCxrc4EqQPcBLYVkg.JPEG/%EC%97%B0%EC%8A%B5246.jpg
          http://blogfiles.naver.net/MjAyNjAxMDhfMjc2/MDAxNzY3ODYzMTQ1NTkz.lXuZBTBUKlvgMfg0oq11TEAFbqZ-WtvnmyPJJNRa7LYg.eljyh-_f7SejWRMxUmAcCyx5dn1z58BKeqKSYfYsersg.JPEG/%EC%97%B0%EC%8A%B5247.jpg
          http://blogfiles.naver.net/MjAyNjAxMDhfMTI1/MDAxNzY3ODYzMTQ2OTkx.wGh4JEX2dajD2WoBBwpjr3mY_REf-g9UIA6vX0FBAeog.Yvo-hjsRheX45-dKaN5iewrt8AjBZ0mgCcWqsH_WONIg.JPEG/%EC%97%B0%EC%8A%B5248.jpg
          http://blogfiles.naver.net/MjAyNjAxMDhfMjE3/MDAxNzY3ODYzMTQ3Mzc3.mmd5jmzIExnA2iCeImmsUvjnYNUqAYQYr_EKAX0LFw8g.YQJlLWb-VW_Vhb14Owce-malQWEsA0T26Z3TQEHjyRwg.JPEG/%EC%97%B0%EC%8A%B5249.jpg
        ],
        media_files: [
          { file_size: 6_478_361 },
          { file_size: 6_266_584 },
          { file_size: 6_731_692 },
          { file_size: 7_104_825 },
          { file_size: 5_869_112 },
          { file_size: 6_488_599 },
          { file_size: 6_850_074 },
          { file_size: 6_472_427 },
          { file_size: 6_219_829 },
          { file_size: 7_753_930 },
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
          "[image]":[http://blogfiles.naver.net/MjAyNjAxMDhfMjM1/MDAxNzY3ODYzMTQ1NzE3.X1uhHyomt-NFXliaDTrfSXRd6U1iRjyng5EH9xCd8PYg.b_ke3PbhwYdz1ONXIDJNpvSX_-GmUmAkJMgLVziZXBog.JPEG/가야보정.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNjAxMDhfMTUy/MDAxNzY3ODYzMTQ3MzA3.kl7YVWYrh6jfo8cHu-Xrw2buhVl1HinMQl_Zrr_7zFQg.abPpK-w_V_IRVjMx0jlFrXf4InuiecgbU1-O6qF3I0sg.JPEG/연습239.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNjAxMDhfOTcg/MDAxNzY3ODYzMTQ3NTAy.MmEFeHnY4mbiq8ApPO_0jlV0-UzvFd5wL79TYWdSYCUg.m6b_L9B4ihohWRGdOcImiwQ3SPPM8H6VtyA8Htz1S3Ag.JPEG/연습241.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNjAxMDhfMTU0/MDAxNzY3ODYzMTQ1NjE2.S0qnZOgri3vqcPpecDiwY9S6r3wUt2UnVFSoq230-Jwg.wz6uC8zC-hrSyPPNjD7UfWXFuvtSccdjBTZOCWiLl6wg.JPEG/연습242.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNjAxMDhfMTAz/MDAxNzY3ODYzMTQ1Mzc2.kH6_J10yDymCxwJ_0rnKLMGwA81_Zt8hDK00z9ehZRAg.fcfqg2temrCmRvEvhl3KNVQ9IZjELnk5Me0ITD7gzPEg.JPEG/연습244.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNjAxMDhfOTIg/MDAxNzY3ODYzMTQ1NTQ0.pWRM-ISlqiwevgyOA5uXffYBvaG_Iwmk00JmOeCywUcg.eZq4AqyunK-bTsm0ibCOx7VzflNmC-pw5kyHE-UNWMog.JPEG/연습245.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNjAxMDhfMjI1/MDAxNzY3ODYzMTQ1ODQx.0arV7saoekVZI8s7Js_pHJRrwhoy0ncu4R-FqSC7nlAg.tUzfdP_Mrcco1YM7DUAzodVrt3SRCxrc4EqQPcBLYVkg.JPEG/연습246.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNjAxMDhfMjc2/MDAxNzY3ODYzMTQ1NTkz.lXuZBTBUKlvgMfg0oq11TEAFbqZ-WtvnmyPJJNRa7LYg.eljyh-_f7SejWRMxUmAcCyx5dn1z58BKeqKSYfYsersg.JPEG/연습247.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNjAxMDhfMTI1/MDAxNzY3ODYzMTQ2OTkx.wGh4JEX2dajD2WoBBwpjr3mY_REf-g9UIA6vX0FBAeog.Yvo-hjsRheX45-dKaN5iewrt8AjBZ0mgCcWqsH_WONIg.JPEG/연습248.jpg]

          "[image]":[http://blogfiles.naver.net/MjAyNjAxMDhfMjE3/MDAxNzY3ODYzMTQ3Mzc3.mmd5jmzIExnA2iCeImmsUvjnYNUqAYQYr_EKAX0LFw8g.YQJlLWb-VW_Vhb14Owce-malQWEsA0T26Z3TQEHjyRwg.JPEG/연습249.jpg]

          [b]비얌Biyam[/b]

          블로그에 오신 것을 환영합니다.

          * 주인장은 뭐 하는 인간인가?

          기본적으로 웹툰작가 지망생으로, 현재는 (언젠가 있을지도 모를 공모전에 대비하며) 원고를 작업 중이며 동시에 틈틈이 그림을 그려 올리는 중. 한때 스타워즈를 사랑했으나 라스트 제다이에게 싸다구를 후려쳐맞고 현재는 애정이 끊겼다.

          2. 뭘 그리는가?

          주로 고증을 맞춘 역사 그림을 많이 그리지만 좋아하는 만화, 게임 등의 팬아트, 갑자기 삘 꽂혀서 그리는 캐릭터 디자인 등등을 그리는 중. 최근에 든 생각인데 특히 좋아하는 건 '고증에 맞으면서도 현대인에게 낯선 비주얼의 과거의 복식' 인 듯하다.

          3. <데뷔했어요, 수령님!>

          <https://comic.naver.com/challenge/list?titleId=846023>

          <https://comic.naver.com/challenge/list?titleId=846023>

          도전만화에서 연재 중인데 많이들 봐주십시오 감사합니다

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
