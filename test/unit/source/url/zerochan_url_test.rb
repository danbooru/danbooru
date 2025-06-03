require "test_helper"

module Source::Tests::URL
  class ZerochanUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://s4.zerochan.net/600/24/13/90674.jpg",
          "http://static.zerochan.net/full/24/13/90674.jpg",
          "https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png",
          "https://static.zerochan.net/THE.iDOLM%40STER.full.1262006.jpg",
          "https://static.zerochan.net/Lancer.(Fate.stay.night).full.2600383.jpg",
        ],
        page_urls: [
          "http://www.zerochan.net/full/1567893",
          "http://www.zerochan.net/1567893",
          "http://www.zerochan.net/1567893#full",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("http://www.zerochan.net/full/1567893", work_id: "1567893")
      url_parser_should_work("http://www.zerochan.net/1567893", work_id: "1567893")
      url_parser_should_work("http://www.zerochan.net/1567893#full", work_id: "1567893")
      url_parser_should_work("https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png", work_id: "2831797")

      url_parser_should_work("https://s4.zerochan.net/600/24/13/90674.jpg", work_id: "90674")
      url_parser_should_work("https://static.zerochan.net/Lancer.(Fate.stay.night).full.2600383.jpg", work_id: "2600383")
    end
  end
end
