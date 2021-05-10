module TagsHelper
  def tag_class(tag)
    return nil if tag.blank?
    "tag-type-#{tag.category}"
  end
end
