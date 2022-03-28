# frozen_string_literal: true

class PostQuery
  extend Memoist

  attr_reader :search, :parser, :ast
  delegate :tag_names, to: :ast

  def initialize(search)
    @search = search
    @parser = Parser.new(search)
    @ast = parser.parse.simplify
  end

  def tags
    Tag.where(name: tag_names)
  end

  memoize :tags
end
