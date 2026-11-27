# frozen_string_literal: true

class Source::URL::Crepe < Source::URL
  site "Crepe", url: "https://crepe.cm", domains: %w[crepe.cm crepe.land kre.pe]

  extractors { [Source::Extractor::Crepe, Source::Extractor::URLShortener] }

  attr_reader :username, :commission_slug, :portfolio_slug, :redirect_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[crepe.cm crepe.land kre.pe])
  end

  def parse
    # Remove the locale from e.g. https://crepe.cm/ko/@yolrsona.
    segments = path_segments.first.to_s.match?(/\A[a-z]{2}\z/) ? path_segments.drop(1) : path_segments

    case [subdomain, domain, *segments]

    # https://i.crepe.land/https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png?h=640&q=100&t=i&v=3a&w=1280 (sample)
    in "i", "crepe.land", "https:", "crepe.land", *_rest
      @full_image_url = to_s[%r{\Ahttps://i\.crepe\.land/(https://crepe\.land/[^?#]+)}, 1]

    # https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png
    # https://crepe.land/portfolio/6/6h/6hwx89nokxxdag7n24ee1yfhndsu0nan_%EB%82%99%EC%84%AF%21.jpg
    # https://crepe.land/user_profile/c/cp/cpvwzgjo74j6h1v95thpti6rfq71ifg4_image.jpg
    in nil, "crepe.land", *_rest if image_url?
      @full_image_url = without(:query).to_s

    # https://kre.pe/E0f0 (redirects to https://crepe.cm/ko/@yolrsona/t71oz0uls)
    in nil, "kre.pe", redirect_id
      @redirect_id = redirect_id

    # https://crepe.cm/@yolrsona/portfolios/abc123
    # https://crepe.cm/@yolrsona/portfolios/abc123/edit
    in nil, "crepe.cm", /\A@([a-zA-Z0-9_]+)\z/, "portfolios", portfolio_slug, *rest if rest.in?([[], ["edit"]])
      @username = $1
      @portfolio_slug = portfolio_slug

    # https://crepe.cm/@yolrsona/portfolios
    in nil, "crepe.cm", /\A@([a-zA-Z0-9_]+)\z/, "portfolios"
      @username = $1

    # https://crepe.cm/@yolrsona/t71oz0uls
    # https://crepe.cm/@yolrsona/t71oz0uls/edit
    in nil, "crepe.cm", /\A@([a-zA-Z0-9_]+)\z/, commission_slug, *rest if rest.in?([[], ["edit"]])
      @username = $1
      @commission_slug = commission_slug

    # https://crepe.cm/@yolrsona
    in nil, "crepe.cm", /\A@([a-zA-Z0-9_]+)\z/
      @username = $1

    else
      nil
    end
  end

  def extractor_class
    redirect_id.present? ? Source::Extractor::URLShortener : Source::Extractor::Crepe
  end

  def image_sample?
    image_url? && subdomain == "i"
  end

  def page_url
    if username.present? && portfolio_slug.present?
      "https://crepe.cm/@#{username}/portfolios/#{portfolio_slug}"
    elsif username.present? && commission_slug.present?
      "https://crepe.cm/@#{username}/#{commission_slug}"
    end
  end

  def profile_url
    "https://crepe.cm/@#{username}" if username.present?
  end
end
