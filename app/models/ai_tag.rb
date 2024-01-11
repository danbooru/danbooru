# frozen_string_literal: true

class AITag < ApplicationRecord
  self.primary_key = :media_asset_id, :tag_id

  belongs_to :tag
  belongs_to :media_asset
  has_one :post, through: :media_asset
  has_one :aliased_tag, through: :tag

  validates :score, inclusion: { in: (0..100) }

  scope :deprecated, -> { where(tag: Tag.deprecated) }
  scope :undeprecated, -> { where(tag: Tag.undeprecated) }
  scope :empty, -> { where(tag: Tag.empty) }
  scope :nonempty, -> { where(tag: Tag.nonempty) }

  delegate :name, :pretty_name, :post_count, :category, :category_name, :to_aliased_tag, :is_deprecated?, :empty?, :is_aliased?, :metatag?, to: :tag

  def self.named(name)
    name = $1.downcase if name =~ /\A(rating:.)/i
    where(tag: Tag.find_by_name_or_alias(name))
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:media_asset, :tag, :post, :score], current_user: current_user)

    if params[:tag_name].present?
      q = q.named(params[:tag_name])
    end

    if params[:is_posted].to_s.truthy?
      q = q.where.associated(:post)
    elsif params[:is_posted].to_s.falsy?
      q = q.where.missing(:post)
    end

    case params[:order]
    when "score", "score_desc"
      q = q.order(score: :desc, media_asset_id: :desc, tag_id: :desc)
    when "score_asc"
      q = q.order(score: :asc, media_asset_id: :asc, tag_id: :asc)
    when "media_asset_id", "media_asset_id_desc"
      q = q.order(media_asset_id: :desc, tag_id: :desc)
    when "media_asset_id_asc"
      q = q.order(media_asset_id: :asc, tag_id: :asc)
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def self.default_order
    order(media_asset_id: :desc, tag_id: :asc)
  end

  # True if the AI tag is present on the post; false if the AI tag is not on the post, or the asset isn't a post yet.
  def post_tagged?
    if media_asset.post.nil?
      false
    elsif tag.name =~ /\Arating:(.)\z/
      media_asset.post.rating == $1.first
    else
      media_asset.post.has_tag?(tag.name)
    end
  end

  def self.available_includes
    %i[media_asset post tag]
  end
end
