require 'test_helper'

module Sources
  class TwitPicTest < ActiveSupport::TestCase
    context "normalizing for source" do
      should "normalize d3j5vwomefv46c.cloudfront.net links" do
        source = "http://d3j5vwomefv46c.cloudfront.net/photos/large/820960031.jpg?1384107199"
        assert_equal("https://twitpic.com/dks0tb", Sources::Strategies.normalize_source(source))
      end

      should "normalize dn3pm25xmtlyu.cloudfront.net links" do
        source = "https://dn3pm25xmtlyu.cloudfront.net/photos/large/839006715.jpg?Expires=1646850828&Signature=d60CmLlmNqZJvOTteTOan13QWZ8gY3C4rUWCkh-IUoRr012vYtUYtip74GslGwCG0dxV5mpUpVFkaVZf16PiY7CsTdpAlA8Pmu2tN98D2dmC5FuW9KhhygDv6eFC8faoaGEyj~ArLuwz-8lC6Y05TVf0FgweeWwsRxFOfD5JHgCeIB0iZqzUx1t~eb6UMAWvbaKpfgvcp2oaDuCdZlMNi9T5OUBFoTh2DfnGy8t5COys1nOYYfZ9l69TDvVb2PKBaV8lsKK9xMwjoJNaWa1HL5S4MgODS5hiNDvycoBpu9KUvQ7q~rhC8cV6ZNctB5H9u~MmvBPoTKfy4w37cSc5uw__&Key-Pair-Id=APKAJROXZ7FN26MABHYA"
        assert_equal("https://twitpic.com/dvitq3", Sources::Strategies.normalize_source(source))
      end

      should "normalize o.twimg.com links" do
        source = "https://o.twimg.com/2/proxy.jpg?t=HBgpaHR0cHM6Ly90d2l0cGljLmNvbS9zaG93L2xhcmdlL2R0bnVydS5qcGcUsAkU0ggAFgASAA&s=dnN4DHCdnojC-iCJWdvZ-UZinrlWqAP7k7lmll2fTxs"
        assert_equal("https://twitpic.com/dtnuru", Sources::Strategies.normalize_source(source))
      end
    end
  end
end
