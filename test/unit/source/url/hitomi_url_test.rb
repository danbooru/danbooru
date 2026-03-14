require "test_helper"

module Source::Tests::URL
  class HitomiUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "https://aa.hitomi.la/galleries/883451/t_rena1g.png",
        page_url: "https://hitomi.la/galleries/883451.html",
      )

      url_parser_should_work(
        "https://la.hitomi.la/galleries/1054851/001_main_image.jpg",
        page_url: "https://hitomi.la/reader/1054851.html#1",
      )
    end
  end
end
