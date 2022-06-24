# frozen_string_literal: true

class AITag < ApplicationRecord
  belongs_to :tag
  belongs_to :media_asset
  has_one :post, through: :media_asset

  validates :score, inclusion: { in: (0.0..1.0) }

  def self.search(params)
    q = search_attributes(params, :media_asset, :tag, :post, :score)

    if params[:tag_name].present?
      q = q.where(tag_id: Tag.find_by_name_or_alias(params[:tag_name])&.id)
    end

    if params[:is_posted].to_s.truthy?
      q = q.where.associated(:post)
    elsif params[:is_posted].to_s.falsy?
      q = q.where.missing(:post)
    end

    q = q.apply_default_order(params)
    q
  end

  def self.default_order
    order(media_asset_id: :desc, tag_id: :asc)
  end

  def correct?
    if post.nil?
      false
    elsif tag.name =~ /\Arating:(.)\z/
      post.rating == $1
    else
      post.has_tag?(tag.name)
    end
  end
end
