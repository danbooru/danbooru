# frozen_string_literal: true

class TagListComponent < ApplicationComponent
  attr_reader :tags, :current_query, :search_params

  delegate :humanized_number, to: :helpers

  def initialize(tags: [], current_query: nil, search_params: {})
    super
    @tags = tags
    @current_query = current_query
    @search_params = search_params
  end

  def self.tags_from_names(tag_names)
    names_to_tags = Tag.where(name: tag_names).index_by(&:name)

    tag_names.map do |name|
      names_to_tags.fetch(name) { Tag.new(name: name).freeze }
    end
  end

  def categorized_tags(categories, &block)
    return to_enum(:categorized_tags, categories) unless block_given?

    categories.each do |category|
      tags = tags_for_category(category)
      yield category, tags if tags.present?
    end
  end

  def tags_for_category(category_name)
    category = TagCategory.mapping[category_name.downcase]
    tags_by_category[category] || []
  end

  def tags_by_category
    @tags_by_category ||= tags.sort_by(&:name).group_by(&:category)
  end

  def is_underused_tag?(tag)
    tag.post_count <= 1 && tag.general? && tag.name !~ /_\((cosplay|style)\)\z/
  end
end
