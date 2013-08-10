class PostFlag < ActiveRecord::Base
  class Error < Exception ; end

  belongs_to :creator, :class_name => "User"
  belongs_to :post
  validates_presence_of :reason, :creator_id, :creator_ip_addr
  validate :validate_creator_is_not_limited
  validate :validate_post_is_active
  before_validation :initialize_creator, :on => :create
  validates_uniqueness_of :creator_id, :scope => :post_id, :message => "have already flagged this post"
  before_save :update_post

  module SearchMethods
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
      q = scoped
      return q if params.blank?

      if params[:creator_id].present?
        q = q.where("creator_id = ?", params[:creator_id].to_i)
      end

      if params[:creator_name].present?
        q = q.where("creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].mb_chars.downcase.strip.tr(" ", "_"))
      end

      if params[:post_id].present?
        q = q.where("post_id = ?", params[:post_id].to_i)
      end

      if params[:is_resolved] == "true"
        q = q.resolved
      elsif params[:is_resolved] == "false"
        q = q.unresolved
      end

      case params[:category]
      when "normal"
        q = q.where("reason != ? and reason != ?", "Unapproved in three days", "Artist requested removal")
      when "unapproved"
        q = q.where("reason = ?", "Unapproved in three days")
      when "banned"
        q = q.where("reason = ?", "Artist requested removal")
      end

      q
    end
  end

  extend SearchMethods

  def update_post
    post.update_column(:is_flagged, true) unless post.is_flagged?
  end

  def validate_creator_is_not_limited
    if CurrentUser.is_janitor?
      # do nothing
    elsif creator.created_at > 1.week.ago
      errors[:creator] << "cannot flag within the first week of sign up"
    elsif creator.is_gold? && flag_count_for_creator >= 10
      errors[:creator] << "can flag 10 posts a day"
    elsif !creator.is_gold? && flag_count_for_creator >= 1
      errors[:creator] << "can flag 1 post a day"
    end
  end

  def validate_post_is_active
    if post.is_deleted?
      errors[:post] << "is deleted"
    end
  end

  def initialize_creator
    self.creator_id = CurrentUser.id
    self.creator_ip_addr = CurrentUser.ip_addr
  end

  def resolve!
    update_column(:is_resolved, true)
  end

  def flag_count_for_creator
    PostFlag.where(:creator_id => creator_id).recent.count
  end
end
