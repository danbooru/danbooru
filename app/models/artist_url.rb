class ArtistUrl < ActiveRecord::Base
  before_save :normalize
  validates_presence_of :url
  belongs_to :artist
  
  def self.normalize(url)
    if url.nil?
      nil
    else
      url.gsub!(/^http:\/\/blog\d+\.fc2/, "http://blog.fc2")
      url.gsub!(/^http:\/\/blog-imgs-\d+\.fc2/, "http://blog.fc2")
      url.gsub!(/^http:\/\/blog-imgs-\d+-\w+\.fc2/, "http://blog.fc2")
      url.gsub!(/^http:\/\/img\d+\.pixiv\.net/, "http://img.pixiv.net")
      url.gsub!(/\/+$/, "")
      url + "/"
    end
  end
  
  def self.normalize_for_search(url)
    if url =~ /\.\w+$/ && url =~ /\w\/\w/
      url = File.dirname(url)
    end
    
    url = url.gsub(/^http:\/\/blog\d+\.fc2/, "http://blog*.fc2")
    url = url.gsub(/^http:\/\/blog-imgs-\d+\.fc2/, "http://blog*.fc2")
    url = url.gsub(/^http:\/\/blog-imgs-\d+-\w+\.fc2/, "http://blog*.fc2")
    url = url.gsub(/^http:\/\/img\d+\.pixiv\.net/, "http://img*.pixiv.net")    
  end

  def normalize
    self.normalized_url = self.class.normalize(url)
  end
  
  def to_s
    url
  end
end
