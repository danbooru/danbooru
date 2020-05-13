class RelatedTagQuery
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

  attr_reader :query, :post_query, :category, :type, :user, :limit

  def initialize(query:, user: User.anonymous, category: nil, type: nil, limit: nil)
    @user = user
    @post_query = PostQueryBuilder.new(query, user).normalized_query
    @query = @post_query.to_s
    @category = category
    @type = type
    @limit = (limit =~ /^\d+/ ? limit.to_i : 25)
  end

  def pretty_name
    query.tr("_", " ")
  end

  def tags
    if type == "frequent"
      frequent_tags
    elsif type == "similar"
      similar_tags
    elsif type == "like"
      pattern_matching_tags("*#{query}*")
    elsif query =~ /\*/
      pattern_matching_tags(query)
    elsif category.present?
      frequent_tags
    elsif query.present?
      similar_tags
    else
      Tag.none
    end
  end

  def tags_overlap
    if type == "like" || query =~ /\*/
      {}
    else
      tags.map { |v| [v.name, v.overlap_count] }.to_h
    end
  end

  def frequent_tags
    @frequent_tags ||= RelatedTagCalculator.frequent_tags_for_search(post_query, category: category_of).take(limit)
  end

  def similar_tags
    @similar_tags ||= RelatedTagCalculator.similar_tags_for_search(post_query, category: category_of).take(limit)
  end

  # Returns the top 20 most frequently added tags within the last 20 edits made by the user in the last hour.
  def recent_tags(since: 1.hour.ago, max_edits: 20, max_tags: 20)
    return [] unless user.present? && PostVersion.enabled?

    versions = PostVersion.where(updater_id: user.id).where("updated_at > ?", since).order(id: :desc).limit(max_edits)
    tags = versions.flat_map(&:added_tags)
    tags = tags.reject { |tag| tag.match?(/\A(source:|parent:|rating:)/) }
    tags = tags.group_by(&:itself).transform_values(&:size).sort_by { |tag, count| [-count, tag] }.map(&:first)
    tags.take(max_tags)
  end

  def favorite_tags
    user&.favorite_tags.to_s.split
  end

  def wiki_page_tags
    wiki_page.try(:tags) || []
  end

  def other_wiki_pages
    if Tag.category_for(query) == Tag.categories.copyright
      copyright_other_wiki_pages
    elsif Tag.category_for(query) == Tag.categories.general
      general_other_wiki_pages
    else
      []
    end
  end

  def copyright_other_wiki_pages
    list_of_wikis = DText.parse_wiki_titles(wiki_page&.body&.to_s).grep(/\Alist_of_/i)
    map_tags_to_wikis(list_of_wikis)
  end

  def general_other_wiki_pages
    match = query.match(/(.+?)_\(cosplay\)/)
    return [] unless match
    map_tags_to_wikis([match[1]])
  end

  def map_tags_to_wikis(other_tags)
    other_wikis = other_tags.map { |name| WikiPage.titled(name).first }
    other_wikis = other_wikis.reject { |wiki| wiki.nil? }
    other_wikis = other_wikis.select { |wiki| wiki.tags.present? }
    other_wikis
  end

  def serializable_hash(**options)
    {
      query: query,
      category: category,
      tags: tags_with_categories(tags.map(&:name)),
      tags_overlap: tags_overlap,
      wiki_page_tags: tags_with_categories(wiki_page_tags),
      other_wikis: other_wiki_pages.map { |wiki| [wiki.title, tags_with_categories(wiki.tags)] }.to_h
    }
  end

  protected

  def tags_with_categories(list_of_tag_names)
    Tag.categories_for(list_of_tag_names).to_a
  end

  def category_of
    (category.present? ? Tag.categories.value_for(category) : nil)
  end

  def pattern_matching_tags(tag_query)
    tags = Tag.nonempty.name_matches(tag_query)
    tags = tags.where(category: Tag.categories.value_for(category)) if category.present?
    tags = tags.order("post_count desc, name asc").limit(limit)
    tags
  end

  def wiki_page
    WikiPage.titled(query).first
  end
end
