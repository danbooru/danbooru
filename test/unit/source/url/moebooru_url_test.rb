require "test_helper"

module Source::Tests::URL
  class MoebooruUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://yande.re/sample/ceb6a12e87945413a95b90fada406f91/.jpg",
          "https://yande.re/jpeg/22577d2344fe694cf47f80563031b3cd.jpg",
          "https://assets.yande.re/data/preview/7e/cf/7ecfdead705d7b956b26b1d37b98d089.jpg",
          "https://ayase.yande.re/image/2d0d229fd8465a325ee7686fcc7f75d2/yande.re%20192481%20animal_ears%20bunny_ears%20garter_belt%20headphones%20mitha%20stockings%20thighhighs.jpg",
          "https://yuno.yande.re/image/1764b95ae99e1562854791c232e3444b/yande.re%20281544%20cameltoe%20erect_nipples%20fundoshi%20horns%20loli%20miyama-zero%20sarashi%20sling_bikini%20swimsuits.jpg",
          "https://konachan.com/data/preview/5d/63/5d633771614e4bf5c17df19a0f0f333f.jpg",
          "https://konachan.com/sample/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20sample.jpg",
          "https://konachan.com/jpeg/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20banishment%20bicycle%20grass%20group%20male%20night%20original%20rooftop%20scenic%20signed%20stars%20tree.jpg",
        ],
        page_urls: [
          "https://yande.re/post/show?md5=2c95b8975b73744da2bcbed9619c1d59",
          "https://yande.re/post?tags=md5:2c95b8975b73744da2bcbed9619c1d59",
          "https://yande.re/post/show/3",
          "https://konachan.com/post/show?md5=955aa45f3b452b415509b47dcc9475ac",
          "https://konachan.com/post?tags=md5:955aa45f3b452b415509b47dcc9475ac",
          "https://konachan.com/post/show/270803/banishment-bicycle-grass-group-male-night-original",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://files.yande.re/image/b66909b940e8d77accab7c9b25aa4dc3/yande.re%20377828.png",
                             page_url: "https://yande.re/post/show/377828",)

      url_parser_should_work("https://files.yande.re/image/2a5d1d688f565cb08a69ecf4e35017ab/yande.re%20349790%20breast_hold%20kurashima_tomoyasu%20mahouka_koukou_no_rettousei%20naked%20nipples.jpg",
                             page_url: "https://yande.re/post/show/349790",)

      url_parser_should_work("https://files.yande.re/image/e4c2ba38de88ff1640aaebff84c84e81/469784.jpg",
                             page_url: "https://yande.re/post/show/469784",)

      url_parser_should_work("https://yande.re/image/b4b1d11facd1700544554e4805d47bb6/.png",
                             page_url: "https://yande.re/post/show?md5=b4b1d11facd1700544554e4805d47bb6",)

      url_parser_should_work("https://yande.re/jpeg/22577d2344fe694cf47f80563031b3cd.jpg",
                             page_url: "https://yande.re/post/show?md5=22577d2344fe694cf47f80563031b3cd",)

      url_parser_should_work("https://konachan.com/image/5d633771614e4bf5c17df19a0f0f333f/Konachan.com%20-%20270807%20black_hair%20bokuden%20clouds%20grass%20landscape%20long_hair%20original%20phone%20rope%20scenic%20seifuku%20skirt%20sky%20summer%20torii%20tree.jpg",
                             page_url: "https://konachan.com/post/show/270807",)

      url_parser_should_work("https://konachan.com/sample/e2e2994bae738ff52fff7f4f50b069d5/Konachan.com%20-%20270803%20sample.jpg",
                             page_url: "https://konachan.com/post/show/270803",)

      url_parser_should_work("https://konachan.com/image/99a3c4f10c327d54486259a74173fc0b.jpg",
                             page_url: "https://konachan.com/post/show?md5=99a3c4f10c327d54486259a74173fc0b",)
    end
  end
end
