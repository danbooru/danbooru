# frozen_string_literal: true

# Handle finding related tags by the {RelatedTagsController}. Used for finding
# related tags when tagging a post.
class RelatedTagQuery
  extend Memoist
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

  attr_reader :query, :post_query, :media_asset, :categories, :search_sample_size, :tag_sample_size, :user, :order, :limit

  def initialize(query:, media_asset: nil, user: User.anonymous, categories: nil, search_sample_size: nil, tag_sample_size: nil, order: nil, limit: nil)
    @user = user
    @post_query = PostQuery.normalize(query, current_user: user) # XXX This query does not include implicit metatags (rating:s, -status:deleted)
    @query = @post_query.to_s
    @media_asset = media_asset
    @categories = categories
    @categories = @categories.to_s.split(/[[:space:],]/) unless categories.is_a?(Array)
    @categories = @categories.map { |c| Tag.categories.value_for(c) }
    @order = order
    @search_sample_size = search_sample_size.to_i.clamp(0, 100_000)
    @search_sample_size = 5000 if @search_sample_size == 0
    @tag_sample_size = tag_sample_size.to_i.clamp(0, 1000)
    @tag_sample_size = 500 if @tag_sample_size == 0
    @limit = limit.to_i.clamp(0, 1000)
    @limit = 100 if @limit == 0
  end

  def related_tags
    tags = related_tag_calculator.frequent_tags_for_search

    case order.to_s.downcase
    when "cosine"
      tags = tags.sort_by { |t| [-t.cosine_similarity, t.category, -t.post_count, t.name] }
    when "jaccard"
      tags = tags.sort_by { |t| [-t.jaccard_similarity, t.category, -t.post_count, t.name] }
    when "overlap"
      tags = tags.sort_by { |t| [-t.overlap_coefficient, t.category, -t.post_count, t.name] }
    else
      tags = tags.sort_by { |t| [-t.frequency, t.category, -t.post_count, t.name] }
    end

    tags.take(limit)
  end

  memoize def related_tag_calculator
    RelatedTagCalculator.new(post_query, categories: categories, search_sample_size: search_sample_size, tag_sample_size: tag_sample_size)
  end

  def results_present?
    related_tag_calculator.frequent_tags_for_search.present? || wiki_page_tags.present?
  end

  def frequent_tags(categories: [])
    tags = related_tag_calculator.frequent_tags_for_search
    tags = tags.select { |t| t.category.in?(categories) } if categories.present?
    tags = sort_by_category(tags) if categories.present?
    tags.take(limit)
  end

  def similar_tags(categories: related_categories, category_top_n: 4)
    tags = related_tag_calculator.similar_tags_for_search
    tags = tags.select { |t| t.category.in?(categories) } if categories.present?
    tags = sort_by_category(tags) if categories.present?

    category_counts = Hash.new { 0 }
    tags = tags.select do |t|
      category_counts[t.category] += 1
      t.general? || category_counts[t.category] <= category_top_n
    end

    tags.take(limit)
  end

  def ai_tags
    return AITag.none if media_asset.nil?

    tags = media_asset.ai_tags.includes(:tag, :aliased_tag)
    tags = tags.reject(&:is_deprecated?).reject { |t| t.empty? && !t.metatag? }
    tags = tags.sort_by { |t| [TagCategory.canonical_mapping.keys.index(t.category_name), -t.score, t.name] }
    tags.take(limit)
  end

  # Returns the top 20 most frequently added tags within the last 20 edits made by the user in the last hour.
  def recent_tags(since: 1.hour.ago, max_edits: 20, max_tags: 20)
    return [] unless user.present?

    versions = PostVersion.where(updater_id: user.id).where("updated_at > ?", since).order(id: :desc).limit(max_edits)
    tags = versions.flat_map(&:added_tags)
    tags = tags.reject { |tag| tag.match?(/\A(source:|parent:|rating:)/) }
    tags = tags.group_by(&:itself).transform_values(&:size).sort_by { |tag, count| [-count, tag] }.map(&:first)
    tags = tags.take(max_tags)
    tags = Tag.nonempty.undeprecated.named_or_aliased_in_order(tags)
    tags
  end

  def favorite_tags
    tag_names = user&.favorite_tags.to_s.split

    tag_names = TagAlias.to_aliased(tag_names)
    names_to_tags = Tag.where(name: tag_names).index_by(&:name)
    tags = tag_names.map { |name| names_to_tags[name] || Tag.new(name: name).freeze }
    tags = tags.reject(&:is_deprecated?).reject { |tag| tag.empty? && !tag.metatag? }

    tags
  end

  # The list of tags mentioned in the wiki page of the queried tag. General tags aren't included when looking up characters.
  memoize def wiki_page_tags
    tags = wiki_page&.tags.to_a

    if tag&.category == TagCategory::CHARACTER
      tags.reject { |t| t.category == TagCategory::GENERAL }
    else
      tags
    end
  end

  def serializable_hash(options = {})
    {
      query: query,
      post_count: post_query.post_count,
      tag: tag,
      related_tags: related_tags,
      wiki_page_tags: wiki_page_tags,
    }
  end

  memoize def tag
    post_query.tag
  end

  def related_categories
    category = tag&.category || TagCategory::CHARACTER
    TagCategory.related_tag_categories[category]
  end

  def cache_duration
    4.hours
  end

  def cache_publicly?
    !post_query.is_user_dependent_search?
  end

  protected

  def sort_by_category(tags)
    tags.sort_by.with_index { |tag, i| [related_categories.index(tag.category), i] }
  end

  memoize def wiki_page
    WikiPage.active.titled(query).first
  end
end
