# frozen_string_literal: true

# @see Source::URL::Skland
class Source::Extractor::Skland < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    elsif article.dig(:item, :videoListSlice).present?
      article.dig(:item, :videoListSlice).to_a.map do |video|
        video_url = video[:resolutions]&.max_by { it[:size].to_i }&.dig(:playURL)
        Source::URL.parse(video_url).try(:full_image_url) || video_url
      end
    else
      article.dig(:item, :imageListSlice).to_a.pluck(:url).map do |url|
        Source::URL.parse(url).try(:full_image_url) || url
      end
    end
  end

  def username
    "skland_#{profile_id}" if profile_id.present?
  end

  def display_name
    article.dig(:user, :nickname)
  end

  def profile_id
    article.dig(:user, :id)
  end

  def profile_url
    if profile_id.present?
      "https://www.skland.com/profile?id=#{profile_id}"
    else
      parsed_url.profile_url || parsed_referer&.profile_url
    end
  end

  def tags
    article[:tags].to_a.map do |tag|
      [tag[:name], "https://www.skland.com/tag?id=#{tag[:id]}"]
    end
  end

  def artist_commentary_title
    article.dig(:item, :title)
  end

  def artist_commentary_desc
    return nil unless article.dig(:item, :format).present?

    { format: article.dig(:item, :format)&.parse_json, **article[:item]&.slice(:caption, :textSlice, :imageListSlice) }.to_json
  end

  def dtext_artist_commentary_desc
    DText.from_html(html_artist_commentary_desc, base_url: "https://www.skland.com")
  end

  def html_artist_commentary_desc
    format = article.dig(:item, :format)&.parse_json || {}

    format[:data].to_a.map do |item|
      case item[:type]
      # { "type": "paragraph", "contents": [{ "foregroundColor": "#222222", "type": "text", "contentId": "1", "bold": false, "underline": 0, "italic": false }] }
      in "paragraph"
        contents = item[:contents].to_a.map { |content| content_to_html(content) }.join
        "<p>#{contents}</p>" if contents.present?

      # {"type": "image", "width": 2408, "height": 1080, "size": 1001063, "imageId": "0"}
      in "image"
        "" # XXX ignored

      else
        ""
      end
    end.join
  end

  def content_to_html(content)
    case content[:type]
    # { "foregroundColor": "#222222", "type": "text", "contentId": "1", "bold": false, "underline": 0, "italic": false }
    in "text"
      id = content[:contentId]

      text = CGI.escapeHTML(text_slices[id].to_s)
      text = "<b>#{text}</b>" if content[:bold]
      text = "<i>#{text}</i>" if content[:italic]
      text = "<u>#{text}</u>" if content[:underline].to_i > 0
      text

    # { "type": "emoji", "id": "amiya-1__amiya_wuwu" }
    in "emoji"
      ":#{content[:id]}:"

    else
      ""
    end
  end

  memoize def text_slices
    # [{"id":"1","c":"絮雨买外敷#2243"},{"id":"2","c":"去年开的号，号上没几个好友"}]
    # => {"1":"絮雨买外敷#2243","2":"去年开的号，号上没几个好友"}
    article.dig(:item, :textSlice).to_h { |slice| [slice[:id], slice[:c]] }
  end

  def article_id
    parsed_url.article_id || parsed_referer&.article_id
  end

  memoize def article
    api_response[:data] || {}
  end

  memoize def api_response
    return {} unless article_id.present? && shumei_device_id.present?

    timestamp = Time.now.to_i.to_s
    headers = {
      platform: "3",
      timestamp: timestamp,
      dId: shumei_device_id,
      vName: "1.0.0",
    }

    token = http.headers(**headers).parsed_get("https://zonai.skland.com/web/v1/auth/refresh")&.dig(:data, :token)
    return {} unless token.present?

    api_url = Source::URL.parse("https://zonai.skland.com/web/v1/item?id=#{article_id}")
    str = "#{api_url.path}#{api_url.query}#{timestamp}#{headers.to_json}"
    hmac_sha256 = OpenSSL::HMAC.hexdigest("SHA256", token, str)
    headers[:sign] = Digest::MD5.hexdigest(hmac_sha256)

    http.headers(**headers).cache(1.minute).parsed_get(api_url.to_s) || {}
  end

  memoize def shumei_device_id
    Shumei.new(http).device_id
  end

  # Generates a Shumei device ID for the API. Works by generating and encrypting a fake device fingerprint.
  #
  # https://help.ishumei.com/docs/tw/sdk/guide/developDoc/
  # https://github.com/kafuneri/Skland-Sign-In/blob/main/skland_api.py
  # https://github.com/search?q=https://fp-it.portal101.cn/deviceprofile/v4&type=code
  class Shumei
    extend Memoist

    # https://github.com/search?q=UWXspnCCJN4sfYlNfqps&type=code
    ORGANIZATION = "UWXspnCCJN4sfYlNfqps"
    PUBLIC_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCmxMNr7n8ZeT0tE1R9j/mPixoinPkeM+k4VGIn/s0k7N5rJAfnZ0eMER+QhwFvshzo0LNmeUkpR8uIlU/GEVr8mN28sKmwd2gpygqj0ePnBmOW4v0ZVwbSYK+izkhVFk2V/doLoMbWy6b+UnA8mkjvg0iYWRByfRsK2gdl7llqCwIDAQAB"

    attr_reader :http, :uid

    def initialize(http)
      @http = http
      @uid = SecureRandom.uuid
    end

    memoize def device_id
      response = http.cache(1.minute).parsed_post("https://fp-it.portal101.cn/deviceprofile/v4", format: :json, json: {
        appId: "default",
        organization: ORGANIZATION,
        ep: ep,
        data: data,
        os: "web",
        encode: 5,
        compress: 2,
      },)

      raw_device_id = response&.dig(:detail, :deviceId)
      "B#{raw_device_id}" if raw_device_id.present?
    end

    private

    memoize def ep
      public_key = OpenSSL::PKey::RSA.new(Base64.decode64(PUBLIC_KEY))
      encrypted = public_key.public_encrypt(uid, OpenSSL::PKey::RSA::PKCS1_PADDING)
      Base64.strict_encode64(encrypted)
    end

    memoize def data
      # current_time = (Time.zone.now.to_f * 1000).to_i

      fingerprint = [
        { name: :protocol,     obfuscated_name: :protocol, des_key: nil,        value: 102 },
        # { name: :organization, obfuscated_name: :dp,       des_key: "78moqjfc", value: ORGANIZATION },
        # { name: :appId,        obfuscated_name: :xx,       des_key: "uy7mzc4h", value: "default" },
        { name: :os,           obfuscated_name: :pj,       des_key: "je6vk6t4", value: "web" },
        # { name: :version,      obfuscated_name: :version,  des_key: nil,        value: "3.0.0" },
        # { name: :sdkver,       obfuscated_name: :sc,       des_key: "9q3dcxp2", value: "3.0.0" },
        # { name: :box,          obfuscated_name: :jf,       des_key: nil,        value: "" },
        { name: :rtype,        obfuscated_name: :lo,       des_key: "x8o2h2bl", value: "all" },
        # { name: :smid,         obfuscated_name: :smid,     des_key: nil,        value: smid },
        # { name: :subVersion,   obfuscated_name: :ns,       des_key: "eo3i2puh", value: "1.0.0" },
        # { name: :time,         obfuscated_name: :nb,       des_key: "q2t3odsk", value: 0 },
        # { name: :plugins,      obfuscated_name: :kq,       des_key: "v51m3pzl", value: "MicrosoftEdgePDFPluginPortableDocumentFormatinternal-pdf-viewer1,MicrosoftEdgePDFViewermhjfbmdgcfjbbpaeojofohoefgiehjai1" },
        # { name: :ua,           obfuscated_name: :bj,       des_key: "k92crp1t", value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 Edg/129.0.0.0" },
        # { name: :canvas,       obfuscated_name: :yk,       des_key: "snrn887t", value: "259ffe69" },
        # { name: :timezone,     obfuscated_name: :as,       des_key: "1uv05lj5", value: -480 },
        # { name: :platform,     obfuscated_name: :gm,       des_key: "pakxhcd2", value: "Win32" },
        # { name: :url,          obfuscated_name: :cf,       des_key: "y95hjkoo", value: "https://www.skland.com/" },
        # { name: :referer,      obfuscated_name: :ab,       des_key: "y7bmrjlc", value: "" },
        # { name: :res,          obfuscated_name: :hf,       des_key: "whxqm2a7", value: "1920_1080_24_1.25" },
        # { name: :clientSize,   obfuscated_name: :zx,       des_key: "cpmjjgsu", value: "0_0_1080_1920_1920_1080_1920_1080" },
        # { name: :status,       obfuscated_name: :an,       des_key: "2jbrxxw4", value: "0011" },
        # { name: :vpw,          obfuscated_name: :ca,       des_key: "r9924ab5", value: SecureRandom.uuid },
        # { name: :svm,          obfuscated_name: :qr,       des_key: "fzj3kaeh", value: current_time },
        # { name: :trees,        obfuscated_name: :pi,       des_key: "acfs0xo4", value: SecureRandom.uuid },
        # { name: :pmf,          obfuscated_name: :vw,       des_key: "2mdeslu3", value: current_time },
      ]

      # { obfuscated_name => encrypted_value }
      fingerprint_hash = fingerprint.to_h do |rule|
        value = rule[:value]
        value = Base64.strict_encode64(des_encrypt(value.to_s, rule[:des_key])) if rule[:des_key].present?

        [rule[:obfuscated_name], value]
      end

      gzip_base64 = Base64.strict_encode64(gzip(fingerprint_hash.to_json))
      aes_encrypt(gzip_base64).unpack1("H*")
    end

    def gzip(data)
      io = StringIO.new
      gzip = Zlib::GzipWriter.new(io)
      gzip.write(data)
      gzip.close
      io.string
    end

    def des_encrypt(data, key)
      encrypt(data, algorithm: "des-ede3", key: key * 3, block_size: 8)
    end

    def aes_encrypt(data)
      key = Digest::MD5.hexdigest(uid)[0, 16]
      encrypt(data, algorithm: "aes-128-cbc", key: key, iv: "0102030405060708", block_size: 16)
    end

    def encrypt(string, algorithm:, key:, block_size:, iv: nil)
      pad_len = (block_size - (string.bytesize % block_size)) % block_size
      string += "\0" * pad_len

      cipher = OpenSSL::Cipher.new(algorithm)
      cipher.encrypt
      cipher.key = key
      cipher.iv = iv if iv.present?
      cipher.padding = 0

      cipher.update(string) + cipher.final
    end

    memoize def smid
      time_str = Time.zone.now.strftime("%Y%m%d%H%M%S")
      uid_md5 = Digest::MD5.hexdigest(uid)
      prefix = "#{time_str}#{uid_md5}00"
      suffix = Digest::MD5.hexdigest("smsk_web_#{prefix}")[0, 14]
      "#{prefix}#{suffix}0"
    end
  end
end
