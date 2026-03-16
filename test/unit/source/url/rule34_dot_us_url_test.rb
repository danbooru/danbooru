require "test_helper"

module Source::Tests::URL
  class Rule34DotUsUrlTest < ActiveSupport::TestCase
    context "Rule34.us URLs" do
      should be_image_url(
        "https://img2.rule34.us/images/23/66/236690fd962fa394edf9894450261dac.png",
        "https://img2.rule34.us/thumbnails/23/66/thumbnail_236690fd962fa394edf9894450261dac.jpg",
        "https://video.rule34.us/images/d8/1d/d81d79f0292cdb096a8653efa001342d.webm",
      )

      should be_page_url(
        "https://rule34.us/index.php?r=posts/view&id=6204967",
        "https://rule34.us/hotlink.php?hash=236690fd962fa394edf9894450261dac",
      )

      should parse_url("https://img2.rule34.us/images/23/66/236690fd962fa394edf9894450261dac.png").into(
        md5: "236690fd962fa394edf9894450261dac",
        full_image_url: "https://img2.rule34.us/images/23/66/236690fd962fa394edf9894450261dac.png",
        page_url: "https://rule34.us/hotlink.php?hash=236690fd962fa394edf9894450261dac",
      )

      should parse_url("https://img2.rule34.us/thumbnails/23/66/thumbnail_236690fd962fa394edf9894450261dac.jpg").into(
        md5: "236690fd962fa394edf9894450261dac",
        full_image_url: nil,
        page_url: "https://rule34.us/hotlink.php?hash=236690fd962fa394edf9894450261dac",
      )

      should parse_url("https://video.rule34.us/images/d8/1d/d81d79f0292cdb096a8653efa001342d.webm").into(
        md5: "d81d79f0292cdb096a8653efa001342d",
        full_image_url: "https://video.rule34.us/images/d8/1d/d81d79f0292cdb096a8653efa001342d.webm",
        page_url: "https://rule34.us/hotlink.php?hash=d81d79f0292cdb096a8653efa001342d",
      )

      should parse_url("https://rule34.us/index.php?r=posts/view&id=6204967").into(
        post_id: 6_204_967,
        page_url: "https://rule34.us/index.php?r=posts/view&id=6204967",
      )

      should parse_url("https://rule34.us/hotlink.php?hash=236690fd962fa394edf9894450261dac").into(
        md5: "236690fd962fa394edf9894450261dac",
        page_url: "https://rule34.us/hotlink.php?hash=236690fd962fa394edf9894450261dac",
      )
    end

    should parse_url("https://img2.rule34.us/images/23/66/236690fd962fa394edf9894450261dac.png").into(site_name: "Rule34.us")
  end
end
