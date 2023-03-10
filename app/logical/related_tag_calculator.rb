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
module RelatedTagCalculator
  # Return the set of tags similar to the given search.
  # @param post_query [PostQuery] the search to find similar tags for.
  # @param search_sample_size [Integer] the number of posts to sample from the search
  # @param tag_sample_size [Integer] the number of tags to calculate similarity for
  # @param category [Integer] an optional tag category, to restrict the tags to a given category.
  # @return [Array<Tag>] the set of similar tags, ordered by most similar
  def self.similar_tags_for_search(post_query, search_sample_size: 1000, tag_sample_size: 250, category: nil)
    search_count = post_query.post_count
    return [] if search_count.nil?

    search_sample_size = [search_count, search_sample_size].min
    return [] if search_sample_size <= 0

    tags = frequent_tags_for_search(post_query, search_sample_size: search_sample_size, category: category).limit(tag_sample_size)
    tags = tags.sort_by do |tag|
      # cosine distance(tag1, tag2) = 1 - {{tag1 tag2}} / sqrt({{tag1}} * {{tag2}})
      1 - tag.overlap_count / Math.sqrt(tag.post_count * search_count.to_f)
    end

    tags
  end

  # Return the set of tags most frequently appearing in the given search.
  # @param post_query [PostQuery] the search to find frequent tags for.
  # @param search_sample_size [Integer] the number of posts to sample from the search
  # @param category [Integer] an optional tag category, to restrict the tags to a given category.
  # @return [Array<Tag>] the set of frequent tags, ordered by most frequent
  def self.frequent_tags_for_search(post_query, search_sample_size: 1000, category: nil)
    sample_posts = post_query.posts.reorder(:md5).limit(search_sample_size)
    frequent_tags_for_post_relation(sample_posts, category: category)
  end

  # Return the set of tags most frequently appearing in the given set of posts.
  # @param posts [ActiveRecord::Relation<Post>] the set of posts
  # @param category [Integer] an optional tag category, to restrict the tags to a given category.
  # @return [Array<Tag>] the set of frequent tags, ordered by most frequent
  def self.frequent_tags_for_post_relation(posts, category: nil)
    tag_counts = Post.from(posts).with_unflattened_tags.group("tag").select("tag, COUNT(*) AS overlap_count")

    tags = Tag.from(tag_counts).joins("JOIN tags ON tags.name = tag")
    tags = tags.select("tags.*, overlap_count")
    tags = tags.nonempty.undeprecated
    tags = tags.where(category: Tag.categories.value_for(category)) if category.present?
    tags = tags.order("overlap_count DESC, tags.post_count DESC, tags.name")
    tags
  end

  # Return the set of tags most frequently appearing in the given array of posts.
  # @param posts [Array<Post>] the array of posts
  # @return [Array<Tag>] the set of frequent tags, ordered by most frequent
  def self.frequent_tags_for_post_array(posts)
    tags_with_counts = posts.flat_map(&:tag_array).group_by(&:itself).transform_values(&:size)
    tags_with_counts.sort_by { |tag_name, count| [-count, tag_name] }.map(&:first)
  end

  # Return a cached set of tags similar to the given search.
  # @param post_query [PostQuery] the search to find similar tags for.
  # @param max_tags [Integer] the maximum number of tags to return
  # @param search_timeout [Integer] the database timeout for the search
  # @param cache_timeout [Integer] the length of time to cache the results
  # @return [Array<String>] the set of similar tag names, ordered by most similar
  def self.cached_similar_tags_for_search(post_query, max_tags, search_timeout: 2000, cache_timeout: 8.hours)
    Cache.get(cache_key(post_query), cache_timeout, race_condition_ttl: 60.seconds) do
      ApplicationRecord.with_timeout(search_timeout, []) do
        similar_tags_for_search(post_query).take(max_tags).pluck(:name)
      end
    end
  end

  # Return a cache key for the given search. Some searches are cached on a
  # per-user basis because they depend on the current user (for example,
  # searches for private favorites, favgroups, or saved searches).
  # @param post_query [PostQuery] the post search
  # @return [String] the cache key
  def self.cache_key(post_query)
    if post_query.is_user_dependent_search?
      "similar_tags[#{post_query.current_user.id}]:#{post_query.to_s}"
    else
      "similar_tags:#{post_query.to_s}"
    end
  end
end
