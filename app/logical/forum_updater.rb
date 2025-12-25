# frozen_string_literal: true

# Add a post to a forum topic.
class ForumUpdater
  attr_reader :forum_topic

  def initialize(forum_topic)
    @forum_topic = forum_topic
  end

  def update(message)
    forum_topic.forum_posts.create(body: message, skip_mention_notifications: true, creator: User.system)
  end
end
