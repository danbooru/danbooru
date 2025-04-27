# frozen_string_literal: true

# Generates the X-Client-Transaction-Id header for Twitter API requests.
#
# A transaction ID must be generated for each API call to Twitter. The same transaction ID can't be used for the same
# call more than once, but it can be reused for different calls with different parameters. An invalid transaction ID
# will result in a 404 error.
#
# The transaction ID is based on the following factors:
#
# * The API endpoint (path and method). Each transaction ID is only valid for a single endpoint.
# * The value of the `<meta name="twitter-site-verification">` element, obtained by scraping the Twitter home page. This
#   value changes on every page load, but it can be cached.
# * The Twitter logo, obtained by scraping the `svg#loading-x-anim-*` elements from the home page. The algorithm
#   mainly works by performing some CSS transformations on the logo, which we have to emulate.
# * Some magic indices obtained from the latest `https://abs.twimg.com/responsive-web/client-web/ondemand.s.#{id}a.js`
#   file. Changes every few days/weeks. The ID of the file is obtained by scraping the home page.
# * The current time (doesn't have to be very recent).
# * A random byte, chosen by us (used to xor-encode the transaction ID).
#
# @see https://github.com/iSarabjitDhiman/XClientTransaction
# @see https://github.com/fa0311/twitter-tid-deobf-fork
# @see https://github.com/fa0311/antibot_blog_archives
# @see https://fa0311.github.io/antibot_blog_archives/web/twitter-header-part-1.html
# @see https://fa0311.github.io/antibot_blog_archives/web/twitter-header-part-2.html
# @see https://fa0311.github.io/antibot_blog_archives/web/twitter-header-part-3.html
class TwitterTransactionIdGenerator
  extend Memoist

  attr_reader :time, :xor_key, :http

  # @param time [Integer] The current time (in seconds since the epoch).
  # @param twitter_site_verification_key [String] The value of the `<meta name="twitter-site-verification">` element.
  # @param xor_key [Integer] A random integer from 0-255 used to XOR encrypt the transaction ID.
  # @param http [Danbooru::Http] The HTTP client to use for scraping the Twitter home page.
  def initialize(twitter_site_verification_key: nil, time: Time.zone.now, xor_key: rand(255), http: Danbooru::Http.external)
    @twitter_site_verification_key = twitter_site_verification_key
    @time = time.to_i
    @xor_key = xor_key
    @http = http
  end

  # Parse a transaction ID and return a new generator based on the same input params.
  #
  # @param tid [String] The transaction ID.
  # @return [TwitterTransactionIdGenerator] The transaction ID generator.
  def self.from(tid)
    xor_key, *rest = Base64.decode64(tid).unpack("C*")
    decoded_bytes = rest.map { |byte| byte ^ xor_key }

    key_bytes = decoded_bytes[0..47].pack("c*")
    key = Base64.strict_encode64(key_bytes)

    time_delta = decoded_bytes[48..51].pack("c*").unpack1("L")
    time = (time_delta * 1000 + 1682924400 * 1000) / 1000

    new(twitter_site_verification_key: key, time: time, xor_key: xor_key)
  end

  # Given a transaction ID, validate that parsing it and generating a new ID based on the same input params returns the same result.
  def self.validate(tid, path)
    from(tid).transaction_id(path) == tid
  end

  # Generate a transaction ID for the given API endpoint.
  #
  # @param path [String] The URL path of the API endpoint.
  # @param method [String] The HTTP method for the API endpoint.
  # @return [String] The transaction ID.
  def transaction_id(path, method: "GET")
    time_delta = ((time.to_f * 1000 - 1682924400 * 1000) / 1000).floor
    time_delta_bytes = (0..3).map { |i| (time_delta >> (i * 8) & 0xFF) }

    # An easter egg from Twitter; "obfio" is the guy who originally reversed engineered this (see https://github.com/obfio, https://antibot.blog).
    keyword = "obfiowerehiring"
    hash = Digest::SHA256.digest("#{method}!#{path}!#{time_delta}#{keyword}#{animation_key}")

    bytes = [*key_bytes, *time_delta_bytes, *hash.bytes[0..15], 3]
    xor_bytes = [xor_key] + bytes.map { |byte| byte ^ xor_key }

    Base64.strict_encode64(xor_bytes.pack("c*")).strip.gsub(/=/, "")
  end

  # Below are internal methods used to calculate the transaction ID.

  # @return [Nokogiri::HTML5::DocumentFragment] The Twitter homepage (used to extract the verification key, Twitter logo, and ondemand.s.js file).
  memoize def homepage
    headers = {
      "Authority": "x.com",
      "Accept-Language": "en-US,en;q=0.9",
      "Cache-Control": "no-cache",
      "Referer": "https://x.com",
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
      "X-Twitter-Active-User": "yes",
      "X-Twitter-Client-Language": "en"
    }

    http.cache(1.minute).headers(headers).parsed_get("https://x.com")
  end

  # @return [String] The Javascript file for the transaction ID generator (used to extract some magic values).
  memoize def on_demand_js
    id = homepage&.at('script[text()*="__SCRIPTS_LOADED__"]')&.text&.slice(/"ondemand\.s":"(\h*)"/, 1)
    url = "https://abs.twimg.com/responsive-web/client-web/ondemand.s.#{id}a.js"
    http.cache(1.minute).get(url)&.to_s
  end

  # @return [Array<Integer>] Four magic numbers extracted from the ondemand.s.js file.
  memoize def indices
    # ... (n[38],16) ... (n[22],16) ... (n[8],16) ... (n[14],16)) ...
    on_demand_js&.scan(/\(\w\[(\d{1,2})\],16\)/)&.flatten.to_a.map(&:to_i)
  end

  # @return [String] The value of the <meta name="twitter-site-verification"> element.
  def twitter_site_verification_key
    @twitter_site_verification_key ||= homepage&.at("meta[name='twitter-site-verification']")&.attr("content")
  end

  # @return [Array<Integer>] The decoded bytes of the site verification key.
  memoize def key_bytes
    Base64.decode64(twitter_site_verification_key).bytes if twitter_site_verification_key.present?
  end

  # @return [Array<Array<Integer>>] A 11x16 2D array of integers taken from the coordinates of one of the frames of the
  #   X logo (chosen by a byte from the verification key).
  memoize def frame_data
    logo_frames = homepage&.css("svg[id^='loading-x-anim']").to_a
    logo_frame = logo_frames[key_bytes[5] % logo_frames.size] # The 6th byte of the verification key determines which of the four frames to use.

    # Convert the SVG coordinates to a matrix of integers.
    logo_frame&.at("path:nth-child(2)")&.attr("d")&.slice(/C .*/)&.split(/C/).to_a.compact_blank.map { |item| item.scan(/\d+/).map(&:to_i) }
  end

  # @return [Array<Integer>] A row taken from one of the frames of the X logo (chosen by a byte from the verification
  #   key, itself chosen by an index extracted from the ondemand.s.js file).
  memoize def frame_row
    frame_data[key_bytes[indices[0]] % frame_data.size]
  end

  # @return [Array<Float>] An array of four floats, based on the frame row.
  memoize def curves
    frame_row[7..].map.with_index do |item, i|
      min = i % 2 == 1 ? -1.0 : 0.0
      scale(item.to_f, min, 1.0).round(2)
    end
  end

  def scale(value, min, max)
    value * (max - min) / 255 + min
  end

  # @return [Float] A percentage from 0.0-1.0, determining how long to run the animation, based on a product of bytes
  #   from the verification key.
  memoize def frame_time
    target_time = indices[1..].map { |i| key_bytes[i] % 16 }.reduce(:*)
    target_time = (target_time / 10.0).round * 10
    target_time / 4096.0
  end

  # @return [Float] A cubic-bezier interpolation of 3 bytes taken from the verification key.
  memoize def cubic
    if frame_time <= 0.0
      if curves[0] > 0.0
        start_gradient = curves[1] / curves[0]
      elsif curves[1] == 0.0 && curves[2] > 0.0
        start_gradient = curves[3] / curves[2]
      end

      return start_gradient * frame_time
    elsif frame_time >= 1.0
      if curves[2] < 1.0
        end_gradient = (curves[3] - 1.0) / (curves[2] - 1.0)
      elsif curves[2] == 1.0 && self.curves[0] < 1.0
        end_gradient = (curves[1] - 1.0) / (curves[0] - 1.0)
      end

      return 1.0 + end_gradient * (frame_time - 1.0)
    end

    start = mid = 0.0
    finish = 1.0

    while start < finish
      mid = (start + finish) / 2
      x_est = calculate(curves[0], curves[2], mid)

      if (frame_time - x_est).abs < 0.00001
        return calculate(curves[1], curves[3], mid)
      elsif x_est < frame_time
        start = mid
      else
        finish = mid
      end
    end

    calculate(curves[1], curves[3], mid)
  end

  def calculate(a, b, m)
    3.0 * a * (1 - m) * (1 - m) * m + 3.0 * b * (1 - m) * m * m + m * m * m
  end

  # @return [Array<Float>] An array of four floats (a RGBA color), based on a color transformation of the Twitter logo.
  def color
    from_color = frame_row[0..2].map(&:to_f) + [1.0]
    to_color = frame_row[3..5].map(&:to_f) + [1.0]
    interpolate(from_color, to_color, cubic).map { |c| c.clamp(0..255.0) }
  end

  # @return [Float] An angle (in degrees), based on a rotation of the Twitter logo.
  def rotation
    from_rotation = [0.0]
    to_rotation = [scale(frame_row[6].to_f, 60.0, 360.0).floor]
    interpolate(from_rotation, to_rotation, cubic)
  end

  def interpolate(from_list, to_list, f)
    from_list.zip(to_list).map do |from, to|
      from * (1 - f) + to * f
    end
  end

  # @return [Array<Float>] The logo rotation expressed as a matrix.
  def matrix
    angle = rotation[0]
    rad = (angle / 180.0) * Math::PI
    [Math.cos(rad), -Math.sin(rad), Math.sin(rad), Math.cos(rad)]
  end

  # @return [String] The color and rotation transformations, concatenated together into a string.
  def animation_key
    array = color[..-2].map { |c| c.round.to_s(16) }
    array += matrix.map { |num| float_to_hex(num.round(2).abs) }

    [*array, "0", "0"].join.tr(".-", "")
  end

  # Convert a float to a hex string; equivalent to `f.toString(16)` in Javascript.
  def float_to_hex(f, precision: 15)
    int_part = f.to_i
    frac_part = f - int_part
    return int_part.to_s(16) if frac_part.zero?

    result = int_part.to_s(16) + "."
    precision.times do
      frac_part *= 16
      digit = frac_part.to_i
      result += digit.to_s(16)
      frac_part -= digit
      break if frac_part.zero?
    end

    result
  end
end
