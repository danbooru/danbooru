require "test_helper"

module Source::Tests::URL
  class LofterUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0",
          "http://imglf0.nosdn.127.net/img/cHl3bXNZdDRaaHBnNWJuN1Y4OXBqR01CeVBZSVNmU2FWZWtHc1h4ZTZiUGxlRzMwZnFDM1JnPT0.jpg ",
          "https://vodm2lzexwq.vod.126.net/vodm2lzexwq/Pc5jg1nL_3039990631_sd.mp4?resId=254486990bfa2cd7aa860229db639341_3039990631_1&sign=4j02HTHXqNfhaF%2B%2FO14Ny%2F9SMNZj%2FIjpJDCqXfYa4aM%3D",
        ],
        page_urls: [
          "https://gengar563.lofter.com/post/1e82da8c_1c98dae1b",
          "https://gengar563.lofter.com/front/post/1e82da8c_1c98dae1b",
          "https://uls.lofter.com/?h5url=https%3A%2F%2Flesegeng.lofter.com%2Fpost%2F1f0aec07_2bbc5ce0b",
        ],
        profile_urls: [
          "https://www.lofter.com/front/blog/home-page/noshiqian",
          "http://www.lofter.com/app/xiaokonggedmx",
          "http://www.lofter.com/blog/semblance",
          "http://gengar563.lofter.com",
          "https://www.lofter.com/mentionredirect.do?blogId=1278105311",
        ],
      )
    end
  end
end
