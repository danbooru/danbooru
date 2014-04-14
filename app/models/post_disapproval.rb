class PostDisapproval < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  validates_uniqueness_of :post_id, :scope => [:user_id], :message => "have already hidden this post"
  attr_accessible :post_id, :post, :user_id, :user

  def self.prune!
    joins(:post).where("posts.is_pending = FALSE AND posts.is_flagged = FALSE").each do |post_disapproval|
      post_disapproval.destroy
    end
  end
end
