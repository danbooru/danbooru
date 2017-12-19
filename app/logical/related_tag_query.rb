class RelatedTagQuery
  attr_reader :query, :category

  def initialize(query, category = nil)
    @query = TagAlias.to_aliased(query.strip).join(" ")
    @category = category
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
    if Tag.category_for(query) != Tag.categories.copyright
      return []
    end
    listtags = (wiki_page.try(:tags) || []).select {|name| name =~ /^list_of_/i }
    results = listtags.map do |name|
      listlinks = WikiPage.titled(name).first.try(:tags) || []
      if listlinks.length > 0
        {"title" => name, "wiki_page_tags" => map_with_category_data(listlinks)}
      end
    end
    results.reject {|list| list.nil?}
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
