class DiscordNotificationJob < ApplicationJob
  retry_on Exception, attempts: 0

  def perform(forum_post:)
    forum_post.send_discord_notification
  end
end
