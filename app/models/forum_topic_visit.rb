# frozen_string_literal: true

class ForumTopicVisit < ApplicationRecord
  belongs_to :user
  belongs_to :forum_topic

  def self.visible(user)
    if user.is_owner?
      all
    else
      where(user: user)
    end
  end

  def self.prune!(user)
    where("user_id = ? and last_read_at < ?", user.id, user.last_forum_read_at).delete_all
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :user, :forum_topic, :last_read_at)
    q.apply_default_order(params)
  end

  def self.available_includes
    [:forum_topic]
  end
end
