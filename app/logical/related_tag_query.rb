class RelatedTagQuery
  attr_reader :query, :category
  
  def initialize(query, category)
    @query = query.strip
    @category = category
  end

  def tags
    if query =~ /\*/
      pattern_matching_tags
    elsif category.present?
      related_tags_by_category
    else
      related_tags
    end
  end
  
  def wiki_page_tags
    results = wiki_page.try(:tags) || []
    results.reject! do |name|
      name =~ /^(?:list_of_|tag_group|pool_group|howto:|about:|help:|template:)/
    end
    results
  end
  
  def to_json
    {:query => query, :category => category, :tags => map_with_category_data(tags), :wiki_page_tags => map_with_category_data(wiki_page_tags)}.to_json
  end
  
protected
  
  def map_with_category_data(list_of_tag_names)
    Tag.categories_for(list_of_tag_names).to_a
  end
  
  def pattern_matching_tags
    Tag.name_matches(query).order("post_count desc").limit(50).sort_by {|x| x.name}.map(&:name)
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
