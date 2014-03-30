class ForumTopic < ActiveRecord::Base
  CATEGORIES = {
    0 => "General",
    1 => "Tags",
    2 => "Bugs & Features"
  }

  attr_accessible :title, :original_post_attributes, :category_id, :as => [:member, :builder, :gold, :platinum, :contributor, :janitor, :moderator, :admin, :default]
  attr_accessible :is_sticky, :is_locked, :is_deleted, :as => [:janitor, :admin, :moderator]
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  has_many :posts, :class_name => "ForumPost", :order => "forum_posts.id asc", :foreign_key => "topic_id", :dependent => :destroy
  has_one :original_post, :class_name => "ForumPost", :order => "forum_posts.id asc", :foreign_key => "topic_id"
  before_validation :initialize_creator, :on => :create
  before_validation :initialize_updater
  before_validation :initialize_is_deleted, :on => :create
  validates_presence_of :title, :creator_id
  validates_associated :original_post
  validates_inclusion_of :category_id, :in => CATEGORIES.keys
  accepts_nested_attributes_for :original_post

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

    def search(params)
      q = scoped
      return q if params.blank?

      if params[:title_matches].present?
        q = q.title_matches(params[:title_matches])
      end

      if params[:category_id].present?
        q = q.for_category_id(params[:category_id])
      end

      if params[:title].present?
        q = q.where("title = ?", params[:title])
      end

      q
    end
  end

  extend SearchMethods
  include CategoryMethods

  def editable_by?(user)
    creator_id == user.id || user.is_janitor?
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

  def last_page
    (posts.count / Danbooru.config.posts_per_page.to_f).ceil
  end

  def presenter(forum_posts)
    @presenter ||= ForumTopicPresenter.new(self, forum_posts)
  end
  
  def hidden_attributes
    super + [:text_index]
  end

  def read_by?(user, read_forum_topic_ids)
    return true if updated_at < user.last_forum_read_at
    if read_forum_topic_ids.any? {|topic_id, timestamp| id.to_s == topic_id && updated_at.to_i > timestamp.to_i}
      return false
    end
    if read_forum_topic_ids.any? {|topic_id, timestamp| id.to_s == topic_id && updated_at.to_i <= timestamp.to_i}
      return true
    end
    return false if user.last_forum_read_at.nil?
    return false
  end

  def mark_as_read(read_forum_topic_ids)
    hash = read_forum_topic_ids.inject({}) do |hash, x|
      hash[x[0].to_s] = x[1].to_s
      hash
    end
    hash[id.to_s] = updated_at.to_i.to_s
    result = hash.to_a.flatten.join(" ")
    if result.size > 3000
      ids = result.scan(/\S+/)
      result = ids[(ids.size / 2)..-1].join(" ")
    end
    update_last_forum_read_at(hash.keys)
    result
  end

  def update_last_forum_read_at(read_forum_topic_ids)
    query = ForumTopic.scoped
    if CurrentUser.user.last_forum_read_at.present?
      query = query.where("updated_at >= ?", CurrentUser.last_forum_read_at)
    end
    if read_forum_topic_ids.any?
      query = query.where("id not in (?)", read_forum_topic_ids)
    end
    query = query.order("updated_at asc")
    topic = query.first
    if topic
      CurrentUser.user.update_attribute(:last_forum_read_at, topic.updated_at)
    else
      CurrentUser.user.update_attribute(:last_forum_read_at, Time.now)
    end
  end

  def merge(topic)
    ForumPost.update_all({:topic_id => id}, :id => topic.posts.map(&:id))
    update_attribute(:is_deleted, true)
  end
end
