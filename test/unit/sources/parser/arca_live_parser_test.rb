require "test_helper"

module Source::URL::Tests
  class ArcaLiveParserTest < ActiveSupport::TestCase
    context "for image urls" do
      should_recognize_image_urls(
        "https://ac2.namu.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5.jpg?type=orig",
      )
    end

    context "for page urls" do
      should_recognize_page_urls(
        "https://arca.live/b/arknights/66031722?p=1",
      )
    end

    context "for profile urls" do
      should_recognize_profile_urls(
        "https://arca.live/u/@Si리링",
        "https://arca.live/u/@Nauju/45320365",
      )
    end

    context "when parsing" do
      url_parser_should_work("https://arca.live/u/@%EC%9C%BE%ED%8C%8C", username: "윾파")
    end
  end
end
