# frozen_string_literal: true

# An AITagQuery is a tag search performed on media assets using AI tags. Only
# basic tags are allowed, no metatags.
class AITagQuery
  extend Memoist

  attr_reader :search_string
  delegate :to_infix, :to_pretty_string, to: :ast
  alias_method :to_s, :to_infix

  def initialize(search_string)
    @search_string = search_string.to_s.strip
  end

  def self.search(search_string, **options)
    new(search_string).search(**options)
  end

  def ast
    @ast ||= PostQuery::Parser.parse(search_string)
  end

  def normalized_ast
    @normalized_ast ||= ast.to_cnf.rewrite_opts.trim
  end

  def search(relation: MediaAsset.all, foreign_key: :id, score_range: (50..))
    normalized_ast.visit do |node, *children|
      case node.type
      in :all
        relation.all
      in :none
        relation.none
      in :tag
        ai_tag = AITag.named(node.name).where(score: score_range)
        relation.where(ai_tag.where(AITag.arel_table[:media_asset_id].eq(relation.arel_table[foreign_key])).arel.exists)
      in :metatag
        relation.none
      in :wildcard
        relation.none
      in :not
        children.first.negate_relation
      in :and
        joins = children.flat_map(&:joins_values)
        orders = children.flat_map(&:order_values)
        nodes = children.map { |child| child.joins(joins).order(orders) }
        nodes.reduce(&:and)
      in :or
        joins = children.flat_map(&:joins_values)
        orders = children.flat_map(&:order_values)
        nodes = children.map { |child| child.joins(joins).order(orders) }
        nodes.reduce(&:or)
      end
    end
  end
end
