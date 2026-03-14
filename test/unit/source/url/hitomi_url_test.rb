require "test_helper"

module Source::Tests::URL
  class HitomiUrlTest < ActiveSupport::TestCase
    context "Hitomi URLs" do
      should parse_url("https://aa.hitomi.la/galleries/883451/t_rena1g.png").into(
        page_url: "https://hitomi.la/galleries/883451.html",
      )

      should parse_url("https://la.hitomi.la/galleries/1054851/001_main_image.jpg").into(
        page_url: "https://hitomi.la/reader/1054851.html#1",
      )
    end
  end
end
