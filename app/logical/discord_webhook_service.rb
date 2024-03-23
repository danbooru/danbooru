# frozen_string_literal: true

# Used for posting notifications to Discord about new forum posts.
# https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks

class DiscordWebhookService
  attr_reader :webhook_id, :webhook_secret, :http

  def initialize(webhook_id: Danbooru.config.discord_webhook_id, webhook_secret: Danbooru.config.discord_webhook_secret, http: Danbooru::Http.external)
    @webhook_id = webhook_id
    @webhook_secret = webhook_secret
    @http = http
  end

  def enabled?
    webhook_id.present? && webhook_secret.present?
  end

  # https://discord.com/developers/docs/resources/webhook#execute-webhook
  def post_message(forum_post)
    return unless enabled?

    http.post(webhook_url, params: { wait: true }, json: build_message(forum_post))
  end

  # https://discord.com/developers/docs/resources/channel#embed-object
  def build_message(forum_post)
    {
      embeds: [{
        title: forum_post.topic.title,
        description: convert_dtext(forum_post.body),
        timestamp: forum_post.created_at.iso8601,
        url: Routes.url_for(forum_post),
        author: {
          name: forum_post.creator.name,
          url: Routes.url_for(forum_post.creator)
        },
        fields: [
          {
            name: "Replies",
            value: forum_post.topic.response_count,
            inline: true
          },
          {
            name: "Users",
            value: forum_post.topic.forum_posts.distinct.count(:creator_id),
            inline: true
          }
        ]
      }]
    }
  end

  def convert_dtext(dtext)
    DText.new(dtext).to_markdown.truncate(2000)
  end

  def webhook_url
    "https://discord.com/api/webhooks/#{webhook_id}/#{webhook_secret}"
  end
end
