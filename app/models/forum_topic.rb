class ForumTopic < ActiveRecord::Base
  attr_accessible :title, :original_post_attributes
  attr_accessible :is_sticky, :is_locked, :as => :janitor
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  has_many :posts, :class_name => "ForumPost", :order => "forum_posts.id asc", :foreign_key => "topic_id", :dependent => :destroy
  has_one :original_post, :class_name => "ForumPost", :order => "forum_posts.id asc", :foreign_key => "topic_id"
  before_validation :initialize_creator, :on => :create
  before_validation :initialize_updater
  validates_presence_of :title, :creator_id
  validates_associated :original_post
  scope :title_matches, lambda {|title| where(["text_index @@ plainto_tsquery(?)", title])}
  search_methods :title_matches
  accepts_nested_attributes_for :original_post
    
  def editable_by?(user)
    creator_id == user.id || user.is_moderator?
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
end
