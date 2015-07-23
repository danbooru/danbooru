class PostDisapproval < ActiveRecord::Base
  DELETION_THRESHOLD = 1.month

  belongs_to :post
  belongs_to :user
  validates_uniqueness_of :post_id, :scope => [:user_id], :message => "have already hidden this post"
  attr_accessible :post_id, :post, :user_id, :user, :reason
  validates_inclusion_of :reason, :in => %w(legacy breaks_rules poor_quality disinterest)

  scope :breaks_rules, lambda {where(:reason => "breaks_rules")}
  scope :poor_quality, lambda {where(:reason => "poor_quality")}
  scope :disinterest, lambda {where(:reason => ["disinterest", "legacy"])}

  def self.prune!
    PostDisapproval.joins(:post).where("posts.is_pending = FALSE AND posts.is_flagged = FALSE and post_disapprovals.created_at < ?", DELETION_THRESHOLD.ago).each do |post_disapproval|
      post_disapproval.destroy
    end
  end

  def create_downvote
    if %w(breaks_rules poor_quality).include?(reason)
      PostVote.create(:score => -1, :post_id => post_id)
    end
  end
end
