require "test_helper"

module Source::Tests::URL
  class PixivUrlTest < ActiveSupport::TestCase
    context "Pixiv URLs" do
      should be_image_url(
        "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png",
        "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg",
        "https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip",
        "https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg",
        "https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png",
        "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg",
        "http://img18.pixiv.net/img/evazion/14901720.png",
        "http://i2.pixiv.net/img18/img/evazion/14901720.png",
        "https://i.pximg.net/imgaz/upload/20240417/163474511.jpg",
      )

      should be_image_sample(
        "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg",
        "https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira600x600.zip",
        "https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip",
        "https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg",
        "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg",
        "http://img18.pixiv.net/img/evazion/14901720.png",
        "http://i2.pixiv.net/img18/img/evazion/14901720.png",
      )

      should be_page_url(
        "https://www.pixiv.net/en/artworks/46324488",
        "https://www.pixiv.net/artworks/46324488",
        "http://www.pixiv.net/i/18557054",
        "http://p.tl/i/18557054",
        "http://phixiv.net/artworks/18557054",
        "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054",
        "http://www.pixiv.net/member_illust.php?mode=big&illust_id=18557054",
        "http://www.pixiv.net/member_illust.php?mode=manga&illust_id=18557054",
        "http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=18557054&page=1",
        "https://www.pixiv.net/novel/series/9593812",
        "https://www.pixiv.net/novel/show.php?id=18588585",
        "https://embed.pixiv.net/novel.php?id=18588585&mdate=20221102100423",
      )

      should be_profile_url(
        "https://www.pixiv.net/member.php?id=339253",
        "https://www.pixiv.net/u/9202877",
        "https://www.pixiv.net/users/9202877",
        "https://www.pixiv.net/en/users/9202877",
        "https://www.pixiv.net/stacc/noizave",
        "http://www.pixiv.me/noizave",
        "https://pixiv.cc/zerousagi/",
        "https://p.tl/m/9202877",
      )

      should_not be_image_sample(
        "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png",
        "https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip?original",
        "https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png",
        "https://www.pixiv.net/artworks/46324488",
        "https://i.pximg.net/imgaz/upload/20240417/163474511.jpg",
      )
    end

    context "when extracting attributes" do
      context "for illust ids" do
        should parse_url("https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg").into(work_id: "46785915")
        should parse_url("https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png").into(work_id: "79584713")

        should parse_url("http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p0.png").into(work_id: "46304396")
        should parse_url("http://i1.pixiv.net/c/600x600/img-master/img/2014/10/02/13/51/23/46304396_p0_master1200.jpg").into(work_id: "46304396")

        should parse_url("http://img18.pixiv.net/img/evazion/14901720.png").into(work_id: "14901720")
        should parse_url("http://i2.pixiv.net/img18/img/evazion/14901720.png").into(work_id: "14901720")
        should parse_url("http://i2.pixiv.net/img18/img/evazion/14901720_m.png").into(work_id: "14901720")
        should parse_url("http://i2.pixiv.net/img18/img/evazion/14901720_s.png").into(work_id: "14901720")

        should parse_url("http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png").into(work_id: "18557054")
        should parse_url("http://i1.pixiv.net/img07/img/pasirism/18557054_big_p1.png").into(work_id: "18557054")
        should parse_url("http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg").into(work_id: "18557054")
        should parse_url("http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png").into(work_id: "18557054")
        should parse_url("http://www.pixiv.net/i/18557054").into(work_id: "18557054")

        should parse_url("http://www.pixiv.net/en/artworks/18557054").into(work_id: "18557054")
        should parse_url("http://www.pixiv.net/artworks/18557054").into(work_id: "18557054")
        should parse_url("http://p.tl/i/18557054").into(work_id: "18557054")
        should parse_url("http://phixiv.net/artworks/18557054").into(work_id: "18557054")

        should parse_url("https://i.pximg.net/img-master/img/2025/08/22/20/18/32/141762848-757de2f8c8f77f2f637b61e4c9f42ec4_p0_master1200.jpg").into(work_id: "141762848")
        should parse_url("https://i.pximg.net/c/250x250_80_a2/img-master/img/2026/03/01/07/35/25/141762848-757d4d64b92a41c496c04aa34ae56855_p0_square1200.jpg").into(work_id: "141762848")
        should parse_url("https://i.pximg.net/img-original/img/2025/08/22/20/18/32/141762848-757de2f8c8f77f2f637b61e4c9f42ec4_p0.jpg").into(work_id: "141762848")

        should parse_url("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=46324488").into(work_id: "46324488")
        should parse_url("https://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46324488&page=0").into(work_id: "46324488")
        should parse_url("https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png").into(work_id: "46324488")
        should parse_url("https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg").into(work_id: "46324488")
        should parse_url("http://i1.pixiv.net/img-zip-ugoira/img/2014/10/03/17/29/16/46323924_ugoira1920x1080.zip").into(work_id: "46323924")

        should parse_url("https://i.pximg.net/novel-cover-original/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42.jpg").into(work_id: nil)
        should parse_url("https://i.pximg.net/c/600x600/novel-cover-master/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42_master1200.jpg").into(work_id: nil)
        should parse_url("https://www.pixiv.net/novel/show.php?id=10617324").into(work_id: nil)

        should parse_url("https://www.pixiv.net/member_illust.php").into(work_id: nil)
        should parse_url("https://www.pixiv.net/member_illust.php?illust_id=64476642&mode=medium").into(work_id: "64476642")

        should parse_url("http://img25.pixiv.net/img/master4th/16024681").into(work_id: nil)
        should parse_url("https://i.pximg.net/imgaz/upload/20240417/163474511.jpg").into(work_id: nil)
      end

      context "for normal images" do
        should parse_url("http://i2.pixiv.net/img12/img/zenze/39749565.png").into(
          page_url: "https://www.pixiv.net/artworks/39749565",
        )

        should parse_url("http://i1.pixiv.net/img53/img/themare/39735353_big_p1.jpg").into(
          page_url: "https://www.pixiv.net/artworks/39735353",
        )

        should parse_url("http://i1.pixiv.net/c/150x150/img-master/img/2010/11/30/08/39/58/14901720_p0_master1200.jpg").into(
          page_url: "https://www.pixiv.net/artworks/14901720",
        )

        should parse_url("http://i1.pixiv.net/img-original/img/2010/11/30/08/39/58/14901720_p0.png").into(
          page_url: "https://www.pixiv.net/artworks/14901720",
        )

        should parse_url("http://i2.pixiv.net/img-zip-ugoira/img/2014/08/05/06/01/10/44524589_ugoira1920x1080.zip").into(
          page_url: "https://www.pixiv.net/artworks/44524589",
        )

        should parse_url("https://i.pximg.net/img-master/img/2025/08/22/20/18/32/141762848-757de2f8c8f77f2f637b61e4c9f42ec4_p0_master1200.jpg").into(
          page_url: "https://www.pixiv.net/artworks/141762848",
        )
      end

      context "for proxies" do
        should parse_url("http://phixiv.net/artworks/18557054").into(
          page_url: "https://www.pixiv.net/artworks/18557054",
        )
      end

      context "for novel images" do
        should parse_url("https://i.pximg.net/c/480x960/novel-cover-master/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc_master1200.jpg").into(
          page_url: "https://www.pixiv.net/novel/series/9593812",
        )

        should parse_url("https://i.pximg.net/novel-cover-original/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc.jpg").into(
          page_url: "https://www.pixiv.net/novel/series/9593812",
        )

        should parse_url("https://embed.pixiv.net/novel.php?id=18588585&mdate=20221102100423").into(
          page_url: "https://www.pixiv.net/novel/show.php?id=18588585",
        )

        should parse_url("https://i.pximg.net/c/600x600/novel-cover-master/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4_master1200.jpg").into(
          page_url: "https://www.pixiv.net/novel/show.php?id=18588585",
        )

        should parse_url("https://i.pximg.net/novel-cover-original/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4.jpg").into(
          page_url: "https://www.pixiv.net/novel/show.php?id=18588585",
        )

        should parse_url("https://i.pximg.net/c/1200x1200/novel-cover-master/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5_master1200.jpg").into(
          page_url: nil,
        )

        should parse_url("https://i.pximg.net/novel-cover-original/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5.jpg").into(
          page_url: nil,
        )

        should parse_url("https://i.pximg.net/novel-cover-original/img/2018/04/02/19/38/29/9434677_6ab6c651d5568ff39e2ba6ab45edaf28.jpg").into(
          page_url: "https://www.pixiv.net/novel/show.php?id=9434677",
        )

        should parse_url("http://i1.pixiv.net/novel-cover-original/img/2016/11/11/20/11/46/7463785_0e2446dc1671dd3a4937dfaee39c227f.jpg").into(
          page_url: "https://www.pixiv.net/novel/show.php?id=7463785",
        )
      end
    end
  end
end
