class ForumTopic < ApplicationRecord
  CATEGORIES = {
    0 => "General",
    1 => "Tags",
    2 => "Bugs & Features"
  }

  MIN_LEVELS = {
    None: 0,
    Moderator: User::Levels::MODERATOR,
    Admin: User::Levels::ADMIN
  }

  belongs_to :creator, class_name: "User"
  belongs_to_updater
  has_many :forum_posts, foreign_key: "topic_id", dependent: :destroy, inverse_of: :topic
  has_many :forum_topic_visits
  has_one :forum_topic_visit_by_current_user, -> { where(user_id: CurrentUser.id) }, class_name: "ForumTopicVisit"
  has_many :moderation_reports, through: :forum_posts
  has_one :original_post, -> { order(id: :asc) }, class_name: "ForumPost", foreign_key: "topic_id", inverse_of: :topic
  has_many :bulk_update_requests, :foreign_key => "forum_topic_id"
  has_many :tag_aliases, :foreign_key => "forum_topic_id"
  has_many :tag_implications, :foreign_key => "forum_topic_id"

  validates_presence_of :title
  validates_associated :original_post
  validates_inclusion_of :category_id, :in => CATEGORIES.keys
  validates_inclusion_of :min_level, :in => MIN_LEVELS.values
  validates :title, :length => {:maximum => 255}
  accepts_nested_attributes_for :original_post
  after_update :update_orignal_post
  after_save(:if => ->(rec) {rec.is_locked? && rec.saved_change_to_is_locked?}) do |rec|
    ModAction.log("locked forum topic ##{id} (title: #{title})", :forum_topic_lock)
  end

  deletable

  scope :public_only, -> { where(min_level: MIN_LEVELS[:None]) }
  scope :private_only, -> { where.not(min_level: MIN_LEVELS[:None]) }
  scope :pending, -> { where(id: BulkUpdateRequest.has_topic.pending.select(:forum_topic_id)) }
  scope :approved, -> { where(category_id: 1).where(id: BulkUpdateRequest.approved.has_topic.select(:forum_topic_id)).where.not(id: BulkUpdateRequest.has_topic.pending.or(BulkUpdateRequest.has_topic.rejected).select(:forum_topic_id)) }
  scope :rejected, -> { where(category_id: 1).where(id: BulkUpdateRequest.rejected.has_topic.select(:forum_topic_id)).where.not(id: BulkUpdateRequest.has_topic.pending.or(BulkUpdateRequest.has_topic.approved).select(:forum_topic_id)) }

  module CategoryMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def categories
        CATEGORIES.values
      end

      def reverse_category_mapping
        @reverse_category_mapping ||= CATEGORIES.invert
      end
    end

    def category_name
      CATEGORIES[category_id]
    end
  end

  module SearchMethods
    def visible(user)
      where("min_level <= ?", user.level)
    end

    def read_by_user(user)
      last_forum_read_at = user.last_forum_read_at || "2000-01-01".to_time

      read_topics = user.visited_forum_topics.where("forum_topic_visits.last_read_at >= forum_topics.updated_at")
      old_topics = where("? >= forum_topics.updated_at", last_forum_read_at)

      where(id: read_topics).or(where(id: old_topics))
    end

    def unread_by_user(user)
      where.not(id: ForumTopic.read_by_user(user))
    end

    def sticky_first
      order(is_sticky: :desc, updated_at: :desc)
    end

    def default_order
      order(updated_at: :desc)
    end

    def search(params)
      q = super
      q = q.search_attributes(params, :is_sticky, :is_locked, :is_deleted, :category_id, :title, :response_count)
      q = q.text_attribute_matches(:title, params[:title_matches], index_column: :text_index)

      if params[:is_private].to_s.truthy?
        q = q.private_only
      elsif params[:is_private].to_s.falsy?
        q = q.public_only
      end

      if params[:status] == "pending"
        q = q.pending
      elsif params[:status] == "approved"
        q = q.approved
      elsif params[:status] == "rejected"
        q = q.rejected
      end

      if params[:is_read].to_s.truthy?
        q = q.read_by_user(CurrentUser.user)
      elsif params[:is_read].to_s.falsy?
        q = q.unread_by_user(CurrentUser.user)
      end

      case params[:order]
      when "sticky"
        q = q.sticky_first
      when "id"
        q = q.order(id: :desc)
      else
        q = q.apply_default_order(params)
      end

      unless params[:is_deleted].present?
        q = q.active
      end

      q
    end
  end

  module VisitMethods
    def mark_as_read!(user = CurrentUser.user)
      return if user.is_anonymous?

      match = ForumTopicVisit.where(:user_id => user.id, :forum_topic_id => id).first
      if match
        match.update_attribute(:last_read_at, updated_at)
      else
        ForumTopicVisit.create(:user_id => user.id, :forum_topic_id => id, :last_read_at => updated_at)
      end

      unread_topics = ForumTopic.visible(user).active.unread_by_user(user)

      if !unread_topics.exists?
        user.update!(last_forum_read_at: Time.zone.now)
        ForumTopicVisit.prune!(user)
      end
    end
  end

  extend SearchMethods
  include CategoryMethods
  include VisitMethods

  # XXX forum_topic_visit_by_current_user is a hack to reduce queries on the forum index.
  def is_read?
    return true if CurrentUser.is_anonymous?
    return true if new_record?

    topic_last_read_at = forum_topic_visit_by_current_user&.last_read_at || "2000-01-01".to_time
    forum_last_read_at = CurrentUser.last_forum_read_at || "2000-01-01".to_time

    (topic_last_read_at >= updated_at) || (forum_last_read_at >= updated_at)
  end

  def is_private?
    min_level > MIN_LEVELS[:None]
  end

  def create_mod_action_for_delete
    ModAction.log("deleted forum topic ##{id} (title: #{title})", :forum_topic_delete)
  end

  def create_mod_action_for_undelete
    ModAction.log("undeleted forum topic ##{id} (title: #{title})", :forum_topic_undelete)
  end

  def page_for(post_id)
    (forum_posts.where("id < ?", post_id).count / Danbooru.config.posts_per_page.to_f).ceil
  end

  def last_page
    (response_count / Danbooru.config.posts_per_page.to_f).ceil
  end

  def update_orignal_post
    original_post&.update_columns(:updater_id => updater.id, :updated_at => Time.now)
  end

  def pretty_title
    title.gsub(/\A\[APPROVED\]|\[REJECTED\]/, "")
  end

  def self.searchable_includes
    [:creator, :updater, :forum_posts, :bulk_update_requests, :tag_aliases, :tag_implications]
  end

  def self.available_includes
    [:creator, :updater, :original_post]
  end
end
