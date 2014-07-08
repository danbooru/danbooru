class ForumTopicVisit < ActiveRecord::Base
  def self.check!(user, topic)
    match = where(:user_id => user.id, :forum_topic_id => topic.id).first
    result = false
    if match
      if match.last_read_at < topic.updated_at
        result = true
      end
      match.update_attribute(:last_read_at, topic.updated_at)
    else
      create(:user_id => user.id, :forum_topic_id => topic.id, :last_read_at => topic.updated_at)
    end
    result
  end

  def self.check_list!(user, topics)
    matches = where(:user_id => user.id, :forum_topic_id => topics.map(&:id)).to_a.inject({}) do |hash, x|
      hash[x.forum_topic_id] = x
      hash
    end
    topics.each do |topic|
      if matches[topic.id]
        matches[topic.id].update_attribute(:last_read_at, topic.updated_at)
      else
        create(:user_id => user.id,, :forum_topic_id => topic.id, :last_read_at => topic.updated_at)
      end
    end
    matches
  end
end
