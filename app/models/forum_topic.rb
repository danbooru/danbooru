class ForumTopic < ActiveRecord::Base
  attr_accessible :title, :original_post_attributes, :as => [:member, :builder, :gold, :platinum, :contributor, :janitor, :moderator, :admin, :default]
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
  accepts_nested_attributes_for :original_post

  module SearchMethods
    def title_matches(title)
      where("text_index @@ plainto_tsquery(E?)", title.to_escaped_for_tsquery_split)
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

      if params[:title].present?
        q = q.where("title = ?", params[:title])
      end

      q
    end
  end

  extend SearchMethods

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
end
