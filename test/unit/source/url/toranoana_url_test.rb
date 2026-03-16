require "test_helper"

module Source::Tests::URL
  class ToranoanaUrlTest < ActiveSupport::TestCase
    context "Toranoana URLs" do
      should parse_url("http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg").into(
        page_url: "https://ec.toranoana.jp/tora_r/ec/item/040030097695",
      )

      should parse_url("https://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg").into(
        page_url: "https://ec.toranoana.jp/tora_r/ec/item/040030653417",
      )
    end

    should parse_url("http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg").into(site_name: "Toranoana")
  end
end
