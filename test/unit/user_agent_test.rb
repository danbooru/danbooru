require "test_helper"

class UserAgentTest < ActiveSupport::TestCase
  def assert_name_equals(name, user_agent)
    assert_equal(name, UserAgent.new(user_agent).name)
  end

  context "UserAgent#name" do
    should "parse the user agent name correctly" do
      assert_name_equals("googlebot", "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.90 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html")
      assert_name_equals("yandexbot", "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)")
      assert_name_equals("bingbot", "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)")
      assert_name_equals("discordbot", "Mozilla/5.0 (compatible; Discordbot/2.0; +https://discordapp.com)")
      assert_name_equals("twitterbot", "Twitterbot/1.0")
      assert_name_equals("curl", "curl/7.61.1")
      assert_name_equals("https://github.com/AtlasTheBot/booru", "booru (https://github.com/AtlasTheBot/booru)")
      assert_name_equals("http://tt-rss.org/", "Tiny Tiny RSS/21.06-7bd9572aa (http://tt-rss.org/)")
      assert_name_equals("unknown-bot", "Booru v1.2.0, a node package for booru searching (by AtlasTheBot)")

      assert_name_equals("chrome", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36")
      assert_name_equals("firefox", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0")
      assert_name_equals("safari", "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Mobile/15E148 Safari/604.1")
      assert_name_equals("edge", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.54")
      assert_name_equals("opera", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.128 Safari/537.36 OPR/75.0.3969.285")
      assert_name_equals("opera", "Mozilla/5.0 (Linux; Android 10; Mi A2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.6261.149 Mobile Safari/537.36 OPR/81.6.4292.79147")
      assert_name_equals("opera", "Opera/9.80 (Windows NT 6.1; WOW64) Presto/2.12.388 Version/12.17")
      assert_name_equals("msie", "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko")
      assert_name_equals("unknown-browser", "Mozilla/5.0 (Nintendo WiiU) AppleWebKit/536.30 (KHTML, like Gecko) NX/3.0.4.2.13 NintendoBrowser/4.3.2.11274.US")
    end
  end
end
