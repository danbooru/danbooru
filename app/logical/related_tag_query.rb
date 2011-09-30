class RelatedTagQuery
  attr_reader :query, :category
  
  def initialize(query, category)
    @query = query
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
    wiki_page.try(:tags) || []
  end
  
protected
  
  def pattern_matching_tags
    Tag.name_matches(query).order("post_count desc").limit(50).sort_by {|x| x.name}.map(&:name)
  end
  
  def related_tags
    tag = Tag.named(query).first
    
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
