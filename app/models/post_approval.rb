class PostApproval < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  def self.prune!
    where("created_at < ?", 1.month.ago).delete_all
  end

  def self.approved?(user_id, post_id)
    where(user_id: user_id, post_id: post_id).exists?
  end
end
