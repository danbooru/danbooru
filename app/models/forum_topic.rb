class ForumTopic < ActiveRecord::Base
  attr_accessible :title
  belongs_to :creator, :class_name => "User"
  has_many :posts, :class_name => "ForumPost", :order => "forum_posts.id asc"
  validates_presence_of :title, :creator_id
  scope :search_title, lambda {|title| where(["text_index @@ plainto_tsquery(?)", title])}
  accepts_nested_attributes_for :posts
end
