class RelatedTagQuery
  attr_reader :query, :category, :translated_tags, :artists

  def initialize(query, category: nil, translated_tags: nil, artists: nil);
    @query = TagAlias.to_aliased(query.to_s.downcase.strip).join(" ")
    @category = category
    @translated_tags = translated_tags.to_s.split
    @artists = Artist.where(name: artists.to_s.split)
    @artists = [Artist.find_by(name: "banned_artist")] + @artists if @artists.any?(&:is_banned?)
  end

  def pretty_name
    query.tr("_", " ")
  end

  def tags
    if query =~ /\*/
      pattern_matching_tags
    elsif category.present?
      related_tags_by_category
    elsif query.present?
      related_tags
    else
      []
    end
  end

  def wiki_page_tags
    results = wiki_page.try(:tags) || []
    results.reject! do |name|
      name =~ /^(?:list_of_|tag_group|pool_group|howto:|about:|help:|template:)/
    end
    results
  end

  def other_wiki_category_tags
    return [] unless Tag.category_for(query) == Tag.categories.copyright

    other_wikis = wiki_page&.tags.to_a.grep(/^list_of_/i)
    other_wikis = other_wikis.map { |name| WikiPage.titled(name).first }
    other_wikis = other_wikis.select { |wiki| wiki.tags.present? }
    other_wikis
  end

  def tags_for_html
    map_with_category_data(tags)
  end

  def to_json
    {:query => query, :category => category, :tags => map_with_category_data(tags), :wiki_page_tags => map_with_category_data(wiki_page_tags), :other_wikis => other_wiki_category_tags}.to_json
  end

protected

  def map_with_category_data(list_of_tag_names)
    Tag.categories_for(list_of_tag_names).to_a
  end

  def pattern_matching_tags
    Tag.name_matches(query).where("post_count > 0").order("post_count desc").limit(50).sort_by {|x| x.name}.map(&:name)
  end

  def related_tags
    tag = Tag.named(query.strip).first

    if tag
      tag.related_tag_array.map(&:first)
    else
      []
    end
  end

  def related_tags_by_category
    RelatedTagCalculator.calculate_from_sample_to_array(query, Tag.categories.value_for(category)).map(&:first)
  end

  def wiki_page
    WikiPage.titled(query).first
  end
end
