class ForumTopicVisit < ActiveRecord::Base
  belongs_to :user
  belongs_to :forum_topic
  attr_accessible :user_id, :user, :forum_topic_id, :forum_topic, :last_read_at

  def self.prune!(user)
    where("last_read_at < ?", user.last_forum_read_at).delete_all
  end
end
