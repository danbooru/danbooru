class ArtistUrl < ApplicationRecord
  before_save :initialize_normalized_url, on: [ :create ]
  before_save :normalize
  validates_presence_of :url
  belongs_to :artist, :touch => true
  attr_accessible :url, :artist_id, :normalized_url

  def self.normalize(url)
    if url.nil?
      nil
    else
      url = url.gsub(/^https:\/\//, "http://")
      url = url.gsub(/^http:\/\/blog\d+\.fc2/, "http://blog.fc2")
      url = url.gsub(/^http:\/\/blog-imgs-\d+\.fc2/, "http://blog.fc2")
      url = url.gsub(/^http:\/\/blog-imgs-\d+-\w+\.fc2/, "http://blog.fc2")
      url = url.sub(%r!(http://seiga.nicovideo.jp/user/illust/\d+)\?.+!, '\1/')
      url = url.sub(%r!^http://pictures.hentai-foundry.com//!, "http://pictures.hentai-foundry.com/")
      begin
        url = Sources::Site.new(url).normalize_for_artist_finder!
      rescue PixivApiClient::Error
      end
      url = url.gsub(/\/+\Z/, "")
      url + "/"
    end
  end

  def self.legacy_normalize(url)
    if url.nil?
      nil
    else
      url = url.gsub(/^https:\/\//, "http://")
      url = url.gsub(/^http:\/\/blog\d+\.fc2/, "http://blog.fc2")
      url = url.gsub(/^http:\/\/blog-imgs-\d+\.fc2/, "http://blog.fc2")
      url = url.gsub(/^http:\/\/blog-imgs-\d+-\w+\.fc2/, "http://blog.fc2")
      url = url.gsub(/^http:\/\/img\d+\.pixiv\.net/, "http://img.pixiv.net")
      url = url.gsub(/^http:\/\/i\d+\.pixiv\.net\/img\d+/, "http://img.pixiv.net")
      url = url.gsub(/\/+\Z/, "")
      url + "/"
    end
  end

  def self.normalize_for_search(url)
    if url =~ /\.\w+\Z/ && url =~ /\w\/\w/
      url = File.dirname(url)
    end

    url = url.gsub(/^https:\/\//, "http://")
    url = url.gsub(/^http:\/\/blog\d+\.fc2/, "http://blog*.fc2")
    url = url.gsub(/^http:\/\/blog-imgs-\d+\.fc2/, "http://blog*.fc2")
    url = url.gsub(/^http:\/\/blog-imgs-\d+-\w+\.fc2/, "http://blog*.fc2")
    url = url.gsub(/^http:\/\/img\d+\.pixiv\.net/, "http://img*.pixiv.net")
    url = url.gsub(/^http:\/\/i\d+\.pixiv\.net\/img\d+/, "http://*.pixiv.net/img*")
  end

  def normalize
    if !Sources::Site.new(normalized_url).normalized_for_artist_finder?
      self.normalized_url = self.class.normalize(url)
    end
  end

  def initialize_normalized_url
    self.normalized_url = url
  end

  def to_s
    url
  end
end
