require "test_helper"

module Source::Tests::URL
  class ZerochanUrlTest < ActiveSupport::TestCase
    context "Zerochan URLs" do
      should be_image_url(
        "https://s4.zerochan.net/600/24/13/90674.jpg",
        "http://static.zerochan.net/full/24/13/90674.jpg",
        "https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png",
        "https://static.zerochan.net/THE.iDOLM%40STER.full.1262006.jpg",
        "https://static.zerochan.net/Lancer.(Fate.stay.night).full.2600383.jpg",
      )
      should be_page_url(
        "http://www.zerochan.net/full/1567893",
        "http://www.zerochan.net/1567893",
        "http://www.zerochan.net/1567893#full",
      )

      should parse_url("http://www.zerochan.net/full/1567893").into(work_id: "1567893")
      should parse_url("http://www.zerochan.net/1567893").into(work_id: "1567893")
      should parse_url("http://www.zerochan.net/1567893#full").into(work_id: "1567893")
      should parse_url("https://static.zerochan.net/Fullmetal.Alchemist.full.2831797.png").into(work_id: "2831797")

      should parse_url("https://s4.zerochan.net/600/24/13/90674.jpg").into(work_id: "90674")
      should parse_url("https://static.zerochan.net/Lancer.(Fate.stay.night).full.2600383.jpg").into(work_id: "2600383")
    end
  end
end
