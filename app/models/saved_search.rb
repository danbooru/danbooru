class SavedSearch < ActiveRecord::Base
  module ListbooruMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def posts_search_available?
        Danbooru.config.listbooru_server.present? && CurrentUser.is_gold?
      end

      def refresh_listbooru(user_id)
        return false unless Danbooru.config.listbooru_enabled?

        sqs = SqsService.new(Danbooru.config.aws_sqs_queue_url)
        sqs.send_message("refresh\n#{user_id}")
      end

      def reset_listbooru(user_id)
        return false unless Danbooru.config.listbooru_enabled?

        sqs = SqsService.new(Danbooru.config.aws_sqs_queue_url)
        user = User.find(user_id)

        sqs.send_message("delete\n#{user_id}\nall\n")

        user.saved_searches.each do |saved_search|
          sqs.send_message("create\n#{user_id}\n#{saved_search.category}\n#{saved_search.tag_query}", :delay_seconds => 30)
        end

        true
      end
    end

    def update_listbooru_on_create
      return unless Danbooru.config.listbooru_enabled?
      return unless user.is_gold?

      sqs = SqsService.new(Danbooru.config.aws_sqs_queue_url)
      sqs.send_message("create\n#{user_id}\n#{category}\n#{tag_query}")
    end

    def update_listbooru_on_destroy
      return unless Danbooru.config.listbooru_enabled?

      sqs = SqsService.new(Danbooru.config.aws_sqs_queue_url)
      sqs.send_message("delete\n#{user_id}\n#{category}\n#{tag_query}")
    end

    def update_listbooru_on_update
      return unless Danbooru.config.listbooru_enabled?
      return unless user.is_gold?

      sqs = SqsService.new(Danbooru.config.aws_sqs_queue_url)
      sqs.send_message("update\n#{user_id}\n#{category_was}\n#{tag_query_was}\n#{category}\n#{tag_query}")
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
    return [] unless Danbooru.config.listbooru_enabled?

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
