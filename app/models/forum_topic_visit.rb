class ForumTopicVisit < ApplicationRecord
  belongs_to :user
  belongs_to :forum_topic

  def self.prune!(user)
    where("user_id = ? and last_read_at < ?", user.id, user.last_forum_read_at).delete_all
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :user, :forum_topic_id, :last_read_at)
    q.apply_default_order(params)
  end
end
