# frozen_string_literal: true

# A MediaAssetQuery is a tag search performed on media assets (or upload media assets) using AI tags.
class MediaAssetQuery
  extend Memoist

  METATAGS = %w[id md5 pixelhash width height duration mpixels ratio filesize filetype date age status is exif]

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
    @ast ||= PostQuery::Parser.parse(search_string, metatags: METATAGS)
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
        tag_name, score = node.name.split(",")
        score_range = score&.delete("%").presence || score_range

        ai_tag = AITag.named(tag_name).where_numeric_matches(:score, score_range.to_s)
        relation.where(ai_tag.where(AITag.arel_table[:media_asset_id].eq(relation.arel_table[foreign_key])).arel.exists)
      in :metatag
        metatag_matches(node.name, node.value, relation)
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

  def metatag_matches(name, value, relation)
    case name
    when "id"
      relation.attribute_matches(value, :id)
    when "md5"
      relation.attribute_matches(value, "media_assets.md5", :md5)
    when "pixelhash"
      relation.attribute_matches(value, "media_assets.pixel_hash", :md5)
    when "width"
      relation.attribute_matches(value, "media_assets.image_width")
    when "height"
      relation.attribute_matches(value, "media_assets.image_height")
    when "duration"
      relation.attribute_matches(value, "media_assets.duration", :float)
    when "mpixels"
      relation.attribute_matches(value, "(media_assets.image_width * media_assets.image_height) / 1000000.0", :float)
    when "ratio"
      relation.attribute_matches(value, "ROUND(media_assets.image_width::numeric / media_assets.image_height::numeric, 2)", :ratio)
    when "filesize"
      relation.attribute_matches(value, "media_assets.file_size", :filesize)
    when "filetype"
      relation.attribute_matches(value, "media_assets.file_ext", :enum)
    when "date"
      relation.attribute_matches(value, :created_at, :date)
    when "age"
      relation.attribute_matches(value, :created_at, :age)
    when "status"
      relation.attribute_matches(value, :status, :enum)
    when "is"
      relation.is_matches(value)
    when "exif"
      relation.exif_matches(value)
    end
  end
end
