require "test_helper"

module Source::Tests::URL
  class MinitokyoUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://static.minitokyo.net/downloads/27/13/365677.jpg?433592448,Minitokyo.Eien.no.Aselia.Scans_365677.jpg",
        page_url: "http://gallery.minitokyo.net/view/365677",
      )

      url_parser_should_work(
        "http://static.minitokyo.net/downloads/14/33/199164.jpg?928244019",
        page_url: "http://gallery.minitokyo.net/view/199164",
      )
    end
  end
end
