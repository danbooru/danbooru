class ForumPost < ActiveRecord::Base
  attr_accessible :body, :topic_id, :as => [:member, :builder, :janitor, :gold, :platinum, :contributor, :admin, :moderator, :default]
  attr_accessible :is_locked, :is_sticky, :is_deleted, :as => [:admin, :moderator, :janitor]
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  belongs_to :topic, :class_name => "ForumTopic"
  before_validation :initialize_creator, :on => :create
  before_validation :initialize_updater
  before_validation :initialize_is_deleted, :on => :create
  after_create :update_topic_updated_at_on_create
  after_update :update_topic_updated_at_on_update_for_original_posts
  after_destroy :update_topic_updated_at_on_destroy
  validates_presence_of :body, :creator_id
  validate :validate_topic_is_unlocked
  before_destroy :validate_topic_is_unlocked
  after_save :delete_topic_if_original_post

  module SearchMethods
    def body_matches(body)
      if body =~ /\*/ && CurrentUser.user.is_builder?
        where("forum_posts.body ILIKE ? ESCAPE E'\\\\'", body.to_escaped_for_sql_like)
      else
        where("forum_posts.text_index @@ plainto_tsquery(E?)", body.to_escaped_for_tsquery)
      end
    end

    def for_user(user_id)
      where("forum_posts.creator_id = ?", user_id)
    end

    def creator_name(name)
      where("forum_posts.creator_id = (select _.id from users _ where lower(_.name) = ?)", name.mb_chars.downcase)
    end

    def active
      where("forum_posts.is_deleted = false")
    end

    def search(params)
      q = scoped
      return q if params.blank?

      if params[:creator_id].present?
        q = q.where("creator_id = ?", params[:creator_id].to_i)
      end

      if params[:topic_id].present?
        q = q.where("topic_id = ?", params[:topic_id].to_i)
      end

      if params[:topic_title_matches].present?
        q = q.joins(:topic).where("forum_topics.text_index @@ plainto_tsquery(E?)", params[:topic_title_matches].to_escaped_for_tsquery_split)
      end

      if params[:body_matches].present?
        q = q.body_matches(params[:body_matches])
      end

      if params[:creator_name].present?
        q = q.creator_name(params[:creator_name].tr(" ", "_"))
      end

      if params[:topic_category_id].present?
        q = q.joins(:topic).where("forum_topics.category_id = ?", params[:topic_category_id].to_i)
      end

      q
    end
  end

  extend SearchMethods

  def self.new_reply(params)
    if params[:topic_id]
      new(:topic_id => params[:topic_id])
    elsif params[:post_id]
      forum_post = ForumPost.find(params[:post_id])
      forum_post.build_response
    else
      new
    end
  end

  def validate_topic_is_unlocked
    return if CurrentUser.is_janitor?
    return if topic.nil?

    if topic.is_locked?
      errors.add(:topic, "is locked")
      return false
    else
      return true
    end
  end

  def editable_by?(user)
    creator_id == user.id || user.is_janitor?
  end

  def update_topic_updated_at_on_create
    if topic
      # need to do this to bypass the topic's original post from getting touched
      ForumTopic.update_all(["updater_id = ?, response_count = response_count + 1, updated_at = ?", CurrentUser.id, Time.now], {:id => topic.id})
    end
  end

  def update_topic_updated_at_on_update_for_original_posts
    if is_original_post?
      topic.touch
    end
  end

  def update_topic_updated_at_on_destroy
    max = ForumPost.where(:topic_id => topic.id).maximum(:updated_at)
    if max
      ForumTopic.update_all(["response_count = response_count - 1, updated_at = ?", max], {:id => topic.id})
    else
      ForumTopic.update_all(["response_count = response_count - 1"], {:id => topic.id})
    end
  end

  def initialize_creator
    self.creator_id = CurrentUser.id
  end

  def initialize_updater
    self.updater_id = CurrentUser.id
  end

  def initialize_is_deleted
    self.is_deleted = false if is_deleted.nil?
  end

  def creator_name
    User.id_to_name(creator_id)
  end

  def updater_name
    User.id_to_name(updater_id)
  end

  def quoted_response
    stripped_body = body.gsub(/\[quote\](?:.|\n|\r)+?\[\/quote\][\n\r]*/m, "")
    "[quote]\n#{creator_name} said:\n\n#{stripped_body}\n[/quote]\n\n"
  end

  def forum_topic_page
    ((ForumPost.where("topic_id = ? and created_at <= ?", topic_id, created_at).count) / Danbooru.config.posts_per_page.to_f).ceil
  end

  def is_original_post?
    ForumPost.exists?(["id = ? and id = (select _.id from forum_posts _ where _.topic_id = ? order by _.id asc limit 1)", id, topic_id])
  end

  def delete_topic_if_original_post
    if is_deleted? && is_original_post?
      topic.update_attribute(:is_deleted, true)
    end

    true
  end

  def build_response
    dup.tap do |x|
      x.body = x.quoted_response
    end
  end

  def hidden_attributes
    super + [:text_index]
  end
end
