# frozen_string_literal: true

class ArtistURL < ApplicationRecord
  normalizes :url, with: ->(url) { ArtistURL.normalize_url(url) }

  validates :url, presence: true, length: { maximum: 300, message: "'%{value}' is too long (maximum is 300 characters)" }, uniqueness: { scope: :artist_id }
  validate :validate_url_format
  belongs_to :artist, :touch => true

  scope :active, -> { where(is_active: true) }

  def self.parse_prefix(url)
    prefix, url = url.match(/\A(-)?(.*)/)[1, 2]
    is_active = prefix.nil?

    [is_active, url]
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :url, :is_active, :artist], current_user: current_user)
    q = q.urls_match(params[:url_matches])

    case params[:order]
    when /\A(id|artist_id|url|is_active|created_at|updated_at)(?:_(asc|desc))?\z/i
      dir = $2 || :desc
      q = q.order($1 => dir).order(id: :desc)
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def self.urls_match(urls)
    urls = Array.wrap(urls).flat_map(&:split)
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
    else
      where_ilike(:url, "*#{url.escape_wildcards}*")
    end
  end

  def self.normalized_url_like(url)
    url = url.downcase.gsub(%r{\Ahttps?://|/\z}i, "") # "https://example.com/A/B/C/" => "example.com/a/b/c"
    url = url + "/" unless url.include?("*")
    where_like("regexp_replace(lower(artist_urls.url), '^https?://|/$', '', 'g') || '/'", url) # this is indexed
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
    case url
    when %r{pixiv\.net/stacc}i
      true
    when %r{pixiv\.net/fanbox}i
      true
    when %r{twitter\.com/intent}i
      true
    when %r{(?:www|com|dic)\.nicovideo\.jp}i
      true
    when %r{pawoo\.net/web/accounts}i
      true
    when %r{misskey\.(?:io|art|design)/users}i
      true
    when %r{inkbunny\.net/user\.php}i
      true
    when %r{bsky\.app/profile/did:}i
      true
    when %r{lofter\.com/mentionredirect.do}i
      true
    when %r{mihuashi\.com/users/}i
      true
    else
      false
    end
  end

  # The sort order of sites in artist URL lists.
  def priority
    sites = %w[
      Pixiv Twitter
      Anifty ArtStation Baraag Bilibili BCY Booth Deviant\ Art Fantia Foundation Furaffinity Hentai\ Foundry Huashijie Lofter Newgrounds Nico\ Seiga Nijie Pawoo Fanbox Pixiv\ Sketch Plurk Reddit Arca.live DC\ Inside Skeb Tinami Tumblr Weibo Misskey.io Misskey.art Misskey.design Xfolio
      Ask.fm Facebook FC2 Gumroad Huajia Instagram Ko-fi Livedoor Mihuashi Mixi.jp Patreon Piapro.jp Picarto Privatter Sakura.ne.jp Stickam Twitch Youtube
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

  # @return [Array<Artist>] The list of other artists that also contain this URL.
  def duplicate_artists
    ArtistFinder.find_artists(url).without(artist)
  end

  def validate_url_format
    uri = Addressable::URI.parse(url)
    Source::URL.parse!(url)

    if !uri.host&.include?(".")
      errors.add(:url, "'#{url}' is not a valid URL")
    end
  rescue StandardError
    errors.add(:url, "'#{url}' is not a valid URL")
  end

  def self.available_includes
    [:artist]
  end
end
