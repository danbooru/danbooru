require "test_helper"

module Source::Tests::URL
  class MinitokyoUrlTest < ActiveSupport::TestCase
    context "Minitokyo URLs" do
      should be_image_url(
        "http://static.minitokyo.net/downloads/27/13/365677.jpg?433592448,Minitokyo.Eien.no.Aselia.Scans_365677.jpg",
        "http://static.minitokyo.net/downloads/42/26/571342-3.jpg",
        "http://static1.minitokyo.net/thumbs/42/26/571342-2.jpg",
      )

      should be_page_url(
        "http://gallery.minitokyo.net/view/365677",
        "http://gallery.minitokyo.net/download/332089",
        "http://gallery.minitokyo.net/download/571342/1",
      )

      should be_profile_url(
        "http://deto15.minitokyo.net",
      )

      should be_image_sample(
        "http://static1.minitokyo.net/thumbs/42/26/571342-2.jpg",
      )

      should parse_url("http://static.minitokyo.net/downloads/27/13/365677.jpg?433592448,Minitokyo.Eien.no.Aselia.Scans_365677.jpg").into(
        page_url: "http://gallery.minitokyo.net/view/365677",
      )

      should parse_url("http://static.minitokyo.net/downloads/14/33/199164.jpg?928244019").into(
        page_url: "http://gallery.minitokyo.net/view/199164",
      )

      should parse_url("http://gallery.minitokyo.net/download/332089").into(
        page_url: "http://gallery.minitokyo.net/view/332089",
      )

      should parse_url("http://gallery.minitokyo.net/download/571342/1").into(
        page_url: "http://gallery.minitokyo.net/view/571342",
      )

      should parse_url("http://static.minitokyo.net/downloads/27/13/365677.jpg?433592448").into(
        site_name: "Minitokyo",
      )
    end
  end
end
