require "test_helper"

module Source::Tests::URL
  class TumblrUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "http://data.tumblr.com/07e7bba538046b2b586433976290ee1f/tumblr_o3gg44HcOg1r9pi29o1_raw.jpg",
          "https://40.media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_1280.jpg",
          "https://media.tumblr.com/de018501416a465d898d24ad81d76358/tumblr_nfxt7voWDX1rsd4umo1_r23_raw.jpg",
          "https://66.media.tumblr.com/2c6f55531618b4335c67e29157f5c1fc/tumblr_pz4a44xdVj1ssucdno1_1280.png",
          "https://68.media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_250.gif",
          "https://media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_500.gif",
          "https://66.media.tumblr.com/b9395771b2d0435fe4efee926a5a7d9c/tumblr_pg2wu1L9DM1trd056o2_500h.png",
          "https://media.tumblr.com/701a535af224f89684d2cfcc097575ef/tumblr_pjsx70RakC1y0gqjko1_1280.pnj",
          "https://25.media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png",
          "https://media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_1280.png",
          "https://media.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_500.jpg",
          "https://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg",
          "https://va.media.tumblr.com/tumblr_pgohk0TjhS1u7mrsl.mp4",
          "https://66.media.tumblr.com/168dabd09d5ad69eb5fedcf94c45c31a/3dbfaec9b9e0c2e3-72/s640x960/bf33a1324f3f36d2dc64f011bfeab4867da62bc8.png",
          "https://66.media.tumblr.com/5a2c3fe25c977e2281392752ab971c90/3dbfaec9b9e0c2e3-92/s500x750/4f92bbaaf95c0b4e7970e62b1d2e1415859dd659.png",
          "https://static.tumblr.com/923d3a1b85bdabcb6276ea921911497f/w3ze2u2/mdHpc3im5/tumblr_static_cd6gq50ia8oc8s04kcok44gkc.jpg",
          "https://25.media.tumblr.com/91719d337b218681abc48cdc24e",
        ],
        profile_urls: [
          "https://www.tumblr.com/tawni-tailwind",
          "https://www.tumblr.com/dashboard/blog/dankwartart",
          "https://www.tumblr.com/blog/artofelaineho",
          "https://www.tumblr.com/blog/view/artofelaineho",
          "https://tumblr.com/tawni-tailwind",
          "https://tumblr.com/dashboard/blog/dankwartart",
          "https://tumblr.com/blog/kervalchan",
          "https://tumblr.com/blog/view/artofelaineho",
          "https://rosarrie.tumblr.com/archive",
          "https://solisnotte.tumblr.com/about",
          "https://whereisnovember.tumblr.com/tagged/art",
        ],
      )

      should_not_find_false_positives(
        image_urls: [
          "https://tumblr.com",
          "https://www.tumblr.com",
          "https://yogurtmedia.tumblr.com/post/45732863347",
        ],
        page_urls: [
          "https://25.media.tumblr.com/91719d337b218681abc48cdc24e",
        ],
        profile_urls: [
          "https://25.media.tumblr.com/91719d337b218681abc48cdc24e",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://octrain1020.tumblr.com/post/190713122589",
                             page_url: "https://octrain1020.tumblr.com/post/190713122589",)

      url_parser_should_work("https://octrain1020.tumblr.com/image/190713122589",
                             page_url: "https://octrain1020.tumblr.com/post/190713122589",)

      url_parser_should_work("https://octrain1020.tumblr.com/image/190713122589#asd",
                             page_url: "https://octrain1020.tumblr.com/post/190713122589",)

      url_parser_should_work("https://superboin.tumblr.com/post/141169066579/photoset_iframe/superboin/tumblr_o45miiAOts1u6rxu8/500/false",
                             page_url: "https://superboin.tumblr.com/post/141169066579",)

      url_parser_should_work("https://at.tumblr.com/pizza-and-ramen/118684413624/uqndb20nkyob",
                             page_url: "https://pizza-and-ramen.tumblr.com/post/118684413624",)

      url_parser_should_work("https://octrain1020.tumblr.com/", page_url: nil, blog_name: "octrain1020")

      url_parser_should_work("https://at.tumblr.com/cyanideqpoison/u2czj612ttzq",
                             profile_url: "https://cyanideqpoison.tumblr.com",)
    end
  end
end
