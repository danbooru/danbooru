class ArtistUrl < ApplicationRecord
  before_validation :initialize_normalized_url, on: :create
  before_validation :normalize
  validates :url, presence: true, uniqueness: { scope: :artist_id }
  validate :validate_url_format
  belongs_to :artist, :touch => true

  scope :url_matches, ->(url) { url_attribute_matches(:url, url) }
  scope :normalized_url_matches, ->(url) { url_attribute_matches(:normalized_url, url) }

  def self.parse_prefix(url)
    prefix, url = url.match(/\A(-)?(.*)/)[1, 2]
    is_active = prefix.nil?

    [is_active, url]
  end

  def self.normalize(url)
    if url.nil?
      nil
    else
      url = url.sub(%r!^https://!, "http://")
      url = url.sub(%r!^http://([^/]+)!i) { |domain| domain.downcase }
      url = url.sub(%r!^http://blog\d+\.fc2!, "http://blog.fc2")
      url = url.sub(%r!^http://blog-imgs-\d+\.fc2!, "http://blog.fc2")
      url = url.sub(%r!^http://blog-imgs-\d+-\w+\.fc2!, "http://blog.fc2")
      # url = url.sub(%r!^(http://seiga.nicovideo.jp/user/illust/\d+)\?.+!, '\1/')
      url = url.sub(%r!^http://pictures.hentai-foundry.com//!, "http://pictures.hentai-foundry.com/")

      # XXX should be handled by pixiv strategy.
      url = url.sub(%r!\Ahttps?://www\.pixiv\.net/(?:en/)?users/(\d+)\z!i, 'https://www.pixiv.net/member.php?id=\1')

      # the strategy won't always work for twitter because it looks for a status
      url = url.downcase if url =~ %r!^https?://(?:mobile\.)?twitter\.com!

      begin
        source = Sources::Strategies.find(url)

        if !source.normalized_for_artist_finder? && source.normalizable_for_artist_finder?
          url = source.normalize_for_artist_finder
        end
      rescue Net::OpenTimeout, PixivApiClient::Error
        raise if Rails.env.test?
      end

      url = url.gsub(/\/+\Z/, "")
      url = url.gsub(%r!^https://!, "http://")
      url + "/"
    end
  end

  def self.search(params = {})
    q = super

    q = q.search_attributes(params, :url, :normalized_url, :artist_id, :is_active)

    q = q.artist_matches(params[:artist])
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

  def self.artist_matches(params = {})
    return all if params.blank?
    where(artist_id: Artist.search(params).reorder(nil))
  end

  def self.url_attribute_matches(attr, url)
    if url.blank?
      all
    elsif url =~ %r!\A/(.*)/\z!
      where_regex(attr, $1)
    elsif url.include?("*")
      where_ilike(attr, url)
    else
      where(attr => normalize(url))
    end
  end

  def priority
    if normalized_url =~ /pixiv\.net\/member\.php/
      10

    elsif normalized_url =~ /seiga\.nicovideo\.jp\/user\/illust/
      10

    elsif normalized_url =~ /twitter\.com/ && normalized_url !~ /status/
      15

    elsif normalized_url =~ /tumblr|patreon|deviantart|artstation/
      20

    else
      100
    end
  end

  def normalize
    self.normalized_url = self.class.normalize(url)
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

  def validate_url_format
    uri = Addressable::URI.parse(url)
    errors[:url] << "'#{uri}' must begin with http:// or https:// " if !uri.scheme.in?(%w[http https])
  rescue Addressable::URI::InvalidURIError => error
    errors[:url] << "'#{uri}' is malformed: #{error}"
  end

  def self.available_includes
    [:artist]
  end
end
