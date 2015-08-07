class PostDisapproval < ActiveRecord::Base
  DELETION_THRESHOLD = 1.month

  belongs_to :post
  belongs_to :user
  validates_uniqueness_of :post_id, :scope => [:user_id], :message => "have already hidden this post"
  attr_accessible :post_id, :post, :user_id, :user, :reason, :message
  validates_inclusion_of :reason, :in => %w(legacy breaks_rules poor_quality disinterest)

  scope :with_message, lambda {where("message is not null and message <> ''")}
  scope :breaks_rules, lambda {where(:reason => "breaks_rules")}
  scope :poor_quality, lambda {where(:reason => "poor_quality")}
  scope :disinterest, lambda {where(:reason => ["disinterest", "legacy"])}

  def self.prune!
    PostDisapproval.destroy_all(["created_at < ?", DELETION_THRESHOLD.ago])
  end

  def self.dmail_messages!
    admin = User.admins.first
    disapprovals = {}

    PostDisapproval.with_message.where("created_at >= ?", 1.day.ago).find_each do |disapproval|
      disapprovals[disapproval.post.uploader_id] ||= []
      disapprovals[disapproval.post.uploader_id] << disapproval
    end

    disapprovals.each do |user_id, list|
      user = User.find(user_id)
      CurrentUser.scoped(admin, "127.0.0.1") do
        message = list.map do |x|
          "* post ##{x.post_id}: #{x.message}"
        end.join("\n")

        Dmail.create_split(
          :to_id => user.id,
          :title => "Some of your uploads have been critiqued by the moderators",
          :body => message
        )
      end
    end
  end

  def create_downvote
    if %w(breaks_rules poor_quality).include?(reason)
      PostVote.create(:score => -1, :post_id => post_id)
    end
  end
end
