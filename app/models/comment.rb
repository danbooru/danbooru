class Comment < ActiveRecord::Base
  validate :validate_creator_is_not_limited
  validates_format_of :body, :with => /\S/, :message => 'has no content'
  belongs_to :post
  belongs_to :creator, :class_name => "User"
  has_many :votes, :class_name => "CommentVote", :dependent => :destroy
  before_validation :initialize_creator, :on => :create
  after_save :update_last_commented_at
  attr_accessible :body, :post_id
  attr_accessor :do_not_bump_post
  
  scope :recent, :order => "comments.id desc", :limit => 6
  scope :body_matches, lambda {|query| where("body_index @@ plainto_tsquery(?)", query).order("comments.id DESC")}
  scope :hidden, lambda {|user| where("score < ?", user.comment_threshold)}
  scope :visible, lambda {|user| where("score >= ?", user.comment_threshold)}
  scope :post_tag_match, lambda {|query| joins(:post).where("posts.tag_index @@ to_tsquery('danbooru', ?)", query)}
  scope :for_user, lambda {|user_id| where("creator_id = ?", user_id)}
  
  search_methods :body_matches, :post_tag_match

  def initialize_creator
    self.creator_id = CurrentUser.user.id
    self.ip_addr = CurrentUser.ip_addr
  end

  def creator_name
    User.id_to_name(creator_id)
  end

  def validate_creator_is_not_limited
    creator.is_privileged? || Comment.where("creator_id = ? AND created_at >= ?", creator_id, 1.hour.ago).count < 5
  end

  def update_last_commented_at
    if Comment.where(["post_id = ?", post_id]).count <= Danbooru.config.comment_threshold && !do_not_bump_post
      execute_sql("UPDATE posts SET last_commented_at = ? WHERE id = ?", created_at, post_id)
    end
  end
  
  def vote!(score)
    vote = votes.create(:score => score)
    
    if vote.errors.any?
      raise CommentVote::Error.new(vote.errors.full_messages.join("; "))
    elsif vote.is_positive?
      increment!(:score)
    elsif vote.is_negative?
      decrement!(:score)
    end
  end
  
  def creator_name
    creator.name
  end
end

Comment.connection.extend(PostgresExtensions)
