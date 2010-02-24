class Comment < ActiveRecord::Base  
  validates_format_of :body, :with => /\S/, :message => 'has no content'
  belongs_to :post
  belongs_to :creator, :class_name => "User"
  has_many :votes, :class_name => "CommentVote", :dependent => :destroy
  after_save :update_last_commented_at
  after_destroy :update_last_commented_at
  attr_accessible :body
  attr_accessor :do_not_bump_post
  
  scope :recent, :order => "comments.id desc", :limit => 6
  scope :search_body, lambda {|query| where("body_index @@ plainto_tsquery(?)", query)}
  scope :hidden, lambda {|user| where("score < ?", user.comment_threshold)}

  def update_last_commented_at
    return if do_not_bump_post    
    comment_count = Comment.where(["post_id = ?", post_id]).count    
    if comment_count <= Danbooru.config.comment_threshold
      execute_sql("UPDATE posts SET last_commented_at = ? WHERE id = ?", created_at, post_id)
    end
  end

  def can_be_voted_by?(user)
    !votes.exists?(["user_id = ?", user.id])
  end
  
  def vote!(user, is_positive)
    if can_be_voted_by?(user)
      if is_positive
        increment!(:score)
      else
        decrement!(:score)
      end
      
      votes.create(:user_id => user.id)
    else
      raise CommentVote::Error.new("You have already voted for this comment")
    end
  end
end
