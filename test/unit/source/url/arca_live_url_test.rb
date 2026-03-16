require "test_helper"

module Source::Tests::URL
  class ArcaLiveUrlTest < ActiveSupport::TestCase
    context "ArcaLive URLs" do
      should be_image_url(
        "https://ac.namu.la/20221211sac/5ea7fbca5e49ec16beb099fc6fc991690d37552e599b1de8462533908346241e.png",
        "https://ac2.namu.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5.jpg?type=orig",
      )

      should be_page_url(
        "https://arca.live/b/arknights/66031722?p=1",
      )

      should be_profile_url(
        "https://arca.live/u/@Si리링",
        "https://arca.live/u/@Nauju/45320365",
      )

      should parse_url("https://arca.live/u/@%EC%9C%BE%ED%8C%8C").into(username: "윾파")
    end

    should parse_url("https://ac.namu.la/20221211sac/5ea7fbca5e49ec16beb099fc6fc991690d37552e599b1de8462533908346241e.png").into(site_name: "Arca.live")
  end
end
