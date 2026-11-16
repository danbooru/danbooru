# frozen_string_literal: true

class ForumTopicVisit < ApplicationRecord
  belongs_to :user
  belongs_to :forum_topic

  def self.prune!(user)
    where("user_id = ? and last_read_at < ?", user.id, user.last_forum_read_at).delete_all
  end

  def self.search(params, current_user)
    q = search_attributes(params, current_user: current_user)
    q.apply_default_order(params)
  end

  def self.available_includes
    [:forum_topic]
  end
end
