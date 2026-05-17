require "test_helper"

module Source::Tests::URL
  class PatreonUrlTest < ActiveSupport::TestCase
    context "Patreon URLs" do
      should be_image_url(
        "https://c10.patreonusercontent.com/4/patreon-media/p/post/71057815/d48874de48aa49f7878d32144de631fc/eyJ3Ijo2MjB9/1.jpg?token-time=1668384000&token-hash=9ORWv7LJBzmvzmHTi_xGFQ47Uis9fNzTPp2WweThDj4%3D",
        "https://c10.patreonusercontent.com/4/patreon-media/p/user/4045578/3101d8b9ba8348c592b68227f23b3568/eyJ3IjoyMDB9/1.jpeg?token-time=2145916800&token-hash=SQjWsty-7_MZqPt8R9_ZuJfzkW5F2pO3aqRV8iwZUIA%3D",
        "https://www.patreon.com/file?h=23563293&i=3053667",
      )

      should be_page_url(
        "https://www.patreon.com/m/posts/sparkle-71057815",
        "https://www.patreon.com/posts/71057815",
        "https://www.patreon.com/posts/sparkle-71057815",
        "https://www.patreon.com/api/posts/71057815",
        "https://www.patreon.com/nlch/shop/simple-life-with-my-unobtrusive-girl-1157344",
      )

      should be_profile_url(
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
      )

      should be_secondary_url(
        "https://www.patreon.com/bePatron?u=4045578",
        "https://www.patreon.com/user?u=5993691",
        "https://www.patreon.com/api/user/4045578",
      )

      should_not be_secondary_url(
        "https://www.patreon.com/1041uuu",
        "https://www.patreon.com/cw/iwanokenta",
      )

      should parse_url("https://www.patreon.com/profile/creators?u=7422057").into(
        profile_url: "https://www.patreon.com/user?u=7422057",
      )

      should parse_url("https://www.patreon.com/c/yaisirdrawz").into(
        profile_url: "https://www.patreon.com/yaisirdrawz",
      )

      should parse_url("https://www.patreon.com/cw/iwanokenta").into(
        profile_url: "https://www.patreon.com/iwanokenta",
      )

      should parse_url("https://www.patreon.com/nlch/shop/simple-life-with-my-unobtrusive-girl-1157344").into(
        page_url: "https://www.patreon.com/nlch/shop/simple-life-with-my-unobtrusive-girl-1157344",
        profile_url: "https://www.patreon.com/nlch",
      )
    end

    should parse_url("https://c10.patreonusercontent.com/4/patreon-media/p/post/71057815/d48874de48aa49f7878d32144de631fc/eyJ3Ijo2MjB9/1.jpg?token-time=1668384000&token-hash=9ORWv7LJBzmvzmHTi_xGFQ47Uis9fNzTPp2WweThDj4%3D").into(site_name: "Patreon")
  end
end
