module RelatedTagCalculator
  def self.similar_tags_for_search(tag_query, search_sample_size: 1000, tag_sample_size: 250, category: nil)
    search_count = Post.fast_count(tag_query)
    search_sample_size = [search_count, search_sample_size].min
    return [] if search_sample_size <= 0

    tags = frequent_tags_for_search(tag_query, search_sample_size: search_sample_size, category: category).limit(tag_sample_size)
    tags = tags.sort_by do |tag|
      # cosine distance(tag1, tag2) = 1 - {{tag1 tag2}} / sqrt({{tag1}} * {{tag2}})
      1 - tag.overlap_count / (Math.sqrt(tag.post_count * search_count.to_f))
    end

    tags
  end

  def self.frequent_tags_for_search(tag_query, search_sample_size: 1000, category: nil)
    sample_posts = Post.tag_match(tag_query).reorder(:md5).limit(search_sample_size)
    tag_counts = Post.from(sample_posts).with_unflattened_tags.group("tag").select("tag, COUNT(*) AS overlap_count")

    tags = Tag.from(tag_counts).joins("JOIN tags ON tags.name = tag")
    tags = tags.select("tags.*, overlap_count")
    tags = tags.where("tags.post_count > 0")
    tags = tags.where(category: category) if category.present?
    tags = tags.order("overlap_count DESC, tags.post_count DESC, tags.name")
    tags
  end

  def self.frequent_tags_for_posts(posts)
    tags_with_counts = posts.flat_map(&:tag_array).group_by(&:itself).transform_values(&:size)
    tags_with_counts.sort_by { |tag_name, count| [-count, tag_name] }.map(&:first)
  end
end
