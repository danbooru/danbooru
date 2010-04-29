class PostVote < ActiveRecord::Base
  class Error < Exception ; end
  
  attr_accessor :is_positive
  validates_uniqueness_of :ip_addr, :scope => :post_id
  after_save :update_post_score
  belongs_to :post
  
  def update_post_score
    if is_positive
      post.increment!(:score)
    else
      post.decrement!(:score)
    end
  end
end
