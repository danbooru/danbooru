# frozen_string_literal: true

# Parses a user agent string and tries to determine whether it's a known bot or a known web browser.
#
# @see https://developers.whatismybrowser.com/
# @see https://developers.whatismybrowser.com/api/features/user-agent-checks/weird/
class UserAgent
  attr_reader :user_agent

  # Initialize a user agent
  #
  # @param user_agent [String] the user agent string
  def initialize(user_agent)
    @user_agent = user_agent.to_s
  end

  # @return [String] the name of the user agent
  def name
    if user_agent.blank?
      "blank"

    # Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
    # Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.90 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html
    # Googlebot-Image/1.0
    elsif user_agent =~ %r{http://www\.google\.com/bot\.html} || user_agent =~ %r{Googlebot}
      "googlebot"

    # Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)
    # Mozilla/5.0 (compatible; YandexImages/3.0; +http://yandex.com/bots)
    elsif user_agent =~ %r{http://yandex\.com/bots}
      "yandexbot"

    # Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)
    elsif user_agent =~ %r{http://www\.bing\.com/bingbot\.htm}
      "bingbot"

    # Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)
    elsif user_agent =~ %r{PetalBot}
      "petalbot"

    # Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:52.0) Gecko/20100101 Firefox/52.0 Grabber/7.5.1
    # Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:52.0) Gecko/20100101 Firefox/52.0 Grabber/7.3.2
    # (see https://github.com/Bionus/imgbrd-grabber)
    elsif user_agent =~ %r{Firefox/52\.0 Grabber/[^ ]+\z}
      "imgbrd-grabber"

    # Mozilla/5.0 (Linux; U; Android 11; en_GB; M2101K7AG; Build/RKQ1.201022.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 onlymash.flexbooru.play/2.7.5.c1180 Mobile Safari/537.36
    # (see https://github.com/flexbooru/flexbooru)
    elsif user_agent =~ %r{flexbooru}
      "flexbooru"

    # Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/601.2.4 (KHTML, like Gecko) Version/9.0.1 Safari/601.2.4 facebookexternalhit/1.1 Facebot Twitterbot/1.0
    # (spoofed by iMessage; see https://stackoverflow.com/questions/41499402 and https://www.reddit.com/r/iOSProgramming/comments/4wcake)
    elsif user_agent =~ %r{\AMozilla/5.0.*facebookexternalhit.*Twitterbot}
      "imessage"

    # http.rb/3.2.0 (Mastodon/2.4.4; +https://queer.af/)
    # http.rb/4.4.1 (Mastodon/3.4.0; +https://mastodon.social/) Bot
    # http.rb/4.4.1 (Mastodon/3.4.1; +https://raru.re/) Bot
    elsif user_agent =~ %r{Mastodon}
      "mastodon"

    # facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)
    # facebookexternalhit/1.1;line-poker/1.0
    elsif user_agent =~ %r{\Afacebookexternallhit}
      "facebook"

    # Slackbot 1.0 (+https://api.slack.com/robots)
    elsif user_agent =~ %r{Slackbot}
      "slackbot"

    # TelegramBot (like TwitterBot)
    elsif user_agent =~ %r{\ATelegramBot}
      "telegrambot"

    # Python/3.9 aiohttp/3.6.3
    # Python/3.6 aiohttp/3.7.4.post0
    elsif user_agent =~ %r{aiohttp}
      "aiohttp"

    # Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)
    # Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 10.0; WOW64; Trident/7.0; Sleipnir6/6.4.12; SleipnirSiteUpdates/6.4.12)
    # Mozilla/5.0 (compatible; MSIE 7.0; Windows NT 6.1; Trident/3.0),gzip(gfe)
    # Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/3.0),gzip(gfe)
    elsif user_agent =~ %r{\AMozilla/[^ ]+ \(compatible; MSIE}
      "msie"

    # Mozilla/5.0 (compatible; Hydrus Client)
    # Mozilla/5.0 (compatible; SauceNAO Booru Aggregator 1.0)
    # Mozilla/5.0 (compatible; inoreader.com; 1 subscribers)
    # Mozilla/5.0 (compatible; AhrefsBot/7.0; +http://ahrefs.com/robot/)
    # Mozilla/5.0 (compatible; coccocbot-web/1.0; +http://help.coccoc.com/searchengine)
    # Mozilla/5.0 (compatible; SemrushBot/7~bl; +http://www.semrush.com/bot.html)
    # Mozilla/5.0 (compatible; Discordbot/2.0; +https://discordapp.com)
    # Mozilla/5.0 (compatible; DotBot/1.2; +https://opensiteexplorer.org/dotbot; help@moz.com)
    # Mozilla/5.0 (compatible; Pinterestbot/1.0; +http://www.pinterest.com/bot.html)
    # Mozilla/5.0 (compatible; MegaIndex.ru/2.0; +http://megaindex.com/crawler)
    # Mozilla/5.0 (compatible; MJ12bot/v1.4.8; http://mj12bot.com/)
    elsif user_agent =~ %r{\AMozilla/5\.0 \(compatible; ([^/;)]+)}
      $1.downcase

    # Opera/9.80 (Windows NT 6.1; WOW64) Presto/2.12.388 Version/12.17
    # Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14
    # Opera/9.80 (Android; Opera Mini/57.0.2254/191.236; U; en) Presto/2.12.423 Version/12.16
    # Opera/9.80 (X11; Fedora; Linux x64) Presto/2.12.388 Version/12.18
    elsif user_agent =~ %r{\AOpera/9\.80}
      "opera"

    # Blogtrottr/2.0
    # BooruNav.Android/1.0.0.296b
    # com.apple.Safari.SearchHelper/16611.2.7.1.4 CFNetwork/1240.0.4 Darwin/20.5.0
    # CUMZONATORBOT/1.0 kotb
    # curl/7.61.1
    # feedparser/6.0.2 +https://github.com/kurtmckee/feedparser/
    # FeedDemon/4.5 (http://www.feeddemon.com/; Microsoft Windows)
    # FreshRSS/1.18.0 (Linux; https://freshrss.org)
    # Go-http-client/2.0
    # Illustail/38 CFNetwork/1240.0.4 Darwin/20.5.0
    # ImageBoardAPI/https://github.com/Kodehawa/imageboard-api
    # Irvine/1.3.0
    # iqdb/0.1 (+http://iqdb.org/)
    # LoliSnatcher_Droid/1.8.1
    # Mantaro/6.2.7/JDA-DiscordBot (https://github.com/Mantaro/MantaroBot)
    # MetalBrowser/5.0.0.0
    # multibooru/0.1beta (Linux)
    # node-fetch/1.0 (+https://github.com/bitinn/node-fetch)
    # Node/RssFeedEmitter (https://github.com/filipedeschamps/rss-feed-emitter)
    # nori/3.5.0
    # okhttp/4.9.1
    # PassiveCrawler.green-hill/1.0.0.1
    # Pybooru/4.2.2
    # python-requests/2.22.0
    # Python-urllib/3.8
    # RSSOwlnix/2.8.0.202006031646 (Windows; U; en)
    # Twitterbot/1.0
    # Valve/Steam HTTP Client 1.0
    # Wget/1.21.1
    elsif user_agent !~ %r{\AMozilla/5\.0} && user_agent =~ %r{\A([^ /]*)/([^ ]+)}i
      $1.downcase

    # booru (https://github.com/AtlasTheBot/booru)
    # got (https://github.com/sindresorhus/got)
    # Kaori, a npm module for boorus. v2 (https://github.com/iCrawl/kaori/)
    # Tiny Tiny RSS/21.06-7bd9572aa (http://tt-rss.org/)
    elsif user_agent =~ %r{(https?://[^ )]+)}
      $1

    # Booru v1.2.0, a node package for booru searching (by AtlasTheBot)
    # Danbooru-Aggregator
    # EcchiBot / PrivateGER Discord Bot / Contact: <privateger@privateger.me>
    # Ktor client
    # MobileSafari/604.1 CFNetwork/1240.0.4 Darwin/20.5.0
    # Universal Booru Wrapper (Alejandro Akbal)
    # Mozilla/5.0
    # Mozilla/5.0 BooruSharp
    elsif user_agent !~ %r{\AMozilla/5\.0 \([^)]+\)}
      "unknown-bot"

    # Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0
    # Mozilla/5.0 (Windows NT 6.1; WOW64; rv:89.0) Gecko/20100101 Firefox/89.0
    # Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0
    # Mozilla/5.0 (Windows NT 6.3; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0
    # Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0
    # Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:78.0) Gecko/20100101 Firefox/78.0
    # Mozilla/5.0 (Android 11; Mobile; rv:89.0) Gecko/89.0 Firefox/89.0
    # Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:82.0) Gecko/20100101 Firefox/82.0
    # Mozilla/5.0 (X11; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0
    elsif user_agent =~ %r{Gecko/[^ ]+ Firefox/[^ ]+}
      "firefox"

    # Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36
    # Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.106 Safari/537.36
    # Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36
    elsif user_agent =~ %r{AppleWebKit/[^ ]+ \(KHTML, like Gecko\) Chrome/[^ ]+ Safari/[^ ]+\z}
      "chrome"

    # Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Mobile/15E148 Safari/604.1
    # Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/91.0.4472.80 Mobile/15E148 Safari/604.1
    # Mozilla/5.0 (iPhone; CPU iPhone OS 14_4_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0.3 Mobile/15E148 Safari/604.1
    # Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15
    # Mozilla/5.0 (iPad; CPU OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/91.0.4472.80 Mobile/15E148 Safari/604.1
    # Mozilla/5.0 (PlayStation; PlayStation 4/8.52) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15
    elsif user_agent =~ %r{AppleWebKit/[^ ]+ \(KHTML, like Gecko\).*Safari/[^ ]+\z} && user_agent !~ %r{Chrome}
      "safari"

    # Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.54
    # Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.114 Safari/537.36 Edg/91.0.864.59
    # Mozilla/5.0 (Windows NT 10.0; Win64; x64; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.19041
    # Mozilla/5.0 (Linux; Android 10; SM-A102U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.116 Mobile Safari/537.36 EdgA/46.04.2.5157
    elsif user_agent =~ %r{AppleWebKit/[^ ]+ \(KHTML, like Gecko\).*Edg[eA]?/[^ ]+\z}
      "edge"

    # Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.128 Safari/537.36 OPR/75.0.3969.285
    # Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.101 Safari/537.36 OPR/77.0.4054.90
    # Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.101 Safari/537.36 OPR/77.0.4054.90
    # Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.101 Safari/537.36 OPR/77.0.4054.90 (Edition Yx 05)
    # Mozilla/5.0 (Linux; Android 10; Mi A2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.6261.149 Mobile Safari/537.36 OPR/81.6.4292.79147
    elsif user_agent =~ %r{AppleWebKit/[^ ]+ \(KHTML, like Gecko\) Chrome/[^ ]+ (Mobile )?Safari/[^ ]+ OPR/[^ ]+}
      "opera"

    # Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko
    # Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko
    # Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; rv:11.0) like Gecko
    # Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko
    # Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Geck; GreenBrowser)
    # Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; Touch; rv:11.0) like Gecko
    elsif user_agent =~ %r{Trident/[^ ;)]+}
      "msie"

    # Mozilla/5.0 (Nintendo WiiU) AppleWebKit/536.30 (KHTML, like Gecko) NX/3.0.4.2.13 NintendoBrowser/4.3.2.11274.US
    # Mozilla/5.0 (PLAYSTATION 3 4.87) AppleWebKit/531.22.8 (KHTML, like Gecko)
    # Mozilla/5.0 (PlayStation Vita 3.73) AppleWebKit/537.73 (KHTML, like Gecko) Silk/3.2
    # Mozilla/5.0 (Linux; NetCast; U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.79 Safari/537.36 SmartTV/10.0 Colt/2.0
    # Mozilla/5.0 (Nintendo 3DS; U; ; en) Version/1.7639.EU
    # Mozilla/5.0 (Nintendo Switch; WifiWebAuthApplet) AppleWebKit/606.4 (KHTML, like Gecko) NF/6.0.1.16.11 NintendoBrowser/5.1.0.20935
    else
      "unknown-browser"
    end
  end

  # Returns true if the agent is a known bot (or a human pretending to be a bot), or false if the agent
  # is a known web browser (or a bot pretending to be a known browser).
  def is_bot?
    !name.in?(%w[chrome firefox safari opera edge msie unknown-browser])
  end
end