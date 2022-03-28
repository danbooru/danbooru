# frozen_string_literal: true

class PostQuery
  extend Memoist

  attr_reader :search, :parser, :ast
  delegate :inspect, :is_single_tag?, :is_metatag?, :tag_names, to: :ast

  def initialize(search)
    @search = search
    @parser = Parser.new(search)
    @ast = parser.parse.simplify
  end

  def tag
    tags.first if is_single_tag?
  end

  def tags
    Tag.where(name: tag_names)
  end

  memoize :tag, :tags
end
