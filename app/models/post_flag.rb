class PostFlag < ApplicationRecord
  class Error < StandardError; end

  module Reasons
    UNAPPROVED = "Unapproved in three days"
    REJECTED = "Unapproved in three days after returning to moderation queue%"
    BANNED = "Artist requested removal"
  end

  COOLDOWN_PERIOD = 3.days

  belongs_to :creator, class_name: "User"
  belongs_to :post
  validates_presence_of :reason
  validate :validate_creator_is_not_limited, on: :create
  validate :validate_post
  validates_uniqueness_of :creator_id, :scope => :post_id, :on => :create, :unless => :is_deletion, :message => "have already flagged this post"
  before_save :update_post
  attr_accessor :is_deletion

  scope :by_users, -> { where.not(creator: User.system) }
  scope :by_system, -> { where(creator: User.system) }
  scope :in_cooldown, -> { by_users.where("created_at >= ?", COOLDOWN_PERIOD.ago) }

  module SearchMethods
    def duplicate
      where("to_tsvector('english', post_flags.reason) @@ to_tsquery('dup | duplicate | sample | smaller')")
    end

    def not_duplicate
      where("to_tsvector('english', post_flags.reason) @@ to_tsquery('!dup & !duplicate & !sample & !smaller')")
    end

    def resolved
      where("is_resolved = ?", true)
    end

    def unresolved
      where("is_resolved = ?", false)
    end

    def recent
      where("created_at >= ?", 1.day.ago)
    end

    def old
      where("created_at <= ?", 3.days.ago)
    end

    def search(params)
      q = super

      q = q.search_attributes(params, :post, :is_resolved, :reason)
      q = q.text_attribute_matches(:reason, params[:reason_matches])

      # XXX
      if params[:creator_id].present?
        if CurrentUser.can_view_flagger?(params[:creator_id].to_i)
          q = q.where.not(post_id: CurrentUser.user.posts)
          q = q.where("creator_id = ?", params[:creator_id].to_i)
        else
          q = q.none
        end
      end

      # XXX
      if params[:creator_name].present?
        flagger_id = User.name_to_id(params[:creator_name].strip)
        if flagger_id && CurrentUser.can_view_flagger?(flagger_id)
          q = q.where.not(post_id: CurrentUser.user.posts)
          q = q.where("creator_id = ?", flagger_id)
        else
          q = q.none
        end
      end

      case params[:category]
      when "normal"
        q = q.where("reason NOT IN (?) AND reason NOT LIKE ?", [Reasons::UNAPPROVED, Reasons::BANNED], Reasons::REJECTED)
      when "unapproved"
        q = q.where(reason: Reasons::UNAPPROVED)
      when "banned"
        q = q.where(reason: Reasons::BANNED)
      when "rejected"
        q = q.where("reason LIKE ?", Reasons::REJECTED)
      when "deleted"
        q = q.where("reason = ? OR reason LIKE ?", Reasons::UNAPPROVED, Reasons::REJECTED)
      when "duplicate"
        q = q.duplicate
      end

      q.apply_default_order(params)
    end
  end

  module ApiMethods
    def api_attributes
      attributes = super + [:category]
      attributes -= [:creator_id] unless CurrentUser.can_view_flagger_on_post?(self)
      attributes
    end
  end

  extend SearchMethods
  include ApiMethods

  def category
    case reason
    when Reasons::UNAPPROVED
      :unapproved
    when /#{Reasons::REJECTED.gsub("%", ".*")}/
      :rejected
    when Reasons::BANNED
      :banned
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

  def not_uploaded_by?(userid)
    uploader_id != userid
  end

  def self.available_includes
    includes_array = [:post]
    includes_array << :creator if CurrentUser.user.is_moderator?
    includes_array
  end
end
