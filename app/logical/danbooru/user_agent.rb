# frozen_string_literal: true

module Danbooru
  class UserAgent
    extend Memoist

    attr_reader :raw_user_agent, :user_agent

    delegate :to_s, :platform, :version, :os, :mobile?, to: :user_agent

    # @param string [String] The user agent string.
    def initialize(string)
      @raw_user_agent = string.to_s
      @user_agent = ::UserAgent.parse(raw_user_agent)
    end

    # @return [String, nil] The name of the bot or browser, e.g. "Chrome", "Googlebot", "curl", etc.
    memoize def product
      if raw_user_agent.blank?
        nil
      elsif bot_name.present?
        bot_name
      else
        browser
      end
    end

    # @return [String, nil] The name of the browser, e.g. "Chrome", "Firefox", "Safari", "Edge", etc.
    memoize def browser
      products.each do |product|
        # Mozilla/5.0 (Linux; Android 10; SM-A102U) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.116 Mobile Safari/537.36 EdgA/46.04.2.5157
        # Mozilla/5.0 (Windows NT 10.0; Win64; x64; Xbox; Xbox One) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.19041
        return "Edge" if product.start_with?("Edg")

        # SAMSUNG-SM-B313E Opera/9.80 (J2ME/MIDP; Opera Mini/4.5.40318/191.283; U; en) Presto/2.12.423 Version/12.16
        # Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 OPR/102.0.0.0 GLS/97.10.5999.100")assert_product_equals("Opera", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36 OPR/102.0.0.0 GLS/97.10.5999.100
        return "Opera" if product.in?(%w[Opera OPR])

        # Mozilla/5.0 (Nintendo WiiU) AppleWebKit/536.30 (KHTML, like Gecko) NX/3.0.4.2.13 NintendoBrowser/4.3.2.11274.US
        return "NintendoBrowser" if product == "NintendoBrowser"
      end

      user_agent.browser
    end

    # @return [Array<String, String)>] The name and version of the bot, if the user agent is a bot (e.g. "Googlebot/2.1" "curl/7.61.1", etc.)
    memoize def bot
      # "SAMSUNG-SM-B313E Opera/9.80 (J2ME/MIDP; Opera Mini/4.5.40318/191.283; U; en) Presto/2.12.423 Version/12.16"
      # "Mozilla/5.0 (Linux aarch64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.112 Safari/537.36 OPR/36.0.2128.0 OMI/4.8.0.129.Driver6.32 , _TV_MT5806/092.003.166.031 (Philips, PUG6654, wired)  CE-HTML/1.0 NETTV/4.6.0.2 SignOn/2.0 SmartTvA/5.0.0 WH1.0 en Opera/68.0.3618.31"
      # "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"
      # "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)"
      if raw_user_agent.match("Opera|Trident|MSIE")
        []

      # "com.apple.Safari.SearchHelper/16611.2.7.1.4 CFNetwork/1240.0.4 Darwin/20.5.0" => "com.apple.Safari.SearchHelper"
      # "Tiny Tiny RSS/21.06-7bd9572aa (http://tt-rss.org/)" => "Tiny Tiny RSS"
      # "Python/3.9 aiohttp/3.6.3" => "aiohttp"
      # "CUMZONATORBOT/1.0 kotb" => "CUMZONATORBOT"
      # "http.rb/3.2.0 (Mastodon/2.4.4; +https://queer.af/)" => "http.rb" # XXX should be Mastodon
      elsif !raw_user_agent.match?(%r{\AMozilla/[45]\.0})
        index = unknown_segments.find_index { |segment| segment.version.to_s.present? } || unknown_segments.size
        segments = unknown_segments[0..index]
        name = segments.map(&:product).join(" ")
        version = segments.last.version.to_s

        [name, version]

      # "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.90 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" => "Googlebot"
      # "Mozilla/5.0 (compatible; Hydrus Client)" => "Hydrus Client"
      elsif (segment = user_agent.find { |ua| ua.comment&.first == "compatible" })
        comment = segment.comment[1..]

        # Mozilla/5.0 (Linux; Android 7.0;) AppleWebKit/537.36 (KHTML, like Gecko) Mobile Safari/537.36 (compatible; PetalBot;+https://webmaster.petalsearch.com/site/petalbot)
        if comment.first&.include?("PetalBot")
          ["PetalBot", nil]
        # ["Googlebot/2.1", "+http://www.google.com/bot.html"]
        elsif comment.first&.match?(%r{[^/;]+/[^ ]+})
          comment.first&.split("/")
        # ["Hydrus Client"]
        else
          [comment.first, nil]
        end

      # "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:52.0) Gecko/20100101 Firefox/52.0 Grabber/7.5.1" => "Grabber"
      elsif unknown_segments.present?
        name = unknown_segments.first&.product
        version = unknown_segments.first&.version.to_s

        [name, version]

      # "Mozilla/5.0"
      else
        []
      end
    end

    # @return [String, nil] The bot name, e.g. "Googlebot", "curl", etc.
    def bot_name
      bot.first
    end

    # @return [String, nil] The bot version, e.g. "2.1", "7.61.1", etc.
    def bot_version
      bot.second
    end

    # @return [String, nil] The Android device manufacturer and model name, e.g. "SAMSUNG SM-G781B"
    def device
      return unless os.include?("Android")

      # Mozilla/5.0 (Linux; Android 13; SAMSUNG SM-G781B) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/23.0 Chrome/115.0.0.0 Mobile Safari/537.36
      device = user_agent.first&.comment&.third

      # Mozilla/5.0 (Linux; Android 14; LE2115 Build/UKQ1.230924.001) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.7103.125 Mobile Safari/537.36 OPT/2.9
      device.gsub!(%r{ Build/.*}, "")

      # Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Mobile Safari/537.36
      # Mozilla/5.0 (Linux; U; Android 11; en_GB; M2101K7AG; Build/RKQ1.201022.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 onlymash.flexbooru.play/2.7.5.c1180 Mobile Safari/537.36
      # Mozilla/5.0 (Android 11; Mobile; rv:89.0) Gecko/89.0 Firefox/89.0
      device unless device.match?(/\A(K|rv:\d+\.\d+|Android \d+)\z/)
    end

    # @return [Array<String>] The list of product names in the user agent, e.g. ["Mozilla", "AppleWebKit", "Chrome", "Safari"]
    memoize def products
      user_agent.map(&:product)
    end

    # @return [Array<::UserAgent>] The list of unrecognized segments in the user agent string, e.g. ["Grabber/7.5.1", "onlymash.flexbooru.play/2.7.5.c1180"]
    memoize def unknown_segments
      user_agent.reject do |segment|
        segment.product.in?(%w[
          AppleWebKit Chrome CFNetwork CriOS Darwin Edg Edge EdgA Firefox Gecko GLS Mobile Mozilla NintendoBrowser NF NX
          Python Opera OPR Safari Version
        ])
      end
    end

    # @return [String, nil] The major product version, e.g. "137"
    def major_version
      version.to_a&.first&.to_s
    end

    # @return [String, nil] The product name and major version, e.g. "Chrome 137", "Googlebot 2.1"
    def product_version
      "#{product} #{major_version}" if product.present? && major_version.present?
    end

    # @return [String, nil] The product name and full version, e.g. "Chrome/137.0.0.0", "Googlebot/2.1"
    def full_product_version
      "#{product}/#{version}" if product.present? && version.present?
    end
  end
end
