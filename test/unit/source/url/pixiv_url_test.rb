require "test_helper"

module Source::Tests::URL
  class PixivUrlTest < ActiveSupport::TestCase
    def assert_illust_id(illust_id, url)
      if illust_id.nil?
        assert_nil(Source::URL.parse(url).work_id)
      else
        assert_equal(illust_id, Source::URL.parse(url).work_id.to_i)
      end
    end

    context "parsing illust ids" do
      should "parse ids from illust urls" do
        assert_illust_id(46_785_915, "https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg")
        assert_illust_id(79_584_713, "https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png")

        assert_illust_id(46_304_396, "http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p0.png")
        assert_illust_id(46_304_396, "http://i1.pixiv.net/c/600x600/img-master/img/2014/10/02/13/51/23/46304396_p0_master1200.jpg")

        assert_illust_id(14_901_720, "http://img18.pixiv.net/img/evazion/14901720.png")
        assert_illust_id(14_901_720, "http://i2.pixiv.net/img18/img/evazion/14901720.png")
        assert_illust_id(14_901_720, "http://i2.pixiv.net/img18/img/evazion/14901720_m.png")
        assert_illust_id(14_901_720, "http://i2.pixiv.net/img18/img/evazion/14901720_s.png")

        assert_illust_id(18_557_054, "http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png")
        assert_illust_id(18_557_054, "http://i1.pixiv.net/img07/img/pasirism/18557054_big_p1.png")
        assert_illust_id(18_557_054, "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg")
        assert_illust_id(18_557_054, "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png")
        assert_illust_id(18_557_054, "http://www.pixiv.net/i/18557054")

        assert_illust_id(18_557_054, "http://www.pixiv.net/en/artworks/18557054")
        assert_illust_id(18_557_054, "http://www.pixiv.net/artworks/18557054")
        assert_illust_id(18_557_054, "http://p.tl/i/18557054")
      end

      should "parse ids from expicit/guro illust urls" do
        assert_illust_id(46_324_488, "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=46324488")
        assert_illust_id(46_324_488, "https://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46324488&page=0")
        assert_illust_id(46_324_488, "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png")
        assert_illust_id(46_324_488, "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg")

        assert_illust_id(46_323_924, "http://i1.pixiv.net/img-zip-ugoira/img/2014/10/03/17/29/16/46323924_ugoira1920x1080.zip")
      end

      should "not misparse ids from novel urls" do
        assert_illust_id(nil, "https://i.pximg.net/novel-cover-original/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42.jpg")
        assert_illust_id(nil, "https://i.pximg.net/c/600x600/novel-cover-master/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42_master1200.jpg")
        assert_illust_id(nil, "https://www.pixiv.net/novel/show.php?id=10617324")
      end

      should "not misparse /member_illust.php urls" do
        assert_illust_id(nil, "https://www.pixiv.net/member_illust.php")
        assert_illust_id(64_476_642, "https://www.pixiv.net/member_illust.php?illust_id=64476642&mode=medium")
      end

      should "not misparse broken image urls" do
        assert_illust_id(nil, "http://img25.pixiv.net/img/master4th/16024681")
      end

      should "not misparse imgaz urls" do
        assert_illust_id(nil, "https://i.pximg.net/imgaz/upload/20240417/163474511.jpg")
      end
    end

    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png",
          "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg",
          "https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip",
          "https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg",
          "https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png",
          "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg",
          "http://img18.pixiv.net/img/evazion/14901720.png",
          "http://i2.pixiv.net/img18/img/evazion/14901720.png",
          "https://i.pximg.net/imgaz/upload/20240417/163474511.jpg",
        ],
        image_samples: [
          "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg",
          "https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira600x600.zip",
          "https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip",
          "https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg",
          "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg",
          "http://img18.pixiv.net/img/evazion/14901720.png",
          "http://i2.pixiv.net/img18/img/evazion/14901720.png",
        ],
        page_urls: [
          "https://www.pixiv.net/en/artworks/46324488",
          "https://www.pixiv.net/artworks/46324488",
          "http://www.pixiv.net/i/18557054",
          "http://p.tl/i/18557054",
          "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054",
          "http://www.pixiv.net/member_illust.php?mode=big&illust_id=18557054",
          "http://www.pixiv.net/member_illust.php?mode=manga&illust_id=18557054",
          "http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=18557054&page=1",
          "https://www.pixiv.net/novel/series/9593812",
          "https://www.pixiv.net/novel/show.php?id=18588585",
          "https://embed.pixiv.net/novel.php?id=18588585&mdate=20221102100423",
        ],
        profile_urls: [
          "https://www.pixiv.net/member.php?id=339253",
          "https://www.pixiv.net/u/9202877",
          "https://www.pixiv.net/users/9202877",
          "https://www.pixiv.net/en/users/9202877",
          "https://www.pixiv.net/stacc/noizave",
          "http://www.pixiv.me/noizave",
          "https://pixiv.cc/zerousagi/",
          "https://p.tl/m/9202877",
        ],
      )
      should_not_find_false_positives(
        image_samples: [
          "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png",
          "https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip?original",
          "https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png",
          "https://www.pixiv.net/artworks/46324488",
          "https://i.pximg.net/imgaz/upload/20240417/163474511.jpg",
        ],
      )
    end

    context "when extracting attributes" do
      context "for normal images" do
        url_parser_should_work("http://i2.pixiv.net/img12/img/zenze/39749565.png",
                               page_url: "https://www.pixiv.net/artworks/39749565",)

        url_parser_should_work("http://i1.pixiv.net/img53/img/themare/39735353_big_p1.jpg",
                               page_url: "https://www.pixiv.net/artworks/39735353",)

        url_parser_should_work("http://i1.pixiv.net/c/150x150/img-master/img/2010/11/30/08/39/58/14901720_p0_master1200.jpg",
                               page_url: "https://www.pixiv.net/artworks/14901720",)

        url_parser_should_work("http://i1.pixiv.net/img-original/img/2010/11/30/08/39/58/14901720_p0.png",
                               page_url: "https://www.pixiv.net/artworks/14901720",)

        url_parser_should_work("http://i2.pixiv.net/img-zip-ugoira/img/2014/08/05/06/01/10/44524589_ugoira1920x1080.zip",
                               page_url: "https://www.pixiv.net/artworks/44524589",)
      end

      context "for novel images" do
        url_parser_should_work("https://i.pximg.net/c/480x960/novel-cover-master/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc_master1200.jpg",
                               page_url: "https://www.pixiv.net/novel/series/9593812",)

        url_parser_should_work("https://i.pximg.net/novel-cover-original/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc.jpg",
                               page_url: "https://www.pixiv.net/novel/series/9593812",)

        url_parser_should_work("https://embed.pixiv.net/novel.php?id=18588585&mdate=20221102100423",
                               page_url: "https://www.pixiv.net/novel/show.php?id=18588585",)

        url_parser_should_work("https://i.pximg.net/c/600x600/novel-cover-master/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4_master1200.jpg",
                               page_url: "https://www.pixiv.net/novel/show.php?id=18588585",)

        url_parser_should_work("https://i.pximg.net/novel-cover-original/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4.jpg",
                               page_url: "https://www.pixiv.net/novel/show.php?id=18588585",)

        url_parser_should_work("https://i.pximg.net/c/1200x1200/novel-cover-master/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5_master1200.jpg",
                               page_url: nil,)

        url_parser_should_work("https://i.pximg.net/novel-cover-original/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5.jpg",
                               page_url: nil,)

        url_parser_should_work("https://i.pximg.net/novel-cover-original/img/2018/04/02/19/38/29/9434677_6ab6c651d5568ff39e2ba6ab45edaf28.jpg",
                               page_url: "https://www.pixiv.net/novel/show.php?id=9434677",)

        url_parser_should_work("http://i1.pixiv.net/novel-cover-original/img/2016/11/11/20/11/46/7463785_0e2446dc1671dd3a4937dfaee39c227f.jpg",
                               page_url: "https://www.pixiv.net/novel/show.php?id=7463785",)
      end
    end
  end
end
