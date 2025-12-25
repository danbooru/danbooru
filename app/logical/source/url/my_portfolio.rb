# frozen_string_literal: true

# MyPortfolio is Adobe's portfolio site builder. It supports both subdomains like https://sekigahara023.myportfolio.com
# and custom domains like https://artgerm.com.
#
# For custom domains we detect that the site is using MyPortfolio in Source::Extractor::Null and instantiate
# Source::URL::MyPortfolio directly. In this case we bypass the `match?` method and we have to be careful to handle
# custom domains in `parse`, `page_url`, and `profile_url`.
#
# @see https://portfolio.adobe.com
# @see Source::Extractor::MyPortfolio
class Source::URL::MyPortfolio < Source::URL
  RESERVED_USERNAMES = %w[cdn www]

  attr_reader :username, :artist_uuid, :image_uuid, :image_size, :page_title

  def self.match?(url)
    url.domain == "myportfolio.com"
  end

  def site_name
    "Adobe Portfolio"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://pro2-bar-s3-cdn-cf6.myportfolio.com/59753a162c5d8748646b051378da184f/77f237b4-25e9-46ed-b8ef-2b3709c92491_rw_1200.jpg?h=24a897ae2c7f7ffdaf8ab60b3bd3f8fb (sample)
    # https://pro2-bar-s3-cdn-cf6.myportfolio.com/59753a162c5d8748646b051378da184f/77f237b4-25e9-46ed-b8ef-2b3709c92491.jpg?h=021034439a138a0920b78342343cb37e (full)
    # https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/bb0394ab-0ffd-414b-9748-2a8a751c645a_rw_1200.png?h=fdde829a19fbd8534d6f85d3914f419c (sample)
    # https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/bb0394ab-0ffd-414b-9748-2a8a751c645a.png?h=8e01300d76ec46eb482ed647ec4b78ee (full)
    # https://cdn.myportfolio.com/86bfb012-1d8f-427f-bbbb-287c3b8c0057/2a0c99c7-d94d-4812-87b4-1690d7a13983_car_202x158.png?h=e698f363e29b0f60d61181c64016a99a (thumbnail)
    # https://pro2-bar-s3-cdn-cf6.myportfolio.com/ea94248a8ad87a031cf807d40eb5ac83/af57cb30368b3d3b3576fe81.jpg?h=d656289b0092beab1297ad678ef12647
    in _, "myportfolio.com", artist_uuid, /\A(\h+)(?:_.+_(.+))?/
      @artist_uuid = artist_uuid
      @image_uuid = $1
      @image_size = $2

    # https://sekigahara023.myportfolio.com/eaapexlegends5
    # https://sekigahara023.myportfolio.com/about
    # https://shiori-shii.myportfolio.com/portfolio
    # https://shiori-shii.myportfolio.com/work-1
    in username, "myportfolio.com", /^[a-z0-9-]+$/ => page_title unless username.in?(RESERVED_USERNAMES) || image_url?
      @username = username
      @page_title = page_title

    # https://sekigahara023.myportfolio.com/
    in username, "myportfolio.com" unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://artgerm.com/copy-of-dc-comics-a
    in _, _, /^[a-z0-9-]+$/ => page_title unless image_url?
      @page_title = page_title

    else
      nil
    end
  end

  def page_url
    # https://shiori-shii.myportfolio.com/portfolio
    # https://artgerm.com/copy-of-dc-comics-a
    "#{profile_url}/#{page_title}" if profile_url.present? && page_title.present?
  end

  def profile_url
    # https://sekigahara023.myportfolio.com
    # https://artgerm.com
    site unless image_url?
  end
end
