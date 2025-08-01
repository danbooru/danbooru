# frozen_string_literal: true

class SavedSearch < ApplicationRecord
  REDIS_EXPIRY = 1.hour
  QUERY_LIMIT = 1000
  MAX_TAGS = 150

  attr_reader :disable_labels

  belongs_to :user

  normalizes :query, with: ->(query) { SavedSearch.normalize_query(query) }
  normalizes :labels, with: ->(labels) { SavedSearch.normalize_labels(labels) }

  validates :query, visible_string: true, length: { maximum: 3000 }, if: :query_changed?
  validates :labels, length: { maximum: 20, too_long: "can't have more than 20 labels" }, if: :labels_changed?
  validate :validate_query, if: :query_changed?
  validate :validate_labels, if: :labels_changed?
  validate :validate_count, on: :create

  scope :labeled, ->(label) { where_array_includes_any_lower(:labels, [normalize_label(label)]) }
  scope :has_tag, ->(name) { where_regex(:query, "(^| )[~-]?#{Regexp.escape(name)}( |$)", flags: "i") }

  def self.visible(user)
    if user.is_anonymous?
      none
    else
      where(user: user)
    end
  end

  concerning :Redis do
    extend Memoist

    class_methods do
      extend Memoist

      def redis
        return nil if Danbooru.config.redis_url.blank?
        ::Redis.new(url: Danbooru.config.redis_url)
      end
      memoize :redis

      def post_ids_for(user_id, label: nil)
        return [] if redis.nil?

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
      return Time.zone.now if SavedSearch.redis.nil?

      ttl = SavedSearch.redis.ttl("search:#{normalized_query}")
      return nil if ttl < 0
      (REDIS_EXPIRY.to_i - ttl).seconds.ago
    end
    memoize :refreshed_at

    def cached_size
      return 0 if SavedSearch.redis.nil?

      SavedSearch.redis.scard("search:#{normalized_query}")
    end
    memoize :cached_size
  end

  concerning :Labels do
    class_methods do
      def normalize_labels(labels)
        # XXX should sort and uniq, but will break some use cases.
        labels.map { |label| normalize_label(label) }.reject(&:blank?)
      end

      def normalize_label(label)
        label.to_s.unicode_normalize(:nfc).normalize_whitespace.downcase.gsub(/[[:space:]]+/, "_").squeeze("_").gsub(/\A_|_\z/, "")
      end

      def all_labels
        select(Arel.sql("distinct unnest(labels) as label")).order(:label)
      end

      def labels_like(label)
        all_labels.select { |ss| ss.label.ilike?(label) }.map(&:label)
      end

      def labels_for(user_id)
        SavedSearch
          .where(user_id: user_id)
          .order(label: :asc)
          .pluck(Arel.sql("distinct unnest(labels) as label"))
      end
    end

    def label_string
      labels.join(" ")
    end

    def label_string=(val)
      self.labels = val.to_s.split(/[[:space:]]+/)
    end
  end

  concerning :Search do
    class_methods do
      def search(params, current_user)
        q = search_attributes(params, [:id, :created_at, :updated_at, :query], current_user: current_user)

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
        return if redis.nil?

        redis_key = "search:#{query}"
        return if redis.exists?(redis_key)

        post_ids = Post.with_timeout(timeout, [], query: query) do
          Post.anon_tag_match(query).limit(QUERY_LIMIT).pluck(:id)
        end

        if post_ids.present?
          redis.sadd(redis_key, post_ids)
          redis.expire(redis_key, REDIS_EXPIRY.to_i)
        end
      end
    end
  end

  concerning :Queries do
    extend Memoist

    class_methods do
      def normalize_query(query)
        PostQuery.new(query.to_s).replace_aliases.to_infix
      end

      def queries_for(user_id, label: nil)
        searches = SavedSearch.where(user_id: user_id)
        searches = searches.labeled(label) if label.present?
        queries = searches.map(&:normalized_query)
        queries.sort.uniq
      end

      def rewrite_queries!(old_name, new_name)
        has_tag(old_name).find_each do |ss|
          ss.with_lock do
            ss.rewrite_query(old_name, new_name)
            ss.save!(validate: false)
          end
        end
      end
    end

    def query=(query)
      super
      flush_cache(:post_query)
      flush_cache(:normalized_query)
    end

    memoize def post_query
      PostQuery.new(query)
    end

    memoize def normalized_query
      PostQuery.normalize(query).sort.to_s
    end

    def rewrite_query(old_name, new_name)
      query.gsub!(/(?:\A| )([-~])?#{Regexp.escape(old_name)}(?: |\z)/i) { " #{$1}#{new_name} " }
      query.strip!
    end
  end

  def validate_query
    if post_query.total_term_count > MAX_TAGS
      errors.add(:query, "can't have more than #{MAX_TAGS} tags")
    end
  end

  def validate_labels
    if labels.any? { |label| label.length > 100 }
      errors.add(:labels, "can't have labels more than 100 characters long")
    end
  end

  def validate_count
    if user.saved_searches.count >= user.max_saved_searches
      errors.add(:user, "can only have up to #{user.max_saved_searches} " + "saved search".pluralize(user.max_saved_searches))
    end
  end

  def disable_labels=(value)
    user.update(disable_categorized_saved_searches: true) if value.to_s.truthy?
  end
end
