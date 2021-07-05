# rdoc
#   A tag set represents a set of tags that are displayed together.
#   This class makes it easy to fetch the categories for all the
#   tags in one call instead of fetching them sequentially.

class TagSetPresenter
  extend Memoist
  attr_reader :tag_names

  # @param [Array<String>] a list of tags to present. Tags will be presented in
  # the order given. The list should not contain duplicates. The list may
  # contain tags that do not exist in the tags table, such as metatags.
  def initialize(tag_names)
    @tag_names = tag_names
  end

  # the list of tags inside the tag box in the post edit form.
  def split_tag_list_text(category_list: TagCategory.categorized_list)
    category_list.map do |category|
      tags_for_category(category).map(&:name).join(" ")
    end.reject(&:blank?).join(" \n")
  end

  def humanized_essential_tag_string
    chartags = tags_for_category("character")
    characters = chartags.max_by(5, &:post_count).map(&:unqualified_name)
    characters += ["#{chartags.size - 5} more"] if chartags.size > 5
    characters = characters.to_sentence

    copytags = tags_for_category("copyright")
    copyrights = copytags.max_by(1, &:post_count).map(&:unqualified_name)
    copyrights += ["#{copytags.size - 1} more"] if copytags.size > 1
    copyrights = copyrights.to_sentence
    copyrights = "(#{copyrights})" if characters.present? && copyrights.present?

    artists = tags_for_category("artist").map(&:name).grep_v("banned_artist").to_sentence
    artists = "drawn by #{artists}" if artists.present?

    "#{characters} #{copyrights} #{artists}".strip
  end

  private

  def tags
    Tag.where(name: tag_names).select(:name, :post_count, :category)
  end

  def tags_by_category
    ordered_tags.group_by(&:category)
  end

  def tags_for_category(category_name)
    category = TagCategory.mapping[category_name.downcase]
    tags_by_category[category] || []
  end

  def ordered_tags
    names_to_tags = tags.index_by(&:name)

    tag_names.map do |name|
      names_to_tags[name] || Tag.new(name: name).freeze
    end
  end

  memoize :tags, :tags_by_category, :ordered_tags, :humanized_essential_tag_string
end
