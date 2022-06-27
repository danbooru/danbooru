# frozen_string_literal: true

class AITag < ApplicationRecord
  belongs_to :tag
  belongs_to :media_asset
  has_one :post, through: :media_asset

  validates :score, inclusion: { in: (0.0..1.0) }

  def self.named(name)
    name = $1.downcase if name =~ /\A(rating:.)/i
    where(tag: Tag.find_by_name_or_alias(name))
  end

  def self.search(params)
    q = search_attributes(params, :media_asset, :tag, :post, :score)

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
    if post.nil?
      false
    elsif tag.name =~ /\Arating:(.)\z/
      post.rating == $1
    else
      post.has_tag?(tag.name)
    end
  end

  def self.available_includes
    %i[media_asset post tag]
  end
end
