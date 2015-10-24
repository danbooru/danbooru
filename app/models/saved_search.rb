class SavedSearch < ActiveRecord::Base
  belongs_to :user
  validates :tag_query, :presence => true
  validate :validate_count
  attr_accessible :tag_query, :category
  before_create :update_user_on_create
  after_destroy :update_user_on_destroy
  before_create :update_listbooru_on_create
  after_destroy :update_listbooru_on_destroy
  validates_uniqueness_of :tag_query, :scope => :user_id
  before_validation :normalize

  def self.tagged(tags)
    where(:tag_query => SavedSearch.normalize(tags)).first
  end

  def self.normalize(tag_query)
    Tag.scan_query(tag_query).join(" ")
  end

  def normalize
    self.tag_query = SavedSearch.normalize(tag_query)
  end

  def validate_count
    if user.saved_searches.count + 1 > user.max_saved_searches
      self.errors[:user] << "can only have up to #{user.max_saved_searches} " + "saved search".pluralize(user.max_saved_searches)
    end
  end

  def update_user_on_create
    if !user.has_saved_searches?
      user.update_attribute(:has_saved_searches, true)
    end
  end

  def update_user_on_destroy
    if user.saved_searches.count == 0
      user.update_attribute(:has_saved_searches, false)
    end
  end

  def update_listbooru_on_create
    return unless Danbooru.config.listbooru_auth_key
    Net::HTTP.post_form(Danbooru.config.listbooru_server, {"user_id" => user_id, "query" => tag_query, "key" => Danbooru.config.listbooru_auth_key, "name" => "saved"})
  end

  def update_listbooru_on_destroy
    return unless Danbooru.config.listbooru_auth_key
    uri = URI.parse(Danbooru.config.listbooru_server)
    Net::HTTP.start(uri.host, uri.port) do |http|
      req = Net::HTTP::Delete.new("/searches")
      req.set_form_data("user_id" => user_id, "query" => tag_query, "key" => Danbooru.config.listbooru_auth_key, "name" => "saved")
      http.request(req)
    end
  end
end
