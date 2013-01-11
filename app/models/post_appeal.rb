class PostAppeal < ActiveRecord::Base
  class Error < Exception ; end
  
  belongs_to :creator, :class_name => "User"
  belongs_to :post
  validates_presence_of :reason, :creator_id, :creator_ip_addr
  validate :validate_post_is_inactive
  validate :validate_creator_is_not_limited
  before_validation :initialize_creator, :on => :create
  validates_uniqueness_of :creator_id, :scope => :post_id, :message => "have already appealed this post"
  
  module SearchMethods
    def for_user(user_id)
      where("creator_id = ?", user_id)
    end
    
    def recent
      where("created_at >= ?", 1.day.ago)
    end
    
    def search(params)
      q = scoped
      return q if params.blank?
      
      if params[:creator_id]
        q = q.for_user(params[:creator_id].to_i)
      end
      
      if params[:creator_name]
        q = q.where("creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].downcase)
      end
      
      if params[:post_id]
        q = q.where("post_id = ?", params[:post_id].to_i)
      end
      
      q
    end
  end
  
  extend SearchMethods
  
  def validate_creator_is_not_limited
    if appeal_count_for_creator >= Danbooru.config.max_appeals_per_day
      errors[:creator] << "can appeal at most #{Danbooru.config.max_appeals_per_day} post a day"
      false
    else
      true
    end
  end
  
  def validate_post_is_inactive
    if !post.is_deleted? && !post.is_flagged?
      errors[:post] << "is active"
      false
    else
      true
    end
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.id
    self.creator_ip_addr = CurrentUser.ip_addr
  end
  
  def appeal_count_for_creator
    PostAppeal.for_user(creator_id).recent.count
  end
end
