require "test_helper"

module Source::Tests::URL
  class TwitPicUrlTest < ActiveSupport::TestCase
    context "TwitPic URLs" do
      should be_image_url(
        "https://twitpic.com/show/large/carwkf.jpg",
        "https://o.twimg.com/1/proxy.jpg?t=FQQVBBgpaHR0cHM6Ly90d2l0cGljLmNvbS9zaG93L2xhcmdlL2NhcndrZi5qcGcUBBYAEgA&s=y8haxddqxJYpWql9uVnP3aoFFS7rA10vOGPdTO5HXvk",
        "http://d3j5vwomefv46c.cloudfront.net/photos/large/820960031.jpg?1384107199",
      )

      should be_page_url(
        "https://twitpic.com/carwkf",
      )

      should be_profile_url(
        "http://twitpic.com/photos/Type10TK",
      )

      should parse_url("http://d3j5vwomefv46c.cloudfront.net/photos/large/820960031.jpg?1384107199").into(
        page_url: "https://twitpic.com/dks0tb",
      )

      should parse_url("https://dn3pm25xmtlyu.cloudfront.net/photos/large/839006715.jpg?Expires=1646850828&Signature=d60CmLlmNqZJvOTteTOan13QWZ8gY3C4rUWCkh-IUoRr012vYtUYtip74GslGwCG0dxV5mpUpVFkaVZf16PiY7CsTdpAlA8Pmu2tN98D2dmC5FuW9KhhygDv6eFC8faoaGEyj~ArLuwz-8lC6Y05TVf0FgweeWwsRxFOfD5JHgCeIB0iZqzUx1t~eb6UMAWvbaKpfgvcp2oaDuCdZlMNi9T5OUBFoTh2DfnGy8t5COys1nOYYfZ9l69TDvVb2PKBaV8lsKK9xMwjoJNaWa1HL5S4MgODS5hiNDvycoBpu9KUvQ7q~rhC8cV6ZNctB5H9u~MmvBPoTKfy4w37cSc5uw__&Key-Pair-Id=APKAJROXZ7FN26MABHYA").into(
        page_url: "https://twitpic.com/dvitq3",
      )

      should parse_url("https://o.twimg.com/2/proxy.jpg?t=HBgpaHR0cHM6Ly90d2l0cGljLmNvbS9zaG93L2xhcmdlL2R0bnVydS5qcGcUsAkU0ggAFgASAA&s=dnN4DHCdnojC-iCJWdvZ-UZinrlWqAP7k7lmll2fTxs").into(
        page_url: "https://twitpic.com/dtnuru",
      )
    end

    should parse_url("https://twitpic.com/show/large/carwkf.jpg").into(site_name: "TwitPic")
  end
end
