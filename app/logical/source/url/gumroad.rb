# frozen_string_literal: true

class Source::URL::Gumroad < Source::URL
  RESERVED_USERNAMES = %w[www public-files assets static-2 app discover features pricing university blog login signup terms privacy]

  attr_reader :username, :product_id, :post_id, :image_id, :short_id

  def self.match?(url)
    url.domain.in?(%w[gumroad.com gum.co])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://public-files.gumroad.com/zc2289rdv8fx905pgaikh40fsle2 (page: https://aiki.gumroad.com/l/HelmV2T3)
    in "public-files", "gumroad.com", image_id
      @image_id = image_id

    # https://public-files.gumroad.com/variants/nsqiekm8gnl5nfrw3mtthminn2ig/e82ce07851bf15f5ab0ebde47958bb042197dbcdcae02aa122ef3f5b41e97c02
    in "public-files", "gumroad.com", "variants", image_id, _
      @image_id = image_id

    # https://aiki.gumroad.com/l/HelmV2T3?layout=profile
    # https://gumroad.com/l/HelmV2T3?layout=profile
    # https://www.gumroad.com/l/HelmV2T3?layout=profile
    # https://app.gumroad.com/l/HelmV2T3?layout=profile
    in username, "gumroad.com", "l", product_id
      @username = username unless username.in?(RESERVED_USERNAMES)
      @product_id = product_id

    # https://movw2000.gumroad.com/p/new-product-b072093e-e628-4a92-9740-e9b4564d9901
    in username, "gumroad.com", "p", post_id
      @username = username unless username.in?(RESERVED_USERNAMES)
      @post_id = post_id

    #	https://gumroad.com/aiki
    #	https://www.gumroad.com/aiki
    #	https://app.gumroad.com/aiki
    in _, "gumroad.com", username unless username.in?(RESERVED_USERNAMES)
      @username = username

    #	https://aiki.gumroad.com
    in username, "gumroad.com" unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://gum.co/dkvcip (page: https://aiki.gumroad.com/l/HelmT2)
    in _, "gum.co", short_id
      @short_id = short_id

    else
      nil
    end
  end

  def image_url?
    image_id.present?
  end

  def full_image_url
    "https://public-files.gumroad.com/#{image_id}" if image_id.present?
  end

  def page_url
    if username.present? && product_id.present?
      "https://#{username}.gumroad.com/l/#{product_id}"
    elsif product_id.present?
      "https://www.gumroad.com/l/#{product_id}"
    elsif username.present? && post_id.present?
      "https://#{username}.gumroad.com/p/#{post_id}"
    end
  end

  def profile_url
    "https://#{username}.gumroad.com" if username.present?
  end
end
