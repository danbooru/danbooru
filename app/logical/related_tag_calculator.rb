# frozen_string_literal: true

# Calculate the tags similar to a given tag. Two tags are similar if they have
# nearly the same set of posts, and nearly the same size.
#
# Similarity is calculated using cosine similarity, which is defined as the
# number of items two sets A and B have in common, divided by sqrt(||A|| * ||B||),
# where ||A|| is the size of A. The sqrt of the sizes can be thought of as a
# normalizing factor, to normalize the number of posts in common to a 0.0 - 1.0
# range.
#
# We optimize the calculation by sampling only 1000 random posts from the tag,
# calculating the number of times each tag on those posts appears, then taking
# the top 250 most frequently appearing tags as candidates for similar tags.
#
# Related tags are used for the tag sidebar when doing a search, and for the
# related tags feature when tagging a post.
#
# @see https://en.wikipedia.org/wiki/Cosine_similarity
class RelatedTagCalculator
  extend Memoist

  attr_reader :post_query, :search_sample_size, :tag_sample_size, :categories

  RelatedTag = Data.define(:tag, :overlap_count, :search_count, :sample_count) do
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    delegate :name, :pretty_name, :category, :post_count, :general?, to: :tag

    # https://en.wikipedia.org/wiki/Cosine_similarity#Otsuka%E2%80%93Ochiai_coefficient
    def cosine_similarity
      overlap / Math.sqrt(tag.post_count * search_count.to_f)
    end

    # https://en.wikipedia.org/wiki/Jaccard_index
    def jaccard_similarity
      overlap / (tag.post_count + search_count - overlap)
    end

    # https://en.wikipedia.org/wiki/Overlap_coefficient
    def overlap_coefficient
      overlap / [tag.post_count, search_count].min
    end

    # The estimated number of posts in common between tag A and tag B; that is, the intersection between A and B.
    def overlap
      [frequency * search_count, tag.post_count].min.to_f
    end

    # The estimated percentage of posts in common between tag A and tag B; that is, how frequently tag A appears together with tag B.
    def frequency
      overlap_count.to_f / sample_count.to_f
    end

    def attributes
      %i[tag cosine_similarity jaccard_similarity overlap_coefficient frequency].map { |name| [name, send(name)] }.to_h
    end
  end

  # @param post_query [PostQuery] The search to calculate related tags for. Usually a single tag, but may be an arbitrary search.
  # @param search_sample_size [Integer] The number of posts to sample from the search.
  # @param tag_sample_size [Integer] The maximum number of tags to return.
  # @param categories [Array<Integer>] An optional list of tag categories, to restrict the tags to a given category.
  def initialize(post_query = nil, search_sample_size: 5000, tag_sample_size: 500, categories: nil)
    @post_query = post_query
    @search_sample_size = search_sample_size
    @tag_sample_size = tag_sample_size
    @categories = categories
  end

  # Return the set of tags similar to the given search.
  #
  # @return [Array<RelatedTag>] The set of similar tags, ordered by highest cosine similarity first.
  memoize def similar_tags_for_search
    frequent_tags_for_search.sort_by(&:cosine_similarity).reverse
  end

  # Return the set of tags most frequently appearing in the given search.
  #
  # @return [Array<RelatedTag>] The set of frequent tags, ordered by most frequent first.
  memoize def frequent_tags_for_search
    sample_posts = post_query.posts.reorder(:md5).limit(search_sample_size)
    search_count = post_query.fast_count(timeout: post_query.current_user.statement_timeout)
    frequent_tags_for_post_relation(sample_posts, search_count)
  end

  # Return the set of tags most frequently appearing in the given set of posts.
  #
  # @param posts [ActiveRecord::Relation<Post>] the set of posts
  # @param search_count [Integer] The total number of posts in the search
  # @return [Array<RelatedTag>] The set of related tags, ordered by most frequent first.
  def frequent_tags_for_post_relation(posts, search_count)
    return [] if search_count.nil?

    tag_counts = Post.from(posts).with_unflattened_tags.group("tag").select("tag, COUNT(*) AS overlap_count")

    tags = Tag.from(tag_counts).joins("JOIN tags ON tags.name = tag")
    tags = tags.select("tags.*, overlap_count")
    tags = tags.nonempty.undeprecated
    tags = tags.where(category: categories) if categories.present?
    tags = tags.order("overlap_count DESC, tags.post_count DESC, tags.name")
    tags = tags.limit(tag_sample_size)
    tags.map do |tag|
      RelatedTag.new(tag: tag, overlap_count: tag.overlap_count, search_count: search_count, sample_count: [search_count, search_sample_size].min)
    end
  end

  # Return the set of tags most frequently appearing in the given array of posts.
  #
  # @param posts [Array<Post>] the array of posts
  # @param categories [Array<Integer>] the list of tag categories to include
  # @param max_tags [Integer} the maxmimum number of tags to return
  # @return [Array<Tag>] the set of frequent tags, ordered by most frequent
  def self.frequent_tags_for_post_array(posts, categories: TagCategory.category_ids, max_tags: 10)
    tags_with_counts = posts.flat_map(&:tag_array).group_by(&:itself).transform_values(&:size)
    tag_names = tags_with_counts.sort_by { |tag_name, count| [-count, tag_name] }.map(&:first).take(max_tags * 2)
    Tag.where(name: tag_names, category: categories).to_a.in_order_of(:name, tag_names).take(max_tags)
  end

  # Return a cached set of tags similar to the given search.
  #
  # @param max_tags [Integer] the maximum number of tags to return
  # @param categories [Array<Integer>] the list of tag categories to include
  # @param search_timeout [Integer] the database timeout for the search
  # @param cache_timeout [Integer] the length of time to cache the results
  # @return [Array<Tag>] the set of similar tags, ordered by most similar
  def cached_similar_tags_for_search(max_tags, categories: TagCategory.category_ids, search_timeout: 2000, cache_timeout: 8.hours)
    # Some searches are cached on a per-user basis because they depend on the current user (for example, searches for
    # private favorites, favgroups, or saved searches).
    if post_query.is_user_dependent_search?
      cache_key = "similar-tags-for-user:#{post_query.current_user.id}:#{max_tags}:#{categories}:#{post_query.to_s}"
    else
      cache_key = "similar-tags:#{max_tags}:#{categories}:#{post_query.to_s}"
    end

    tag_names = Cache.get(cache_key, cache_timeout, race_condition_ttl: 60.seconds) do
      ApplicationRecord.with_timeout(search_timeout, []) do
        tags = similar_tags_for_search.select { |related_tag| related_tag.tag.category.in?(categories) }
        tags.map(&:name).take(max_tags)
      end
    end

    Tag.where(name: tag_names).to_a.in_order_of(:name, tag_names)
  end
end
