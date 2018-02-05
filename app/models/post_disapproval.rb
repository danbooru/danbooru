class PostDisapproval < ApplicationRecord
  DELETION_THRESHOLD = 1.month

  belongs_to :post, required: true
  belongs_to :user
  after_initialize :initialize_attributes, if: :new_record?
  validates_uniqueness_of :post_id, :scope => [:user_id], :message => "have already hidden this post"
  validates_inclusion_of :reason, :in => %w(legacy breaks_rules poor_quality disinterest)

  scope :with_message, lambda {where("message is not null and message <> ''")}
  scope :breaks_rules, lambda {where(:reason => "breaks_rules")}
  scope :poor_quality, lambda {where(:reason => "poor_quality")}
  scope :disinterest, lambda {where(:reason => ["disinterest", "legacy"])}

  def initialize_attributes
    self.user_id ||= CurrentUser.user.id
  end

  def self.prune!
    PostDisapproval.where("post_id in (select _.post_id from post_disapprovals _ where _.created_at < ?)", DELETION_THRESHOLD.ago).delete_all
  end

  def self.dmail_messages!
    disapprovals = PostDisapproval.with_message.where("created_at >= ?", 1.day.ago).group_by do |pd|
      pd.post.uploader
    end

    disapprovals.each do |uploader, list|
      message = list.map do |x|
        "* post ##{x.post_id}: #{x.message}"
      end.join("\n")

      Dmail.create_automated(
        :to_id => uploader.id,
        :title => "Someone has commented on your uploads",
        :body => message
      )
    end
  end

  def create_downvote
    if %w(breaks_rules poor_quality).include?(reason)
      PostVote.create(:score => -1, :post_id => post_id)
    end
  end
end
