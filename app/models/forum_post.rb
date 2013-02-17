class ForumPost < ActiveRecord::Base
  attr_accessible :body, :topic_id, :as => [:member, :privileged, :contributor, :janitor, :admin, :moderator, :default]
  attr_accessible :is_locked, :is_sticky, :is_deleted, :as => [:admin, :moderator]
  belongs_to :creator, :class_name => "User"
  belongs_to :topic, :class_name => "ForumTopic"
  before_validation :initialize_creator, :on => :create
  before_validation :initialize_updater
  before_validation :initialize_is_deleted, :on => :create
  after_save :update_topic_updated_at
  validates_presence_of :body, :creator_id
  validate :validate_topic_is_unlocked
  before_destroy :validate_topic_is_unlocked
  
  module SearchMethods
    def body_matches(body)
      where("forum_posts.text_index @@ plainto_tsquery(?)", body)
    end
    
    def for_user(user_id)
      where("forum_posts.creator_id = ?", user_id)
    end
    
    def creator_name(name)
      where("forum_posts.creator_id = (select _.id from users _ where lower(_.name) = ?)", name.downcase)
    end
    
    def active
      where("is_deleted = false")
    end
    
    def search(params)
      q = scoped
      return q if params.blank?
      
      if params[:creator_id]
        q = q.where("creator_id = ?", params[:creator_id].to_i)
      end
      
      if params[:topic_id]
        q = q.where("topic_id = ?", params[:topic_id].to_i)
      end
      
      if params[:topic_title_matches]
        q = q.joins(:topic).where("forum_topics.text_index @@ plainto_tsquery(?)", params[:topic_title_matches])
      end
      
      if params[:body_matches]
        q = q.body_matches(params[:body_matches])
      end
      
      if params[:creator_name]
        q = q.creator_name(params[:creator_name])
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
    return if CurrentUser.is_moderator?
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
  
  def update_topic_updated_at
    if topic
      topic.update_column(:updater_id, CurrentUser.id)
      topic.touch
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
  
  def quoted_response
    "[quote]\n#{body}\n[/quote]\n\n"
  end
  
  def build_response
    dup.tap do |x|
      x.body = x.quoted_response
    end
  end
end
