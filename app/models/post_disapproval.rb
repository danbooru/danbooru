class PostDisapproval < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  validates_uniqueness_of :post_id, :scope => [:user_id]
  
  def self.prune!
    joins(:post).where("posts.is_pending = FALSE AND posts.is_flagged = FALSE").select("post_disapprovals.*").each do |post_disapproval|
      post_disapproval.destroy
    end
  end
end
