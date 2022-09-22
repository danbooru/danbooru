# frozen_string_literal: true

class PostFlag < ApplicationRecord
  module Reasons
    UNAPPROVED = "Unapproved in three days"
    REJECTED = "Unapproved in three days after returning to moderation queue%"
  end

  belongs_to :creator, class_name: "User"
  belongs_to :post

  before_validation { post.lock! }
  validates :reason, presence: true, length: { in: 1..140 }
  validate :validate_creator_is_not_limited, on: :create
  validate :validate_post, on: :create
  validates :creator_id, uniqueness: { scope: :post_id, on: :create, unless: :is_deletion, message: "have already flagged this post" }
  before_save :update_post
  after_create :prune_disapprovals
  attr_accessor :is_deletion

  enum status: {
    pending: 0,
    succeeded: 1,
    rejected: 2,
  }

  scope :by_users, -> { where.not(creator: User.system) }
  scope :by_system, -> { where(creator: User.system) }
  scope :in_cooldown, -> { by_users.where("created_at >= ?", Danbooru.config.moderation_period.ago) }
  scope :expired, -> { pending.where("post_flags.created_at < ?", Danbooru.config.moderation_period.ago) }
  scope :active, -> { pending.or(rejected.in_cooldown) }

  module SearchMethods
    def creator_matches(creator, searcher)
      return none if creator.nil?

      policy = Pundit.policy!(searcher, PostFlag.unscoped.new(creator: creator))

      if policy.can_view_flagger?
        where(creator: creator).where.not(post: searcher.posts)
      else
        none
      end
    end

    def category_matches(category)
      case category
      when "normal"
        where("reason NOT IN (?) AND reason NOT LIKE ?", [Reasons::UNAPPROVED], Reasons::REJECTED)
      when "unapproved"
        where(reason: Reasons::UNAPPROVED)
      when "rejected"
        where("reason LIKE ?", Reasons::REJECTED)
      when "deleted"
        where("reason = ? OR reason LIKE ?", Reasons::UNAPPROVED, Reasons::REJECTED)
      else
        none
      end
    end

    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :reason, :status, :post, :creator], current_user: current_user)

      if params[:category]
        q = q.category_matches(params[:category])
      end

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def category
    case reason
    when Reasons::UNAPPROVED
      :unapproved
    when /#{Reasons::REJECTED.gsub("%", ".*")}/
      :rejected
    else
      :normal
    end
  end

  def prune_disapprovals
    return if is_deletion
    PostDisapproval.where(post: post).delete_all
  end

  def update_post
    post.update_column(:is_flagged, true) unless post.is_flagged?
  end

  def validate_creator_is_not_limited
    errors.add(:creator, "have reached your flag limit") if creator.is_flag_limited? && !is_deletion
  end

  def validate_post
    errors.add(:post, "is pending and cannot be flagged") if post.is_pending? && !is_deletion
    errors.add(:post, "is deleted and cannot be flagged") if post.is_deleted? && !is_deletion

    flag = post.flags.in_cooldown.last
    if !is_deletion && !creator.is_approver? && flag.present?
      errors.add(:post, "cannot be flagged more than once every #{Danbooru.config.moderation_period.inspect} (last flagged: #{flag.created_at.to_formatted_s(:long)})")
    end
  end

  def uploader_id
    post.uploader_id
  end

  def self.available_includes
    [:post]
  end
end
