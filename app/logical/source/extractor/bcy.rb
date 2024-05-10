# frozen_string_literal: true

# @see Source::URL::Bcy
class Source::Extractor::Bcy < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      []
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end
end
