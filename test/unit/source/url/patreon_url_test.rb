require "test_helper"

module Source::Tests::URL
  class PatreonUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://c10.patreonusercontent.com/4/patreon-media/p/post/71057815/d48874de48aa49f7878d32144de631fc/eyJ3Ijo2MjB9/1.jpg?token-time=1668384000&token-hash=9ORWv7LJBzmvzmHTi_xGFQ47Uis9fNzTPp2WweThDj4%3D",
          "https://c10.patreonusercontent.com/4/patreon-media/p/user/4045578/3101d8b9ba8348c592b68227f23b3568/eyJ3IjoyMDB9/1.jpeg?token-time=2145916800&token-hash=SQjWsty-7_MZqPt8R9_ZuJfzkW5F2pO3aqRV8iwZUIA%3D",
          "https://www.patreon.com/file?h=23563293&i=3053667",
        ],
        page_urls: [
          "https://www.patreon.com/m/posts/sparkle-71057815",
          "https://www.patreon.com/posts/71057815",
          "https://www.patreon.com/posts/sparkle-71057815",
          "https://www.patreon.com/api/posts/71057815",
        ],
        profile_urls: [
          "https://www.patreon.com/1041uuu",
          "https://www.patreon.com/checkout/1041uuu?rid=0",
          "https://www.patreon.com/join/twistedgrim/checkout?rid=704013&redirect_uri=/posts/noi-dorohedoro-39394158",
          "https://www.patreon.com/m/1041uuu/about",
          "https://www.patreon.com/bePatron?u=4045578",
          "https://www.patreon.com/user?u=5993691",
          "https://www.patreon.com/user/posts?u=84592583",
          "https://www.patreon.com/api/user/4045578",
          "https://www.patreon.com/profile/creators?u=7422057",
          "https://www.patreon.com/cw/iwanokenta",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://www.patreon.com/profile/creators?u=7422057",
                             profile_url: "https://www.patreon.com/user?u=7422057",)

      url_parser_should_work("https://www.patreon.com/c/yaisirdrawz",
                             profile_url: "https://www.patreon.com/yaisirdrawz",)

      url_parser_should_work("https://www.patreon.com/cw/iwanokenta",
                             profile_url: "https://www.patreon.com/iwanokenta",)
    end
  end
end
