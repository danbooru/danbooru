require "test_helper"

module Source::Tests::URL
  class ArcaLiveUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://ac.namu.la/20221211sac/5ea7fbca5e49ec16beb099fc6fc991690d37552e599b1de8462533908346241e.png",
          "https://ac2.namu.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5.jpg?type=orig",
        ],
        page_urls: [
          "https://arca.live/b/arknights/66031722?p=1",
        ],
        profile_urls: [
          "https://arca.live/u/@Si리링",
          "https://arca.live/u/@Nauju/45320365",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://arca.live/u/@%EC%9C%BE%ED%8C%8C", username: "윾파")
    end
  end
end
