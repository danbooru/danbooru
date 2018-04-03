class PostFlag < ApplicationRecord
  class Error < Exception ; end

  module Reasons
    UNAPPROVED = "Unapproved in three days"
    REJECTED = "Unapproved in three days after returning to moderation queue%"
    BANNED = "Artist requested removal"
  end

  COOLDOWN_PERIOD = 3.days

  belongs_to :creator, :class_name => "User"
  belongs_to :post
  validates_presence_of :reason, :creator_id, :creator_ip_addr
  validate :validate_creator_is_not_limited
  validate :validate_post
  before_validation :initialize_creator, :on => :create
  validates_uniqueness_of :creator_id, :scope => :post_id, :on => :create, :unless => :is_deletion, :message => "have already flagged this post"
  before_save :update_post
  attr_accessor :is_deletion

  scope :by_users, lambda { where.not(creator: User.system) }
  scope :by_system, lambda { where(creator: User.system) }
  scope :in_cooldown, lambda { by_users.where("created_at >= ?", COOLDOWN_PERIOD.ago) }

  module SearchMethods
    def reason_matches(query)
      if query =~ /\*/
        where("post_flags.reason ILIKE ? ESCAPE E'\\\\'", query.to_escaped_for_sql_like)
      else
        where("to_tsvector('english', post_flags.reason) @@ plainto_tsquery(?)", query.to_escaped_for_tsquery)
      end
    end

    def duplicate
      where("to_tsvector('english', post_flags.reason) @@ to_tsquery('dup | duplicate | sample | smaller')")
    end

    def not_duplicate
      where("to_tsvector('english', post_flags.reason) @@ to_tsquery('!dup & !duplicate & !sample & !smaller')")
    end

    def post_tags_match(query)
      PostQueryBuilder.new(query).build(self.joins(:post))
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

    def for_creator(user_id)
      where("creator_id = ?", user_id)
    end

    def search(params)
      q = super

      if params[:reason_matches].present?
        q = q.reason_matches(params[:reason_matches])
      end

      if params[:creator_id].present?
        if CurrentUser.can_view_flagger?(params[:creator_id].to_i)
          q = q.where.not(post_id: CurrentUser.user.posts)
          q = q.where("creator_id = ?", params[:creator_id].to_i)
        else
          q = q.where("false")
        end
      end

      if params[:creator_name].present?
        flagger_id = User.name_to_id(params[:creator_name].strip)
        if flagger_id && CurrentUser.can_view_flagger?(flagger_id)
          q = q.where.not(post_id: CurrentUser.user.posts)
          q = q.where("creator_id = ?", flagger_id)
        else
          q = q.where("false")
        end
      end

      if params[:post_id].present?
        q = q.where(post_id: params[:post_id].split(",").map(&:to_i))
      end

      if params[:post_tags_match].present?
        q = q.post_tags_match(params[:post_tags_match])
      end

      if params[:is_resolved] == "true"
        q = q.resolved
      elsif params[:is_resolved] == "false"
        q = q.unresolved
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
    def hidden_attributes
      list = super
      unless CurrentUser.can_view_flagger_on_post?(self)
        list += [:creator_id]
      end
      super + list
    end

    def method_attributes
      super + [:category]
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

    if CurrentUser.can_approve_posts?
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

  def initialize_creator
    self.creator_id ||= CurrentUser.id
    self.creator_ip_addr = CurrentUser.ip_addr if creator_ip_addr == "127.0.0.1" || creator_ip_addr.blank?
  end

  def resolve!
    update_column(:is_resolved, true)
  end

  def flag_count_for_creator
    PostFlag.where(:creator_id => creator_id).recent.count
  end

  def uploader_id
    @uploader_id ||= Post.find(post_id).uploader_id
  end

  def not_uploaded_by?(userid)
    uploader_id != userid
  end
end
