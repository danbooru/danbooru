require "test_helper"

module Source::URL::Tests
  class ArcaLiveParserTest < ActiveSupport::TestCase
    should_recognize_image_urls(
      "https://ac2.namu.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5.jpg?type=orig",
    )

    should_recognize_page_urls(
      "https://arca.live/b/arknights/66031722?p=1",
    )

    should_recognize_profile_urls(
      "https://arca.live/u/@Si리링",
      "https://arca.live/u/@Nauju/45320365",
    )

    url_parser_should_work(
      "https://arca.live/u/@%EC%9C%BE%ED%8C%8C",
      username: "윾파",
    )
  end
end
