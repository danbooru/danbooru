class SavedSearch < ActiveRecord::Base
  module ListbooruMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def refresh_listbooru(user_id)
        return unless Danbooru.config.listbooru_auth_key
        user = User.find(user_id)
        return unless user.is_gold?
        
        params = {
          :user_id => user_id,
          :key => Danbooru.config.listbooru_auth_key
        }
        uri = URI.parse("#{Danbooru.config.listbooru_server}/users")
        uri.query = URI.encode_www_form(params)
        Net::HTTP.get_response(uri)
      end

      def reset_listbooru(user_id)
        return unless Danbooru.config.listbooru_auth_key

        uri = URI.parse("#{Danbooru.config.listbooru_server}/searches")
        Net::HTTP.start(uri.host, uri.port) do |http|
          req = Net::HTTP::Delete.new("/searches")
          req.set_form_data("user_id" => user_id, "all" => "true", "key" => Danbooru.config.listbooru_auth_key)
          http.request(req)
        end

        user = User.find(user_id)
        user.saved_searches.each do |saved_search|
          update_listbooru_on_create(user_id, saved_search.category, saved_search.tag_query)
        end
      end

      def update_listbooru_on_create(user_id, name, query)
        return unless Danbooru.config.listbooru_auth_key
        uri = URI.parse("#{Danbooru.config.listbooru_server}/searches")
        Net::HTTP.post_form(uri, {"user_id" => user_id, "name" => name.try(:downcase), "query" => query, "key" => Danbooru.config.listbooru_auth_key})
      end

      def update_listbooru_on_destroy(user_id, name, query)
        return unless Danbooru.config.listbooru_auth_key
        uri = URI.parse("#{Danbooru.config.listbooru_server}/searches")
        Net::HTTP.start(uri.host, uri.port) do |http|
          req = Net::HTTP::Delete.new("/searches")
          req.set_form_data("user_id" => user_id, "name" => name.try(:downcase), "query" => query, "key" => Danbooru.config.listbooru_auth_key)
          http.request(req)
        end
      end

      def update_listbooru_on_update(user_id, old_name, old_query, new_name, new_query)
        return unless Danbooru.config.listbooru_auth_key
        uri = URI.parse("#{Danbooru.config.listbooru_server}/searches")
        Net::HTTP.start(uri.host, uri.port) do |http|
          req = Net::HTTP::Put.new("/searches")
          req.set_form_data(
            "user_id" => user_id, 
            "old_name" => old_name.try(:downcase),
            "old_query" => old_query,
            "new_name" => new_name.try(:downcase), 
            "new_query" => new_query, 
            "key" => Danbooru.config.listbooru_auth_key
          )
          http.request(req)
        end
      end
    end

    def update_listbooru_on_create
      return unless Danbooru.config.listbooru_auth_key
      SavedSearch.delay(:queue => "default").update_listbooru_on_create(user_id, category, tag_query)
    end

    def update_listbooru_on_destroy
      return unless Danbooru.config.listbooru_auth_key
      SavedSearch.delay(:queue => "default").update_listbooru_on_destroy(user_id, category, tag_query)
    end

    def update_listbooru_on_update
      return unless Danbooru.config.listbooru_auth_key
      SavedSearch.delay(:queue => "default").update_listbooru_on_update(user_id, category_was, tag_query_was, category, tag_query)
    end
  end

  include ListbooruMethods

  belongs_to :user
  validates :tag_query, :presence => true
  validate :validate_count
  attr_accessible :tag_query, :category
  before_create :update_user_on_create
  before_update :update_listbooru_on_update
  after_destroy :update_user_on_destroy
  after_create :update_listbooru_on_create
  after_destroy :update_listbooru_on_destroy
  validates_uniqueness_of :tag_query, :scope => :user_id
  before_validation :normalize

  def self.tagged(tags)
    where(:tag_query => SavedSearch.normalize(tags)).first
  end

  def self.normalize(tag_query)
    Tag.scan_query(tag_query).join(" ")
  end

  def self.post_ids(user_id, name = nil)
    params = {
      "key" => Danbooru.config.listbooru_auth_key,
      "user_id" => user_id,
      "name" => name
    }
    uri = URI.parse("#{Danbooru.config.listbooru_server}/users")
    uri.query = URI.encode_www_form(params)

    Net::HTTP.start(uri.host, uri.port) do |http|
      resp = http.request_get(uri.request_uri)
      if resp.is_a?(Net::HTTPSuccess)
        resp.body.scan(/\d+/).map(&:to_i)
      else
        raise "HTTP error code: #{resp.code} #{resp.message}"
      end
    end
  end

  def normalize
    self.category = category.strip.gsub(/\s+/, "_").downcase if category
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
end
