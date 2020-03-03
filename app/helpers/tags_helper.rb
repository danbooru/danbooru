module TagsHelper
  def tag_class(tag)
    return nil if tag.blank?
    "tag-type-#{tag.category}"
  end

  def tag_alias_for_pattern(tag, pattern)
    return nil if pattern.blank?

    tag.consequent_aliases.find do |tag_alias|
      !tag.name.ilike?(pattern) && tag_alias.antecedent_name.ilike?(pattern)
    end
  end
end
