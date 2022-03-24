# frozen_string_literal: true

class ArtistURL < ApplicationRecord
  normalize :url, :normalize_url

  validates :url, presence: true, uniqueness: { scope: :artist_id }
  validate :validate_url_format
  validate :validate_url_is_not_duplicate
  belongs_to :artist, :touch => true

  scope :url_matches, ->(url) { url_attribute_matches(:url, url) }
  scope :normalized_url_matches, ->(url) { url_attribute_matches(:normalized_url, url) }
  scope :active, -> { where(is_active: true) }

  def self.parse_prefix(url)
    prefix, url = url.match(/\A(-)?(.*)/)[1, 2]
    is_active = prefix.nil?

    [is_active, url]
  end

  def self.normalize_normalized_url(url)
    return nil if url.nil?

    url = Source::URL.parse(url)&.profile_url || url
    url = url.sub(%r{^https://}, "http://")
    url = url.gsub(%r{/+\Z}, "")
    url + "/"
  end

  def self.search(params = {})
    q = search_attributes(params, :id, :created_at, :updated_at, :url, :normalized_url, :is_active, :artist)

    q = q.url_matches(params[:url_matches])
    q = q.normalized_url_matches(params[:normalized_url_matches])

    case params[:order]
    when /\A(id|artist_id|url|normalized_url|is_active|created_at|updated_at)(?:_(asc|desc))?\z/i
      dir = $2 || :desc
      q = q.order($1 => dir).order(id: :desc)
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def self.url_attribute_matches(attr, url)
    if url.blank?
      all
    elsif url =~ %r{\A/(.*)/\z}
      where_regex(attr, $1)
    elsif url.include?("*")
      where_ilike(attr, url)
    else
      profile_url = Source::Extractor.find(url).profile_url || url
      where(attr => normalize_normalized_url(profile_url))
    end
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
    case url
    when %r{pixiv\.net/stacc}i
      true
    when %r{pixiv\.net/fanbox}i
      true
    when %r{twitter\.com/intent}i
      true
    when %r{lohas\.nicoseiga\.jp}i
      true
    when %r{(?:www|com|dic)\.nicovideo\.jp}i
      true
    when %r{pawoo\.net/web/accounts}i
      true
    when %r{www\.artstation\.com}i
      true
    when %r{blogimg\.jp}i, %r{image\.blog\.livedoor\.jp}i
      true
    else
      false
    end
  end

  # The sort order of sites in artist URL lists.
  def priority
    sites = %w[
      Pixiv Twitter
      ArtStation Baraag BCY Deviant\ Art Hentai\ Foundry Fantia Foundation Lofter Nico\ Seiga Nijie Pawoo Pixiv\ Fanbox Pixiv\ Sketch Plurk Tinami Tumblr Weibo
      Ask.fm Booth.pm Facebook FC2 Gumroad Instagram Ko-fi Livedoor Mihuashi Mixi.jp Patreon Piapro.jp Picarto Privatter Sakura.ne.jp Stickam Skeb Twitch Youtube
      Amazon Circle.ms DLSite Doujinshi.org Erogamescape Mangaupdates Melonbooks Toranoana Wikipedia
    ]

    sites.index(site_name) || 1000
  end

  def self.normalize_url(url)
    Source::URL.parse(url)&.profile_url || Danbooru::URL.parse(url)&.to_normalized_s || url
  end

  def url=(url)
    super(url)
    @parsed_url = Source::URL.parse(url)
    self.normalized_url = self.class.normalize_normalized_url(self.url)
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

  def validate_scheme(uri)
    errors.add(:url, "'#{uri}' must begin with http:// or https:// ") unless uri.scheme.in?(%w[http https])
  end

  def validate_hostname(uri)
    errors.add(:url, "'#{uri}' has a hostname '#{uri.host}' that does not contain a dot") unless uri.host&.include?(".")
  end

  def validate_url_format
    uri = Addressable::URI.parse(url)
    validate_scheme(uri)
    validate_hostname(uri)
  rescue Addressable::URI::InvalidURIError => e
    errors.add(:url, "'#{uri}' is malformed: #{e}")
  end

  def validate_url_is_not_duplicate
    artists = ArtistFinder.find_artists(url).without(artist)

    artists.each do |a|
      warnings.add(:base, "Duplicate of [[#{a.name}]]")
    end
  end

  def self.available_includes
    [:artist]
  end
end
