class SavedSearch < ApplicationRecord
  REDIS_EXPIRY = 1.hour
  QUERY_LIMIT = 1000

  attr_reader :disable_labels
  belongs_to :user

  before_validation :normalize_query
  before_validation :normalize_labels
  validates :query, presence: true
  validate :validate_count, on: :create

  scope :labeled, ->(label) { where_array_includes_any_lower(:labels, [normalize_label(label)]) }
  scope :has_tag, ->(name) { where_regex(:query, "(^| )[~-]?#{Regexp.escape(name)}( |$)", flags: "i") }

  concerning :Redis do
    extend Memoist

    class_methods do
      extend Memoist

      def redis
        ::Redis.new(url: Danbooru.config.redis_url)
      end
      memoize :redis

      def post_ids_for(user_id, label: nil)
        queries = queries_for(user_id, label: label)
        post_ids = Set.new
        queries.each do |query|
          redis_key = "search:#{query}"
          if redis.exists?(redis_key)
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
        redis_key = "search:#{query}"
        return if redis.exists?(redis_key)

        post_ids = Post.with_timeout(timeout, [], query: query) do
          Post.system_tag_match(query).limit(QUERY_LIMIT).pluck(:id)
        end

        if post_ids.present?
          redis.sadd(redis_key, post_ids)
          redis.expire(redis_key, REDIS_EXPIRY.to_i)
        end
      end
    end
  end

  concerning :Queries do
    class_methods do
      def queries_for(user_id, label: nil, options: {})
        searches = SavedSearch.where(user_id: user_id)
        searches = searches.labeled(label) if label.present?
        queries = searches.map(&:normalized_query)
        queries.sort.uniq
      end

      def rewrite_queries!(old_name, new_name)
        has_tag(old_name).find_each do |ss|
          ss.lock!
          ss.rewrite_query(old_name, new_name)
          ss.save!
        end
      end
    end

    def normalized_query
      PostQueryBuilder.new(query).normalized_query.to_s
    end

    def normalize_query
      self.query = PostQueryBuilder.new(query).normalized_query(sort: false).to_s
    end

    def rewrite_query(old_name, new_name)
      self.query.gsub!(/(?:\A| )([-~])?#{Regexp.escape(old_name)}(?: |\z)/i) { " #{$1}#{new_name} " }
      self.query.strip!
    end
  end

  def validate_count
    if user.saved_searches.count >= user.max_saved_searches
      self.errors[:user] << "can only have up to #{user.max_saved_searches} " + "saved search".pluralize(user.max_saved_searches)
    end
  end

  def disable_labels=(value)
    user.update(disable_categorized_saved_searches: true) if value.to_s.truthy?
  end

  def self.available_includes
    [:user]
  end
end
