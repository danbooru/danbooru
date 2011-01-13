class ForumPost < ActiveRecord::Base
  attr_accessible :body, :topic_id
  belongs_to :creator, :class_name => "User"
  belongs_to :topic, :class_name => "ForumTopic"
  before_validation :initialize_creator, :on => :create
  before_validation :initialize_updater
  after_save :update_topic_updated_at
  validates_presence_of :body, :creator_id
  scope :body_matches, lambda {|body| where(["text_index @@ plainto_tsquery(?)", body])}
  search_method :body_matches

  def editable_by?(user)
    creator_id == user.id || user.is_moderator?
  end
  
  def update_topic_updated_at
    topic.update_attributes(:updater_id => CurrentUser.id)
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.id
  end
  
  def initialize_updater
    self.updater_id = CurrentUser.id
  end
end
