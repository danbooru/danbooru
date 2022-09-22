# frozen_string_literal: true

class PostAppeal < ApplicationRecord
  belongs_to :creator, :class_name => "User"
  belongs_to :post

  validates :reason, length: { maximum: 140 }
  validate :validate_post_is_appealable, on: :create
  validate :validate_creator_is_not_limited, on: :create
  validates :creator, uniqueness: { scope: :post, message: "have already appealed this post" }, on: :create
  after_create :prune_disapprovals

  enum status: {
    pending: 0,
    succeeded: 1,
    rejected: 2,
  }

  scope :expired, -> { pending.where("post_appeals.created_at < ?", Danbooru.config.moderation_period.ago) }

  def prune_disapprovals
    PostDisapproval.where(post: post).delete_all
  end

  module SearchMethods
    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :reason, :status, :creator, :post], current_user: current_user)

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def validate_creator_is_not_limited
    errors.add(:creator, "have reached your appeal limit") if creator.is_appeal_limited?
  end

  def validate_post_is_appealable
    errors.add(:post, "cannot be appealed") if !post.is_appealable?
  end

  def self.available_includes
    [:creator, :post]
  end
end
