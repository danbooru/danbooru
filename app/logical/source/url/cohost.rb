# frozen_string_literal: true

# @see Source::Extractor::Cohost
class Source::URL::Cohost < Source::URL
  RESERVED_USERNAMES = %w[rc static]

  attr_reader :full_image_url, :username, :post_id, :title, :slug

  def self.match?(url)
    url.domain.in?(%w[cohost.org cohostcdn.org])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png?width=675&auto=webp&dpr=1 (sample)
    # https://staging.cohostcdn.org/attachment/e70670fc-591b-4f66-b4e9-75938adaa1dd/245_evil_nigiri.png (full)
    # https://staging.cohostcdn.org/attachment/33425ef7-defe-4626-bfdc-6100ad984cd3/TSP%20Animation%20Final.gif (full)
    # https://staging.cohostcdn.org/header/42892-7cd2e652-82fd-464d-b544-4bdd4bea429a-profile.jpeg (profile banner)
    # https://staging.cohostcdn.org/avatar/42892-471e51cc-d0d5-4e86-a52c-eec635fc4a2c-profile.gif?dpr=2&width=80&height=80&fit=cover&auto=webp (profile picture)
    in "staging", "cohostcdn.org", *rest
      @full_image_url = without(:query).to_s

    # https://cohost.org/Karuu/post/2605252-nigiri-evil
    in _, "cohost.org", username, "post", /^(\d+)-(.*)$/ => slug
      @username = username
      @post_id = $1
      @title = $2
      @slug = slug

    # https://cohost.org/Karuu
    # https://cohost.org/Karuu/ask
    in _, "cohost.org", username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://proxy-staging.cohostcdn.org/oUaGFFLq7deDxHHN1stDGZJh7KXDw9y_J0cCYAn1psI/f:png/czM6Ly9jb2hvc3QtcHJvZC9hdHRhY2htZW50LzMzNDI1ZWY3LWRlZmUtNDYyNi1iZmRjLTYxMDBhZDk4NGNkMy9UU1AgQW5pbWF0aW9uIEZpbmFsLmdpZg?width=675&auto=webp&dpr=1 (static animation thumbnail)
    # https://cohost.org/rc/default-avatar/246987.png?dpr=2&width=80&height=80&fit=cover&auto=webp (profile picture)
    else
      nil
    end
  end

  def page_url
    "https://cohost.org/#{username}/post/#{slug}" if username.present? && slug.present?
  end

  def profile_url
    "https://cohost.org/#{username}" if username.present?
  end
end
