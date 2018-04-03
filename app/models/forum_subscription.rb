class ForumSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :forum_topic

  def self.prune!
    where("last_read_at < ?", 3.months.ago).delete_all
  end

  def self.process_all!
    ForumSubscription.find_each do |subscription|
      forum_topic = subscription.forum_topic
      if forum_topic.updated_at > subscription.last_read_at
        CurrentUser.scoped(subscription.user, "127.0.0.1") do
          forum_posts = forum_topic.posts.where("created_at > ?", subscription.last_read_at).order("id desc")
          begin
            UserMailer.forum_notice(subscription.user, forum_topic, forum_posts).deliver_now
          rescue Net::SMTPSyntaxError
          end
          subscription.update_attribute(:last_read_at, forum_topic.updated_at)
        end
      end
    end
  end
end
