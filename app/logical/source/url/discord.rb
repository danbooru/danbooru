# frozen_string_literal: true

class Source::URL::Discord < Source::URL
  attr_reader :server_name, :server_id, :channel_id, :message_id

  def self.match?(url)
    url.domain.in?(%w[discord.gg discord.com discordapp.com discordapp.net])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://discord.gg/Zxs9tPE -> https://discord.com/invite/Zxs9tPE
    # https://discord.gg/danbooru -> https://discord.com/invite/danbooru
    in _, "discord.gg", server_name
      @server_name = server_name

    # https://discord.com/invite/Zxs9tPE
    # https://discord.com/invite/danbooru
    # https://discordapp.com/invite/danbooru
    in _, ("discord.com" | "discordapp.com"), "invite", server_name
      @server_name = server_name

    # https://discord.com/channels/310432830138089472/310653236870643712/1233785107316478063
    in _, ("discord.com" | "discordapp.com"), "channels", /^\d+$/ => server_id, /^\d+$/ => channel_id, /^\d+$/ => message_id
      @server_id = server_id
      @channel_id = channel_id
      @message_id = message_id

    # https://discord.com/channels/310432830138089472/310432830138089472
    in _, ("discord.com" | "discordapp.com"), "channels", /^\d+$/ => server_id, /^\d+$/ => channel_id
      @server_id = server_id
      @channel_id = channel_id

    # https://cdn.discordapp.com/attachments/310653236870643712/1233785107135856711/image.png?ex=662e5b6c&is=662d09ec&hm=6528c2b6fc5d10a06049af2ec8e8daa3280baa6e5fbd8e42d8d00f8df3c25fe4&
    in "cdn", "discordapp.com", "attachments", server_id, *rest
      @server_id = server_id

    # https://media.discordapp.net/attachments/310653236870643712/1233802497177554964/cooltext456949440675671.gif?ex=662e6b9e&is=662d1a1e&hm=7e0aaa8ffb728471045280eacc5d23553a318ca4afa196a1fbf544ab5a83141b
    in "media", "discordapp.net", "attachments", server_id, *rest
      @server_id = server_id

    # https://discord.com/channels/@me
    # https://discordapp.com/users/sleepywedneday
    # https://discordapp.com/users/809362308072996894
    # https://images-ext-1.discordapp.net/external/R-JlEE6CD3oVL7HnZAOGmyDJq1GZJ02I8KJI3CZhWSM/https/mosaic.fxtwitter.com/jpeg/1783964537802154127/GMHl1-aXkAAF90s/GMHl3KFWoAEfLVG?format=webp&width=481&height=676
    else
      nil
    end
  end

  def page_url
    "https://discord.com/channels/#{server_id}/#{channel_id}/#{message_id}" if server_id.present? && channel_id.present? && message_id.present?
  end

  def profile_url
    "https://discord.gg/#{server_name}" if server_name.present?
  end
end
