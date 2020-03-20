class ForumUpdater
  attr_reader :forum_topic, :forum_post

  def initialize(forum_topic, options = {})
    @forum_topic = forum_topic
    @forum_post = options[:forum_post]
  end

  def update(message)
    return if forum_topic.nil?

    CurrentUser.scoped(User.system) do
      create_response(message)

      if forum_post
        update_post(message)
      end
    end
  end

  def create_response(body)
    forum_topic.forum_posts.create(body: body, skip_mention_notifications: true, creator: User.system)
  end

  def update_post(body)
    forum_post.update(body: "#{forum_post.body}\n\nEDIT: #{body}", skip_mention_notifications: true)
  end
end
