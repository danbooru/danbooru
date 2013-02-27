class Comment < ActiveRecord::Base
  validate :validate_creator_is_not_limited
  validates_format_of :body, :with => /\S/, :message => 'has no content'
  belongs_to :post
  belongs_to :creator, :class_name => "User"
  has_many :votes, :class_name => "CommentVote", :dependent => :destroy
  before_validation :initialize_creator, :on => :create
  after_save :update_last_commented_at
  after_destroy :update_last_commented_at
  attr_accessible :body, :post_id, :do_not_bump_post
  attr_accessor :do_not_bump_post
  
  module SearchMethods
    def recent
      reorder("comments.id desc").limit(6)
    end
    
    def body_matches(query)
      where("body_index @@ plainto_tsquery(?)", query).order("comments.id DESC")
    end
    
    def hidden(user)
      where("score < ?", user.comment_threshold)
    end
    
    def visible(user)
      where("score >= ?", user.comment_threshold)
    end
    
    def post_tags_match(query)
      joins(:post).where("posts.tag_index @@ to_tsquery('danbooru', ?)", query)
    end
    
    def for_creator(user_id)
      where("creator_id = ?", user_id)
    end
    
    def for_creator_name(user_name)
      where("creator_id = (select _.id from users _ where lower(_.name) = lower(?))", user_name.downcase)
    end
    
    def search(params)
      q = scoped
      return q if params.blank?
      
      if params[:body_matches].present?
        q = q.body_matches(params[:body_matches])
      end
      
      if params[:post_tags_match].present?
        q = q.post_tags_match(params[:post_tags_match])
      end
      
      if params[:creator_name].present?
        q = q.for_creator_name(params[:creator_name])
      end
      
      if params[:creator_id].present?
        q = q.for_creator(params[:creator_id].to_i)
      end
      
      q
    end
  end
  
  extend SearchMethods
  
  def initialize_creator
    self.creator_id = CurrentUser.user.id
    self.ip_addr = CurrentUser.ip_addr
  end

  def creator_name
    User.id_to_name(creator_id)
  end

  def validate_creator_is_not_limited
    if creator.can_comment?
      true
    else
      errors.add(:creator, "can not post comments within 1 week of sign up, and can only post #{Danbooru.config.member_comment_limit} comments per hour after that")
      false
    end
  end

  def update_last_commented_at
    puts Comment.where("post_id = ?", post_id).count
    puts !do_not_bump_post?
    if Comment.where("post_id = ?", post_id).count == 0
      Post.update_all("last_commented_at = NULL", ["id = ?", post_id])
    elsif Comment.where("post_id = ?", post_id).count <= Danbooru.config.comment_threshold && !do_not_bump_post?
      Post.update_all(["last_commented_at = ?", created_at], ["id = ?", post_id])
    end
  end
  
  def do_not_bump_post?
    do_not_bump_post == "1"
  end
  
  def vote!(score)
    numerical_score = score == "up" ? 1 : -1
    vote = votes.create(:score => numerical_score)
    
    if vote.errors.empty?
      if vote.is_positive?
        increment!(:score)
      elsif vote.is_negative?
        decrement!(:score)
      end
    end

    return vote
  end
  
  def editable_by?(user)
    creator_id == user.id || user.is_moderator?
  end
end

Comment.connection.extend(PostgresExtensions)
