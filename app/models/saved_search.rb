class SavedSearch < ApplicationRecord
  module ListbooruMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def enabled?
        Danbooru.config.aws_sqs_saved_search_url.present?
      end

      def posts_search_available?
        enabled? && CurrentUser.is_gold?
      end

      def sqs_service
        SqsService.new(Danbooru.config.aws_sqs_saved_search_url)
      end

      def post_ids(user_id, label = nil)
        return [] unless enabled?
        label = normalize_label(label) if label

        Cache.get("ss-#{user_id}-#{Cache.hash(label)}", 60) do
          queries = SavedSearch.queries_for(user_id, label)
          return [] if queries.empty?

          json = {
            "key" => Danbooru.config.listbooru_auth_key,
            "queries" => queries
          }.to_json

          uri = "#{Danbooru.config.listbooru_server}/v2/search"

          resp = HTTParty.post(uri, Danbooru.config.httparty_options.merge(body: json))
          if resp.success?
            resp.body.to_s.scan(/\d+/).map(&:to_i)
          else
            raise "HTTP error code: #{resp.code} #{resp.message}"
          end
        end
      end
    end
  end

  include ListbooruMethods

  attr_accessor :disable_labels
  belongs_to :user
  validates :query, :presence => true
  validate :validate_count
  before_create :update_user_on_create
  after_destroy :update_user_on_destroy
  after_save {|rec| Cache.delete(SavedSearch.cache_key(rec.user_id))}
  after_destroy {|rec| Cache.delete(SavedSearch.cache_key(rec.user_id))}
  before_validation :normalize
  scope :labeled, lambda {|label| where("labels @> string_to_array(?, '~~~~')", label)}

  def self.normalize_label(label)
    label.to_s.strip.downcase.gsub(/[[:space:]]/, "_")
  end

  def self.search_labels(user_id, params)
    labels = labels_for(user_id)

    if params[:label].present?
      query = Regexp.escape(params[:label]).gsub("\\*", ".*")
      query = ".*#{query}.*" unless query.include?("*")
      query = /\A#{query}\z/
      labels = labels.grep(query)
    end

    labels
  end

  def self.labels_for(user_id)
    Cache.get(cache_key(user_id)) do
      SavedSearch.where(user_id: user_id).order("label").pluck("distinct unnest(labels) as label")
    end
  end

  def self.cache_key(user_id)
    "ss-labels-#{user_id}"
  end

  def self.queries_for(user_id, label = nil, options = {})
    if label
      SavedSearch.where(user_id: user_id).labeled(label).map(&:normalized_query).sort.uniq
    else
      SavedSearch.where(user_id: user_id).map(&:normalized_query).sort.uniq
    end
  end

  def normalized_query
    Tag.normalize_query(query, sort: true)
  end

  def normalize
    self.query = Tag.normalize_query(query, sort: false)
    self.labels = labels.map {|x| SavedSearch.normalize_label(x)}.reject {|x| x.blank?}
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

  def label_string
    labels.join(" ")
  end

  def label_string=(val)
    self.labels = val.to_s.split(/[[:space:]]+/)
  end

  def labels=(labels)
    labels = labels.map { |label| SavedSearch.normalize_label(label) }
    super(labels)
  end

  def disable_labels=(value)
    CurrentUser.update(disable_categorized_saved_searches: true) if value == "1"
  end
end
