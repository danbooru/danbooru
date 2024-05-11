# frozen_string_literal: true

class Source::URL::Pinterest < Source::URL
  RESERVED_NAMES = %w[docs ideas pin resource shopping today videos _]

  attr_reader :pin_id, :username, :full_image_url, :candidate_full_image_urls

  def self.match?(url)
    url.domain == "pinimg.com" || url.sld == "pinterest" # matches pinterest.com, pinterest.jp, etc
  end

  def parse
    case [subdomain, sld, etld, *path_segments]

    # https://i.pinimg.com/originals/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.png
    in _, "pinimg", "com", "originals", *subdirs, file
      @full_image_url = to_s

    # https://i.pinimg.com/736x/a7/7c/67/a77c67f95a4fec64de7969e98f29cf3b.jpg
    in _, "pinimg", "com", sample_type, *subdirs, file
      @candidate_full_image_urls = %w[jpg png gif].map do |ext|
        "#{site}/originals/#{subdirs.join("/")}/#{filename}.#{ext}"
      end

    # https://www.pinterest.com/pin/551409548144250908/
    # https://www.pinterest.com/pin/AVBZICDCT7hRTla-jHiJ6w2eVUK1wuq7WRYG8P_uqZIziXisjxatHMA/
    # https://www.pinterest.com/pin/580612576989556785/sent/?invite_code=9e94baa7faae405d84a7787593fa46fd&sender=580612714368486682&sfo=1
    in _, "pinterest", _, "pin", pin_id, *rest
      @pin_id = pin_id

    # https://www.pinterest.com/uchihajake/
    # https://www.pinterest.com/uchihajake/hands/
    # https://jp.pinterest.com/uchihajake/
    in _, "pinterest", _, username, *rest unless username.in?(RESERVED_NAMES) || subdomain == "api"
      @username = username

    # https://www.pinterest.com/ideas/people/935950727927/
    # https://api.pinterest.com/url_shortener/4A1N0Rd5W/redirect/
    else
      nil
    end
  end

  def image_url?
    domain == "pinimg.com"
  end

  def page_url
    "https://www.pinterest.com/pin/#{pin_id}/" if pin_id.present?
  end

  def profile_url
    "https://www.pinterest.com/#{username}/" if username.present?
  end
end
