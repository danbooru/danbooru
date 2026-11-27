# frozen_string_literal: true

class ArtistURL < ApplicationRecord
  MAX_URL_LENGTH = 300

  normalizes :url, with: ->(url) { ArtistURL.normalize_url(url) }

  validates :url, presence: true, length: { maximum: MAX_URL_LENGTH, message: "'%{value}' is too long (maximum is #{MAX_URL_LENGTH} characters)" }, uniqueness: { scope: :artist_id }
  validate :validate_url_format, if: :url_changed?
  belongs_to :artist, touch: true

  scope :active, -> { where(is_active: true) }

  def self.parse_prefix(url)
    prefix, url = url.match(/\A(-)?(.*)/)[1, 2]
    is_active = prefix.nil?

    [is_active, url]
  end

  def self.search(params, current_user)
    q = search_attributes(params, current_user: current_user)
    q = q.urls_match(parse_search_params!(params, url_matches: [:string])[:url_matches])

    case params[:order]
    when /\A(id|artist_id|url|is_active|created_at|updated_at)(?:_(asc|desc))?\z/
      dir = $2 || :desc
      q = q.order($1 => dir).order(id: :desc)
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def self.urls_match(urls)
    urls = Array.wrap(urls).flat_map(&:split).take(10) # limit to prevent DoS with huge searches
    return all if urls.empty?

    urls.map do |url|
      url_matches(url)
    end.reduce(&:or)
  end

  def self.url_matches(url)
    if url.blank?
      all
    elsif url =~ %r{\A/(.*)/\z}
      where_regex(:url, $1)
    elsif url.include?("*")
      where_ilike(:url, url)
    elsif url =~ %r{\Ahttps?://}i
      profile_url = Source::URL.profile_url(url) || Source::Extractor.find(url).profile_url || normalize_url(url)
      normalized_url_like(profile_url)
    elsif (profile_url = Source::URL.profile_url("https://#{url}")) # "twitter.com/foo" => "https://x.com/foo"
      normalized_url_like(profile_url)
    else
      where_ilike(:url, "*#{url.escape_wildcards}*")
    end
  end

  def self.normalized_url_like(url)
    url = url.downcase.gsub(%r{\Ahttps?://|/\z}i, "") # "https://example.com/A/B/C/" => "example.com/a/b/c"
    url += "/" unless url.include?("*")
    where_like(Arel.sql("regexp_replace(lower(artist_urls.url), '^https?://|/$', '', 'g') || '/'"), url) # this is indexed
  end

  def self.normalized_url_equals_any(urls)
    urls = urls.map { |url| url.to_s.downcase.gsub(%r{\Ahttps?://|/\z}i, "") + "/" } # "https://example.com/A/B/C" => "example.com/a/b/c/"
    where(["regexp_replace(lower(artist_urls.url), '^https?://|/$', '', 'g') || '/' IN (:urls)", { urls: }]) # this is indexed
  end

  def domain
    parsed_url&.domain.to_s
  end

  def site_name
    parsed_url&.site_name.to_s
  end

  # A secondary URL is an artist URL that we don't normally want to display,
  # usually because it's redundant with the primary profile URL.
  def secondary_url?
    parsed_url&.secondary_url?
  end

  # The sort order of sites in artist URL lists.
  def sorting_priority
    parsed_url&.sorting_priority || 1000
  end

  def self.normalize_url(url)
    Source::URL.parse(url)&.profile_url || Danbooru::URL.parse(url)&.to_normalized_s || url
  end

  def url=(url)
    super
    @parsed_url = Source::URL.parse(url)
  end

  def parsed_url
    @parsed_url ||= Source::URL.parse(url)
  end

  def to_s
    if is_active?
      url
    else
      "-#{url}"
    end
  end

  def validate_url_format
    if Source::URL.parse!(url).host.exclude?(".")
      errors.add(:url, "'#{url}' is not a valid URL")
    end
  rescue StandardError
    errors.add(:url, "'#{url}' is not a valid URL")
  end

  def self.available_includes
    [:artist]
  end
end
