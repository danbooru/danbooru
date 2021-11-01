class ArtistUrl < ApplicationRecord
  before_validation :initialize_normalized_url, on: :create
  before_validation :normalize
  validates :url, presence: true, uniqueness: { scope: :artist_id }
  validate :validate_url_format
  belongs_to :artist, :touch => true

  scope :url_matches, ->(url) { url_attribute_matches(:url, url) }
  scope :normalized_url_matches, ->(url) { url_attribute_matches(:normalized_url, url) }
  scope :active, -> { where(is_active: true) }

  def self.parse_prefix(url)
    prefix, url = url.match(/\A(-)?(.*)/)[1, 2]
    is_active = prefix.nil?

    [is_active, url]
  end

  def self.normalize(url)
    if url.nil?
      nil
    else
      url = url.sub(%r{^https://}, "http://")
      url = url.sub(%r{^http://blog-imgs-\d+\.fc2}, "http://blog.fc2")
      url = url.sub(%r{^http://blog-imgs-\d+-\w+\.fc2}, "http://blog.fc2")
      url = url.sub(%r{^http://blog\d*\.fc2\.com/(?:\w/){,3}(\w+)}, "http://\\1.blog.fc2.com")
      url = url.sub(%r{^http://pictures.hentai-foundry.com//}, "http://pictures.hentai-foundry.com/")

      # the strategy won't always work for twitter because it looks for a status
      url = url.downcase if url =~ %r{^https?://(?:mobile\.)?twitter\.com}

      url = Sources::Strategies.find(url).normalize_for_artist_finder

      # XXX the Pixiv strategy should implement normalize_for_artist_finder and return the correct url directly.
      url = url.sub(%r{\Ahttps?://www\.pixiv\.net/(?:en/)?users/(\d+)\z}i, 'https://www.pixiv.net/member.php?id=\1')

      url = url.gsub(%r{/+\Z}, "")
      url = url.gsub(%r{^https://}, "http://")
      url + "/"
    end
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
      where(attr => normalize(url))
    end
  end

  def domain
    uri = Addressable::URI.parse(normalized_url)
    uri.domain
  end

  def site_name
    source = Sources::Strategies.find(normalized_url)
    source.site_name
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
      ArtStation BCY Deviant\ Art Hentai\ Foundry Foundation Nico\ Seiga Nijie pawoo.net Pixiv\ Fanbox Pixiv\ Sketch Tinami Tumblr
      Ask.fm Booth.pm Facebook Fantia FC2 Gumroad Instagram Ko-fi Livedoor Lofter Mihuashi Mixi.jp Patreon Piapro.jp Picarto Privatter Sakura.ne.jp Stickam Skeb Twitch Weibo Youtube
      Amazon Circle.ms DLSite Doujinshi.org Erogamescape Mangaupdates Melonbooks Toranoana Wikipedia
    ]

    sites.index(site_name) || 1000
  end

  def normalize
    # Perform some normalization with Addressable on the URL itself
    # - Converts scheme and hostname to downcase
    # - Converts unicode hostname to Punycode
    uri = Addressable::URI.parse(url)
    uri.site = uri.normalized_site
    self.url = uri.to_s
    self.normalized_url = self.class.normalize(url)
  rescue Addressable::URI::InvalidURIError
    # Don't bother normalizing the URL if there is errors
  end

  def initialize_normalized_url
    self.normalized_url = url
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

  def self.available_includes
    [:artist]
  end
end
