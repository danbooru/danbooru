class SavedSearch < ApplicationRecord
  REDIS_EXPIRY = 1.hour
  QUERY_LIMIT = 1000

  concerning :Redis do
    extend Memoist

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
          else
            PopulateSavedSearchJob.perform_later(query)
          end
        end
        post_ids.to_a.sort.last(QUERY_LIMIT)
      end
    end

    def refreshed_at
      ttl = SavedSearch.redis.ttl("search:#{normalized_query}")
      return nil if ttl < 0
      (REDIS_EXPIRY.to_i - ttl).seconds.ago
    end
    memoize :refreshed_at

    def cached_size
      SavedSearch.redis.scard("search:#{normalized_query}")
    end
    memoize :cached_size
  end

  concerning :Labels do
    class_methods do
      def normalize_label(label)
        label
          .to_s
          .strip
          .downcase
          .gsub(/[[:space:]]/, "_")
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
        SavedSearch
          .where(user_id: user_id)
          .order("label")
          .pluck(Arel.sql("distinct unnest(labels) as label"))
      end
    end

    def normalize_labels
      self.labels = labels.map {|x| SavedSearch.normalize_label(x)}.reject(&:blank?)
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
      def search(params)
        q = super
        q = q.search_attributes(params, :query)

        if params[:label]
          q = q.labeled(params[:label])
        end

        case params[:order]
        when "query"
          q = q.order(:query).order(id: :desc)
        when "label"
          q = q.order(:labels).order(id: :desc)
        else
          q = q.apply_default_order(params)
        end

        q
      end

      def populate(query, timeout: 10_000)
        CurrentUser.as_system do
          redis_key = "search:#{query}"
          return if redis.exists(redis_key)

          post_ids = Post.with_timeout(timeout, [], query: query) do
            Post.tag_match(query).limit(QUERY_LIMIT).pluck(:id)
          end

          if post_ids.present?
            redis.sadd(redis_key, post_ids)
            redis.expire(redis_key, REDIS_EXPIRY.to_i)
          end
        end
      end
    end
  end

  concerning :Queries do
    class_methods do
      def queries_for(user_id, label: nil, options: {})
        SavedSearch
          .where(user_id: user_id)
          .labeled(label)
          .pluck(:query)
          .map {|x| Tag.normalize_query(x, sort: true)}
          .sort
          .uniq
      end
    end

    def normalized_query
      Tag.normalize_query(query, sort: true)
    end

    def normalize_query
      self.query = Tag.normalize_query(query, sort: false)
    end
  end

  attr_reader :disable_labels
  belongs_to :user
  validates :query, presence: true
  validate :validate_count
  before_validation :normalize_query
  before_validation :normalize_labels
  scope :labeled, ->(label) { label.present? ? where("labels @> string_to_array(?, '~~~~')", label) : where("true") }

  def validate_count
    if user.saved_searches.count + 1 > user.max_saved_searches
      self.errors[:user] << "can only have up to #{user.max_saved_searches} " + "saved search".pluralize(user.max_saved_searches)
    end
  end

  def disable_labels=(value)
    CurrentUser.update(disable_categorized_saved_searches: true) if value.to_s.truthy?
  end

  def self.available_includes
    [:user]
  end
end
