class ForumTopicVisit < ApplicationRecord
  belongs_to :user
  belongs_to :forum_topic

  def self.prune!(user)
    where("user_id = ? and last_read_at < ?", user.id, user.last_forum_read_at).delete_all
  end
end
