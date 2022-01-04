# frozen_string_literal: true

# A job that sends notifications about new forum posts to Discord. Spawned by
# the {ForumPost} class when a new forum post is created.
class DiscordNotificationJob < ApplicationJob
  def perform(forum_post:)
    forum_post.send_discord_notification
  end
end
