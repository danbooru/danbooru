class PostAppeal < ApplicationRecord
  class Error < StandardError; end

  MAX_APPEALS_PER_DAY = 1

  belongs_to :creator, :class_name => "User"
  belongs_to :post
  validates_presence_of :reason
  validate :validate_post_is_inactive
  validate :validate_creator_is_not_limited
  validates_uniqueness_of :creator_id, :scope => :post_id, :message => "have already appealed this post"

  api_attributes including: [:is_resolved]

  module SearchMethods
    def resolved
      joins(:post).where("posts.is_deleted = false and posts.is_flagged = false")
    end

    def unresolved
      joins(:post).where("posts.is_deleted = true or posts.is_flagged = true")
    end

    def recent
      where("created_at >= ?", 1.day.ago)
    end

    def search(params)
      q = super
      q = q.search_attributes(params, :creator, :post, :reason)
      q = q.text_attribute_matches(:reason, params[:reason_matches])

      q = q.resolved if params[:is_resolved].to_s.truthy?
      q = q.unresolved if params[:is_resolved].to_s.falsy?

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def resolved?
    post.present? && !post.is_deleted? && !post.is_flagged?
  end

  def is_resolved
    resolved?
  end

  def validate_creator_is_not_limited
    if appeal_count_for_creator >= MAX_APPEALS_PER_DAY
      errors[:creator] << "can appeal at most #{MAX_APPEALS_PER_DAY} post a day"
    end
  end

  def validate_post_is_inactive
    if resolved?
      errors[:post] << "is active"
    end
  end

  def appeal_count_for_creator
    creator.post_appeals.recent.count
  end

  def self.available_includes
    [:creator, :post]
  end
end
