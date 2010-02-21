class ForumPost < ActiveRecord::Base
  attr_accessible :body, :topic_id
  belongs_to :creator, :class_name => "User"
  belongs_to :topic, :class_name => "ForumTopic"
  after_save :update_topic_updated_at
  validates_presence_of :body, :topic_id, :creator_id
  scope :search_body, lambda {|body| where(["text_index @@ plainto_tsquery(?)", body])}
  
  def update_topic_updated_at
    topic.touch
  end
end
