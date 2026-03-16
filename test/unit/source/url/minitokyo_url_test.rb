require "test_helper"

module Source::Tests::URL
  class MinitokyoUrlTest < ActiveSupport::TestCase
    context "Minitokyo URLs" do
      should parse_url("http://static.minitokyo.net/downloads/27/13/365677.jpg?433592448,Minitokyo.Eien.no.Aselia.Scans_365677.jpg").into(
        page_url: "http://gallery.minitokyo.net/view/365677",
      )

      should parse_url("http://static.minitokyo.net/downloads/14/33/199164.jpg?928244019").into(
        page_url: "http://gallery.minitokyo.net/view/199164",
      )
    end

    should parse_url("http://static.minitokyo.net/downloads/27/13/365677.jpg?433592448").into(site_name: "Minitokyo")
  end
end
