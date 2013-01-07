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
  scope :body_matches, lambda {|body| where(["forum_posts.text_index @@ plainto_tsquery(?)", body])}
  scope :for_user, lambda {|user_id| where("forum_posts.creator_id = ?", user_id)}
  scope :active, where("is_deleted = false")
  search_methods :body_matches
  
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
  
  def build_response
    dup.tap do |x|
      x.body = "[quote]\n#{x.body}\n[/quote]\n\n"
    end
  end
end
