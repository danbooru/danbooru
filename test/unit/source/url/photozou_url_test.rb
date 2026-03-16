require "test_helper"

module Source::Tests::URL
  class PhotozouUrlTest < ActiveSupport::TestCase
    context "Photozou URLs" do
      should parse_url("http://kura3.photozou.jp/pub/794/1481794/photo/161537258_org.v1364829097.jpg").into(
        page_url: "https://photozou.jp/photo/show/1481794/161537258",
      )

      should parse_url("http://art59.photozou.jp/pub/212/1986212/photo/118493247_org.v1534644005.jpg").into(
        page_url: "https://photozou.jp/photo/show/1986212/118493247",
      )
    end

    should parse_url("http://kura3.photozou.jp/pub/794/1481794/photo/161537258_org.v1364829097.jpg").into(site_name: "Photozou")
  end
end
