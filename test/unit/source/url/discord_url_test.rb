require "test_helper"

module Source::Tests::URL
  class DiscordUrlTest < ActiveSupport::TestCase
    context "Discord URLs" do
      should be_image_url(
        "https://cdn.discordapp.com/attachments/310653236870643712/1233785107135856711/image.png?ex=662e5b6c&is=662d09ec&hm=6528c2b6fc5d10a06049af2ec8e8daa3280baa6e5fbd8e42d8d00f8df3c25fe4&",
        "https://media.discordapp.net/attachments/310653236870643712/1233802497177554964/cooltext456949440675671.gif?ex=662e6b9e&is=662d1a1e&hm=7e0aaa8ffb728471045280eacc5d23553a318ca4afa196a1fbf544ab5a83141b",
      )

      should be_page_url(
        "https://discord.com/channels/310432830138089472/310653236870643712/1233785107316478063",
      )

      should be_profile_url(
        "https://discord.gg/danbooru",
      )

      should be_bad_link(
        "https://cdn.discordapp.com/attachments/310653236870643712/1233785107135856711/image.png?ex=662e5b6c&is=662d09ec&hm=6528c2b6fc5d10a06049af2ec8e8daa3280baa6e5fbd8e42d8d00f8df3c25fe4&",
      )

      should be_bad_source(
        "https://discord.com/channels/310432830138089472/310432830138089472",
        "https://discord.gg/danbooru",
      )

      should parse_url("https://discord.gg/danbooru").into(profile_url: "https://discord.gg/danbooru")
      should parse_url("https://discord.com/invite/danbooru").into(profile_url: "https://discord.gg/danbooru")
      should parse_url("https://discordapp.com/invite/danbooru").into(profile_url: "https://discord.gg/danbooru")
    end

    should parse_url("https://cdn.discordapp.com/attachments/310653236870643712/1233785107135856711/image.png?ex=662e5b6c&is=662d09ec&hm=6528c2b6fc5d10a06049af2ec8e8daa3280baa6e5fbd8e42d8d00f8df3c25fe4&").into(site_name: "Discord")
  end
end
