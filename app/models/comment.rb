class Comment < ActiveRecord::Base
  validate :validate_creator_is_not_limited
  validates_format_of :body, :with => /\S/, :message => 'has no content'
  belongs_to :post
  belongs_to :creator, :class_name => "User"
  has_many :votes, :class_name => "CommentVote", :dependent => :destroy
  after_save :update_last_commented_at
  after_destroy :update_last_commented_at
  attr_accessible :body
  
  scope :recent, :order => "comments.id desc", :limit => 6
  scope :search_body, lambda {|query| where("body_index @@ plainto_tsquery(?)", query).order("comments.id DESC")}
  scope :hidden, lambda {|user| where("score < ?", user.comment_threshold)}

  def creator_name
    User.find_name(creator_id)
  end

  def validate_creator_is_not_limited
    creator.is_privileged? || Comment.where("creator_id = ? AND created_at >= ?", creator_id, 1.hour.ago).count < 5
  end

  def update_last_commented_at
    if Comment.where(["post_id = ?", post_id]).count <= Danbooru.config.comment_threshold
      execute_sql("UPDATE posts SET last_commented_at = ? WHERE id = ?", created_at, post_id)
    end
  end
end

Comment.connection.extend(PostgresExtensions)
