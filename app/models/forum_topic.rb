class ForumTopic < ApplicationRecord
  CATEGORIES = {
    0 => "General",
    1 => "Tags",
    2 => "Bugs & Features"
  }

  MIN_LEVELS = {
    None: 0,
    Moderator: User::Levels::MODERATOR,
    Admin: User::Levels::ADMIN,
  }

  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  has_many :posts, lambda {order("forum_posts.id asc")}, :class_name => "ForumPost", :foreign_key => "topic_id", :dependent => :destroy
  has_one :original_post, lambda {order("forum_posts.id asc")}, :class_name => "ForumPost", :foreign_key => "topic_id"
  has_many :subscriptions, :class_name => "ForumSubscription"
  before_validation :initialize_creator, :on => :create
  before_validation :initialize_updater
  before_validation :initialize_is_deleted, :on => :create
  validates_presence_of :title, :creator_id
  validates_associated :original_post
  validates_inclusion_of :category_id, :in => CATEGORIES.keys
  validates_inclusion_of :min_level, :in => MIN_LEVELS.values
  validates :title, :length => {:maximum => 255}
  accepts_nested_attributes_for :original_post
  after_update :update_orignal_post
  after_save(:if => lambda {|rec| rec.is_locked? && rec.is_locked_changed?}) do |rec|
    ModAction.log("locked forum topic ##{id} (title: #{title})",:forum_topic_lock)
  end

  module CategoryMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def categories
        CATEGORIES.values
      end

      def reverse_category_mapping
        @reverse_category_mapping ||= CATEGORIES.invert
      end

      def for_category_id(cid)
        where(:category_id => cid)
      end
    end

    def category_name
      CATEGORIES[category_id]
    end
  end

  module SearchMethods
    def title_matches(title)
      if title =~ /\*/ && CurrentUser.user.is_builder?
        where("title ILIKE ? ESCAPE E'\\\\'", title.to_escaped_for_sql_like)
      else
        where("text_index @@ plainto_tsquery(E?)", title.to_escaped_for_tsquery_split)
      end
    end

    def active
      where("is_deleted = false")
    end

    def permitted
      where("min_level <= ?", CurrentUser.level)
    end

    def sticky_first
      order(is_sticky: :desc, updated_at: :desc)
    end

    def default_order
      order(updated_at: :desc)
    end

    def search(params)
      q = super
      q = q.permitted

      if params[:mod_only].present?
        q = q.where("min_level >= ?", MIN_LEVELS[:Moderator])
      end

      if params[:title_matches].present?
        q = q.title_matches(params[:title_matches])
      end

      if params[:category_id].present?
        q = q.for_category_id(params[:category_id])
      end

      if params[:title].present?
        q = q.where("title = ?", params[:title])
      end

      case params[:order]
      when "sticky"
        q = q.sticky_first
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  module VisitMethods
    def read_by?(user = nil)
      user ||= CurrentUser.user

      if user.last_forum_read_at && updated_at <= user.last_forum_read_at
        return true
      end

      ForumTopicVisit.where("user_id = ? and forum_topic_id = ? and last_read_at >= ?", user.id, id, updated_at).exists?
    end

    def mark_as_read!(user = CurrentUser.user)
      return if user.is_anonymous?
      
      match = ForumTopicVisit.where(:user_id => user.id, :forum_topic_id => id).first
      if match
        match.update_attribute(:last_read_at, updated_at)
      else
        ForumTopicVisit.create(:user_id => user.id, :forum_topic_id => id, :last_read_at => updated_at)
      end

      has_unread_topics = ForumTopic.permitted.active.where("forum_topics.updated_at >= ?", user.last_forum_read_at)
      .joins("left join forum_topic_visits on (forum_topic_visits.forum_topic_id = forum_topics.id and forum_topic_visits.user_id = #{user.id})")
      .where("(forum_topic_visits.id is null or forum_topic_visits.last_read_at < forum_topics.updated_at)")
      .exists?
      unless has_unread_topics
        user.update_attribute(:last_forum_read_at, Time.now)
        ForumTopicVisit.prune!(user)
      end
    end
  end

  module SubscriptionMethods
    def user_subscription(user)
      subscriptions.where(:user_id => user.id).first
    end
  end

  extend SearchMethods
  include CategoryMethods
  include VisitMethods
  include SubscriptionMethods

  def editable_by?(user)
    (creator_id == user.id || user.is_moderator?) && visible?(user)
  end

  def visible?(user)
    user.level >= min_level
  end

  def create_mod_action_for_delete
    ModAction.log("deleted forum topic ##{id} (title: #{title})",:forum_topic_delete)
  end

  def create_mod_action_for_undelete
    ModAction.log("undeleted forum topic ##{id} (title: #{title})",:forum_topic_undelete)
  end

  def initialize_is_deleted
    self.is_deleted = false if is_deleted.nil?
  end

  def initialize_creator
    self.creator_id = CurrentUser.id
  end

  def initialize_updater
    self.updater_id = CurrentUser.id
  end

  def page_for(post_id)
    (posts.where("id < ?", post_id).count / Danbooru.config.posts_per_page.to_f).ceil
  end

  def last_page
    (response_count / Danbooru.config.posts_per_page.to_f).ceil
  end

  def as_json(options = {})
    if CurrentUser.user.level < min_level
      options[:only] = [:id]
    end

    super(options)
  end

  def to_xml(options = {})
    if CurrentUser.user.level < min_level
      options[:only] = [:id]
    end

    super(options)
  end

  def hidden_attributes
    super + [:text_index, :min_level]
  end

  def merge(topic)
    ForumPost.where(:id => self.posts.map(&:id)).update_all(:topic_id => topic.id)
    topic.update_attributes(:response_count => topic.response_count + self.posts.length, :updater_id => CurrentUser.id)
    self.update_columns(:response_count => 0, :is_deleted => true, :updater_id => CurrentUser.id)
  end

  def delete!
    update(is_deleted: true)
  end

  def undelete!
    update(is_deleted: false)
  end

  def update_orignal_post
    if original_post
      original_post.update_columns(:updater_id => CurrentUser.id, :updated_at => Time.now)
    end
  end
end
