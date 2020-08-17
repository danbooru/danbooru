class PostFlag < ApplicationRecord
  class Error < StandardError; end

  module Reasons
    UNAPPROVED = "Unapproved in three days"
    REJECTED = "Unapproved in three days after returning to moderation queue%"
  end

  belongs_to :creator, class_name: "User"
  belongs_to :post
  validates :reason, presence: true, length: { in: 1..140 }
  validate :validate_creator_is_not_limited, on: :create
  validate :validate_post, on: :create
  validates_uniqueness_of :creator_id, scope: :post_id, on: :create, unless: :is_deletion, message: "have already flagged this post"
  before_save :update_post
  attr_accessor :is_deletion

  enum status: {
    pending: 0,
    succeeded: 1,
    rejected: 2
  }

  scope :by_users, -> { where.not(creator: User.system) }
  scope :by_system, -> { where(creator: User.system) }
  scope :in_cooldown, -> { by_users.where("created_at >= ?", Danbooru.config.moderation_period.ago) }
  scope :expired, -> { pending.where("post_flags.created_at < ?", Danbooru.config.moderation_period.ago) }
  scope :active, -> { pending.or(rejected.in_cooldown) }

  module SearchMethods
    def creator_matches(creator, searcher)
      return none if creator.nil?

      policy = Pundit.policy!([searcher, nil], PostFlag.new(creator: creator))

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

    def search(params)
      q = super

      q = q.search_attributes(params, :reason, :status)
      q = q.text_attribute_matches(:reason, params[:reason_matches])

      if params[:creator_id].present?
        flagger = User.find(params[:creator_id])
        q = q.creator_matches(flagger, CurrentUser.user)
      elsif params[:creator_name].present?
        flagger = User.find_by_name(params[:creator_name])
        q = q.creator_matches(flagger, CurrentUser.user)
      end

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

  def update_post
    post.update_column(:is_flagged, true) unless post.is_flagged?
  end

  def validate_creator_is_not_limited
    errors[:creator] << "have reached your flag limit" if creator.is_flag_limited? && !is_deletion
  end

  def validate_post
    errors[:post] << "is pending and cannot be flagged" if post.is_pending? && !is_deletion
    errors[:post] << "is deleted and cannot be flagged" if post.is_deleted? && !is_deletion
    errors[:post] << "is locked and cannot be flagged" if post.is_status_locked?

    flag = post.flags.in_cooldown.last
    if !is_deletion && flag.present?
      errors[:post] << "cannot be flagged more than once every #{Danbooru.config.moderation_period.inspect} (last flagged: #{flag.created_at.to_s(:long)})"
    end
  end

  def uploader_id
    post.uploader_id
  end

  def self.searchable_includes
    [:post]
  end

  def self.available_includes
    [:post]
  end
end
