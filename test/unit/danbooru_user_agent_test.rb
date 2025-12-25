require "test_helper"

class UserAgentTest < ActiveSupport::TestCase
  def assert_product_equals(product, user_agent)
    assert_equal(product, Danbooru::UserAgent.new(user_agent).product)
  end

  def assert_device_equals(device, user_agent)
    assert_equal(device.to_s, Danbooru::UserAgent.new(user_agent).device.to_s)
  end

  context "UserAgent#product" do
    should "parse Chrome user agents correctly" do
      assert_product_equals("Chrome", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36")
      assert_product_equals("Chrome", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.106 Safari/537.36")
      assert_product_equals("Chrome", "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36")
      assert_product_equals("Chrome", "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/91.0.4472.80 Mobile/15E148 Safari/604.1")
      assert_product_equals("Chrome", "Mozilla/5.0 (iPad; CPU OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/91.0.4472.80 Mobile/15E148 Safari/604.1")
    end

    should "parse Firefox user agents correctly" do
      assert_product_equals("Firefox", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0")
      assert_product_equals("Firefox", "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:89.0) Gecko/20100101 Firefox/89.0")
      assert_product_equals("Firefox", "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0")
      assert_product_equals("Firefox", "Mozilla/5.0 (Windows NT 6.3; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0")
      assert_product_equals("Firefox", "Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0")
      assert_product_equals("Firefox", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0")
      assert_product_equals("Firefox", "Mozilla/5.0 (Android 11; Mobile; rv:89.0) Gecko/89.0 Firefox/89.0")
      assert_product_equals("Firefox", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:82.0) Gecko/20100101 Firefox/82.0")
      assert_product_equals("Firefox", "Mozilla/5.0 (X11; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0")
    end

    should "parse Opera user agents correctly" do
      assert_product_equals("Opera", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.128 Safari/537.36 OPR/75.0.3969.285")
      assert_product_equals("Opera", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.128 Safari/537.36 OPR/75.0.3969.285")
      assert_product_equals("Opera", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.101 Safari/537.36 OPR/77.0.4054.90")
      assert_product_equals("Opera", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 OPR/102.0.0.0 GLS/97.10.5999.100")
      assert_product_equals("Opera", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.101 Safari/537.36 OPR/77.0.4054.90")
      assert_product_equals("Opera", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.101 Safari/537.36 OPR/77.0.4054.90 (Edition Yx 05)")
      assert_product_equals("Opera", "Mozilla/5.0 (Linux; Android 12) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/114.0.5735.131 Mobile Opera/5 Safari/537.36")
      assert_product_equals("Opera", "Mozilla/5.0 (Linux; Android 10; Mi A2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.6261.149 Mobile Safari/537.36 OPR/81.6.4292.79147")
      assert_product_equals("Opera", "Mozilla/5.0 (Linux aarch64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/36.0.2128.0 OMI/4.8.0.129.Driver6.32 , _TV_MT5806/092.003.166.031 (Philips, PUG6654, wired)  CE-HTML/1.0 NETTV/4.6.0.2 SignOn/2.0 SmartTvA/5.0.0 WH1.0 en Opera/68.0.3618.31")
      assert_product_equals("Opera", "Opera/9.80 (Windows NT 6.1; WOW64) Presto/2.12.388 Version/12.17")
      assert_product_equals("Opera", "Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14")
      assert_product_equals("Opera", "Opera/9.80 (Android; Opera Mini/57.0.2254/191.236; U; en) Presto/2.12.423 Version/12.16")
      assert_product_equals("Opera", "Opera/9.80 (X11; Fedora; Linux x64) Presto/2.12.388 Version/12.18")
      assert_product_equals("Opera", "SAMSUNG-SM-B313E Opera/9.80 (J2ME/MIDP; Opera Mini/4.5.40318/191.283; U; en) Presto/2.12.423 Version/12.16")
    end

    should "parse Safari user agents correctly" do
      assert_product_equals("Safari", "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Mobile/15E148 Safari/604.1")
      assert_product_equals("Safari", "Mozilla/5.0 (iPhone; CPU iPhone OS 14_4_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1")
      assert_product_equals("Safari", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15")
      assert_product_equals("Safari", "Mozilla/5.0 (PlayStation; PlayStation 4/8.52) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15")
    end

    should "parse Edge user agents correctly" do
      assert_product_equals("Edge", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.54")
      assert_product_equals("Edge", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.59")
      assert_product_equals("Edge", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.19041")
      assert_product_equals("Edge", "Mozilla/5.0 (Linux; Android 10; SM-A102U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.116 Mobile Safari/537.36 EdgA/46.04.2.5157")
    end

    should "parse Internet Explorer user agents correctly" do
      assert_product_equals("Internet Explorer", "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko")
      assert_product_equals("Internet Explorer", "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; Touch; rv:11.0) like Gecko")
      assert_product_equals("Internet Explorer", "Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko")
      assert_product_equals("Internet Explorer", "Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Geck; GreenBrowser)")
      assert_product_equals("Internet Explorer", "Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko")
      assert_product_equals("Internet Explorer", "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)")
      assert_product_equals("Internet Explorer", "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 10.0; WOW64; Trident/7.0; Sleipnir6/6.4.12; SleipnirSiteUpdates/6.4.12)")
      assert_product_equals("Internet Explorer", "Mozilla/5.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/3.0),gzip(gfe)")
      assert_product_equals("Internet Explorer", "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/3.0),gzip(gfe)")
    end

    should "parse unusual browser user agents correctly" do
      assert_product_equals("NintendoBrowser", "Mozilla/5.0 (Nintendo WiiU) AppleWebKit/536.30 (KHTML, like Gecko) NX/3.0.4.2.13 NintendoBrowser/4.3.2.11274.US")
      assert_product_equals("NintendoBrowser", "Mozilla/5.0 (Nintendo Switch; WifiWebAuthApplet) AppleWebKit/606.4 (KHTML, like Gecko) NF/6.0.1.16.11 NintendoBrowser/5.1.0.20935")
      assert_product_equals("SmartTV", "Mozilla/5.0 (Linux; NetCast; U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36 SmartTV/10.0 Colt/2.0")
      assert_product_equals("Silk", "Mozilla/5.0 (PlayStation Vita 3.73) AppleWebKit/537.73 (KHTML, like Gecko) Silk/3.2")
      assert_product_equals("PS3 Internet Browser", "Mozilla/5.0 (PLAYSTATION 3 4.87) AppleWebKit/531.22.8 (KHTML, like Gecko)")
    end

    should "parse Mozilla/5.0 compatible user agents correctly" do
      assert_product_equals("AhrefsBot", "Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)")
      assert_product_equals("bingbot", "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)")
      assert_product_equals("coccocbot-web", "Mozilla/5.0 (compatible; coccocbot-web/1.0; +http://help.coccoc.com/searchengine)")
      assert_product_equals("Discordbot", "Mozilla/5.0 (compatible; Discordbot/2.0; +https://discordapp.com)")
      assert_product_equals("DotBot", "Mozilla/5.0 (compatible; DotBot/1.2; +https://opensiteexplorer.org/dotbot; help@moz.com)")
      assert_product_equals("Googlebot", "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.90 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")
      assert_product_equals("Googlebot", "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")
      assert_product_equals("Hydrus Client", "Mozilla/5.0 (compatible; Hydrus Client)")
      assert_product_equals("inoreader.com", "Mozilla/5.0 (compatible; inoreader.com; 1 subscribers)")
      assert_product_equals("MegaIndex.ru", "Mozilla/5.0 (compatible; MegaIndex.ru/2.0; +http://megaindex.com/crawler)")
      assert_product_equals("MJ12bot", "Mozilla/5.0 (compatible; MJ12bot/v1.4.8; http://mj12bot.com/)")
      assert_product_equals("Pinterestbot", "Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)")
      assert_product_equals("SauceNAO Booru Aggregator 1.0", "Mozilla/5.0 (compatible; SauceNAO Booru Aggregator 1.0)")
      assert_product_equals("SemrushBot", "Mozilla/5.0 (compatible; SemrushBot/7~bl; +http://www.semrush.com/bot.html)")
      assert_product_equals("YandexBot", "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)")
      assert_product_equals("YandexImages", "Mozilla/5.0 (compatible; YandexImages/3.0; +http://yandex.com/bots)")
    end

    should "parse name/x.y.z bot user agents correctly" do
      assert_product_equals("aiohttp", "Python/3.9 aiohttp/3.6.3")
      assert_product_equals("aiohttp", "Python/3.6 aiohttp/3.7.4.post0")
      assert_product_equals("Blogtrottr", "Blogtrottr/2.0")
      assert_product_equals("booru", "booru (https://github.com/AtlasTheBot/booru)")
      assert_product_equals("BooruNav.Android", "BooruNav.Android/1.0.0.296b")
      assert_product_equals("com.apple.Safari.SearchHelper", "com.apple.Safari.SearchHelper/16611.2.7.1.4 CFNetwork/1240.0.4 Darwin/20.5.0")
      assert_product_equals("CUMZONATORBOT", "CUMZONATORBOT/1.0 kotb")
      assert_product_equals("curl", "curl/7.61.1")
      assert_product_equals("facebookexternalhit", "facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)")
      assert_product_equals("facebookexternalhit", "facebookexternalhit/1.1;line-poker/1.0")
      assert_product_equals("feedparser", "feedparser/6.0.2 +https://github.com/kurtmckee/feedparser/")
      assert_product_equals("FeedDemon", "FeedDemon/4.5 (http://www.feeddemon.com/; Microsoft Windows)")
      assert_product_equals("FreshRSS", "FreshRSS/1.18.0 (Linux; https://freshrss.org)")
      assert_product_equals("Go-http-client", "Go-http-client/2.0")
      assert_product_equals("Googlebot-Image", "Googlebot-Image/1.0")
      assert_product_equals("Illustail", "Illustail/38 CFNetwork/1240.0.4 Darwin/20.5.0")
      assert_product_equals("ImageBoardAPI", "ImageBoardAPI/https://github.com/Kodehawa/imageboard-api")
      assert_product_equals("Irvine", "Irvine/1.3.0")
      assert_product_equals("iqdb", "iqdb/0.1 (+http://iqdb.org/)")
      assert_product_equals("LoliSnatcher_Droid", "LoliSnatcher_Droid/1.8.1")
      assert_product_equals("MetalBrowser", "MetalBrowser/5.0.0.0")
      assert_product_equals("multibooru", "multibooru/0.1beta (Linux)")
      assert_product_equals("node-fetch", "node-fetch/1.0 (+https://github.com/bitinn/node-fetch)")
      assert_product_equals("nori", "nori/3.5.0")
      assert_product_equals("okhttp", "okhttp/4.9.1")
      assert_product_equals("PassiveCrawler.green-hill", "PassiveCrawler.green-hill/1.0.0.1")
      assert_product_equals("Pybooru", "Pybooru/4.2.2")
      assert_product_equals("python-requests", "python-requests/2.22.0")
      assert_product_equals("Python-urllib", "Python-urllib/3.8")
      assert_product_equals("RSSOwlnix", "RSSOwlnix/2.8.0.202006031646 (Windows; U; en)")
      assert_product_equals("Slackbot 1.0", "Slackbot 1.0 (+https://api.slack.com/robots)")
      assert_product_equals("TelegramBot", "TelegramBot (like TwitterBot)")
      assert_product_equals("Tiny Tiny RSS", "Tiny Tiny RSS/21.06-7bd9572aa (http://tt-rss.org/)")
      assert_product_equals("Twitterbot", "Twitterbot/1.0")
      assert_product_equals("Wget", "Wget/1.21.1")
    end

    should "parse nonstandard bot user agents correctly" do
      assert_product_equals("Booru v1.2.0, a node package for booru searching", "Booru v1.2.0, a node package for booru searching (by AtlasTheBot)")
      assert_product_equals("BooruSharp", "Mozilla/5.0 BooruSharp")
      assert_product_equals("Danbooru-Aggregator", "Danbooru-Aggregator")
      assert_product_equals("EcchiBot", "EcchiBot / PrivateGER Discord Bot / Contact: <privateger@privateger.me>")
      assert_product_equals("got", "got (https://github.com/sindresorhus/got)")
      assert_product_equals("Kaori, a npm module for boorus. v2", "Kaori, a npm module for boorus. v2 (https://github.com/iCrawl/kaori/)")
      assert_product_equals("Ktor client", "Ktor client")
      assert_product_equals("Mantaro", "Mantaro/6.2.7/JDA-DiscordBot (https://github.com/Mantaro/MantaroBot)")
      assert_product_equals("Node", "Node/RssFeedEmitter (https://github.com/filipedeschamps/rss-feed-emitter)")
      assert_product_equals("Universal Booru Wrapper", "Universal Booru Wrapper (Alejandro Akbal)")
      assert_product_equals("Valve", "Valve/Steam HTTP Client 1.0")
      assert_product_equals("MobileSafari", "MobileSafari/604.1 CFNetwork/1240.0.4 Darwin/20.5.0")
      assert_product_equals("Mozilla", "Mozilla/5.0")
    end

    should "parse browser-like bot user agents correctly" do
      assert_product_equals("PetalBot", "Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)")
      assert_product_equals("Grabber", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:52.0) Gecko/20100101 Firefox/52.0 Grabber/7.5.1") # https://github.com/Bionus/imgbrd-grabber
      assert_product_equals("onlymash.flexbooru.play", "Mozilla/5.0 (Linux; U; Android 11; en_GB; M2101K7AG; Build/RKQ1.201022.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 onlymash.flexbooru.play/2.7.5.c1180 Mobile Safari/537.36") # https://github.com/flexbooru/flexbooru
    end

    should_eventually "parse unusual user agents correctly" do
      # spoofed by iMessage; see https://stackoverflow.com/questions/41499402 and https://www.reddit.com/r/iOSProgramming/comments/4wcake
      assert_product_equals("iMessage", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.4 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.4 facebookexternalhit/1.1 Facebot Twitterbot/1.0")

      assert_product_equals("Mastodon", "http.rb/3.2.0 (Mastodon/2.4.4; +https://queer.af/)")
      assert_product_equals("Mastodon", "http.rb/4.4.1 (Mastodon/3.4.0; +https://mastodon.social/) Bot")
      assert_product_equals("Mastodon", "http.rb/4.4.1 (Mastodon/3.4.1; +https://raru.re/) Bot")

      # Mozilla/5.0 (Nintendo 3DS; U; ; en) Version/1.7639.EU
    end
  end

  context "UserAgent#device" do
    should "parse Android manufacturer and model names correctly" do
      assert_device_equals("SAMSUNG SM-G781B", "Mozilla/5.0 (Linux; Android 13; SAMSUNG SM-G781B) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/23.0 Chrome/115.0.0.0 Mobile Safari/537.36")
      assert_device_equals("LE2115", "Mozilla/5.0 (Linux; Android 14; LE2115 Build/UKQ1.230924.001) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.7103.125 Mobile Safari/537.36 OPT/2.9")
      assert_device_equals("Mi A2", "Mozilla/5.0 (Linux; Android 10; Mi A2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.6261.149 Mobile Safari/537.36 OPR/81.6.4292.79147")
      assert_device_equals("SM-A102U", "Mozilla/5.0 (Linux; Android 10; SM-A102U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.116 Mobile Safari/537.36 EdgA/46.04.2.5157")
      assert_device_equals("Nexus 5X", "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.90 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)")

      assert_device_equals(nil, "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36")
      assert_device_equals(nil, "Mozilla/5.0 (Android 11; Mobile; rv:89.0) Gecko/89.0 Firefox/89.0")
      assert_device_equals(nil, "Mozilla/5.0 (Linux; U; Android 11; en_GB; M2101K7AG; Build/RKQ1.201022.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 onlymash.flexbooru.play/2.7.5.c1180 Mobile Safari/537.36")
      assert_device_equals(nil, "Opera/9.80 (Android; Opera Mini/57.0.2254/191.236; U; en) Presto/2.12.423 Version/12.16")
    end
  end
end
