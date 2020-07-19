class PostFlag < ApplicationRecord
  class Error < StandardError; end

  module Reasons
    UNAPPROVED = "Unapproved in three days"
    REJECTED = "Unapproved in three days after returning to moderation queue%"
  end

  COOLDOWN_PERIOD = 3.days

  belongs_to :creator, class_name: "User"
  belongs_to :post
  validates :reason, presence: true, length: { in: 1..140 }
  validate :validate_creator_is_not_limited, on: :create
  validate :validate_post
  validates_uniqueness_of :creator_id, :scope => :post_id, :on => :create, :unless => :is_deletion, :message => "have already flagged this post"
  before_save :update_post
  attr_accessor :is_deletion

  scope :by_users, -> { where.not(creator: User.system) }
  scope :by_system, -> { where(creator: User.system) }
  scope :in_cooldown, -> { by_users.where("created_at >= ?", COOLDOWN_PERIOD.ago) }
  scope :resolved, -> { where(is_resolved: true) }
  scope :unresolved, -> { where(is_resolved: false) }
  scope :recent, -> { where("post_flags.created_at >= ?", 1.day.ago) }
  scope :old, -> { where("post_flags.created_at <= ?", 3.days.ago) }

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

      q = q.search_attributes(params, :is_resolved, :reason)
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
    return if is_deletion

    if creator.can_approve_posts?
      # do nothing
    elsif creator.created_at > 1.week.ago
      errors[:creator] << "cannot flag within the first week of sign up"
    elsif creator.is_gold? && flag_count_for_creator >= 10
      errors[:creator] << "can flag 10 posts a day"
    elsif !creator.is_gold? && flag_count_for_creator >= 1
      errors[:creator] << "can flag 1 post a day"
    end

    flag = post.flags.in_cooldown.last
    if flag.present?
      errors[:post] << "cannot be flagged more than once every #{COOLDOWN_PERIOD.inspect} (last flagged: #{flag.created_at.to_s(:long)})"
    end
  end

  def validate_post
    errors[:post] << "is pending and cannot be flagged" if post.is_pending? && !is_deletion
    errors[:post] << "is locked and cannot be flagged" if post.is_status_locked?
    errors[:post] << "is deleted" if post.is_deleted?
  end

  def resolve!
    update_column(:is_resolved, true)
  end

  def flag_count_for_creator
    creator.post_flags.recent.count
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
