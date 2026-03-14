require "test_helper"

module Source::Tests::URL
  class ToranoanaUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg",
        page_url: "https://ec.toranoana.jp/tora_r/ec/item/040030097695",
      )

      url_parser_should_work(
        "https://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg",
        page_url: "https://ec.toranoana.jp/tora_r/ec/item/040030653417",
      )
    end
  end
end
