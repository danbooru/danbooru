class SavedSearch < ApplicationRecord
  REDIS_EXPIRY = 3600
  QUERY_LIMIT = 1000

  def self.enabled?
    Danbooru.config.redis_url.present?
  end

  concerning :Redis do
    class_methods do
      extend Memoist

      def redis
        ::Redis.new(url: Danbooru.config.redis_url)
      end
      memoize :redis

      def post_ids_for(user_id, label: nil)
        label = normalize_label(label) if label
        queries = queries_for(user_id, label: label)
        post_ids = Set.new
        queries.each do |query|
          redis_key = "search:#{query}"
          if redis.exists(redis_key)
            sub_ids = redis.smembers(redis_key).map(&:to_i)
            post_ids.merge(sub_ids)
            redis.expire(redis_key, REDIS_EXPIRY)
          else
            SavedSearch.delay(queue: "default").populate(query)
          end
        end
        post_ids.to_a.sort.last(QUERY_LIMIT)
      end
    end
  end

  concerning :Labels do
    class_methods do
      def normalize_label(label)
        label.
          to_s.
          strip.
          downcase.
          gsub(/[[:space:]]/, "_")
      end

      def search_labels(user_id, params)
        labels = labels_for(user_id)

        if params[:label].present?
          query = Regexp.escape(params[:label]).gsub("\\*", ".*")
          query = ".*#{query}.*" unless query.include?("*")
          query = /\A#{query}\z/
          labels = labels.grep(query)
        end

        labels
      end

      def labels_for(user_id)
        SavedSearch.
          where(user_id: user_id).
          order("label").
          pluck(Arel.sql("distinct unnest(labels) as label"))
      end
    end

    def normalize_labels
      self.labels = labels.
        map {|x| SavedSearch.normalize_label(x)}.
        reject {|x| x.blank?}
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
  end

  concerning :Search do
    class_methods do
      def populate(query)
        CurrentUser.as_system do
          redis_key = "search:#{query}"
          return if redis.exists(redis_key)
          post_ids = Post.tag_match(query, true).limit(QUERY_LIMIT).pluck(:id)
          redis.sadd(redis_key, post_ids)
          redis.expire(redis_key, REDIS_EXPIRY)
        end
      rescue Exception
        # swallow
      end
    end
  end

  concerning :Queries do
    class_methods do
      def queries_for(user_id, label: nil, options: {})
        SavedSearch.
          where(user_id: user_id).
          labeled(label).
          pluck(:query).
          map {|x| Tag.normalize_query(x, sort: true)}.
          sort.
          uniq
      end
    end

    def normalized_query
      Tag.normalize_query(query, sort: true)
    end

    def normalize_query
      self.query = Tag.normalize_query(query, sort: false)
    end
  end

  attr_accessor :disable_labels
  belongs_to :user
  validates :query, presence: true
  validate :validate_count
  before_create :update_user_on_create
  after_destroy :update_user_on_destroy
  before_validation :normalize_query
  before_validation :normalize_labels
  scope :labeled, ->(label) { label.present? ? where("labels @> string_to_array(?, '~~~~')", label) : where("true") }

  def validate_count
    if user.saved_searches.count + 1 > user.max_saved_searches
      self.errors[:user] << "can only have up to #{user.max_saved_searches} " + "saved search".pluralize(user.max_saved_searches)
    end
  end

  def update_user_on_create
    if !user.has_saved_searches?
      user.update(has_saved_searches: true)
    end
  end

  def update_user_on_destroy
    if user.saved_searches.count == 0
      user.update(has_saved_searches: false)
    end
  end

  def disable_labels=(value)
    CurrentUser.update(disable_categorized_saved_searches: true) if value.to_s.truthy?
  end
end
