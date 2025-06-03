require "test_helper"

module Source::Tests::URL
  class DiscordUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://cdn.discordapp.com/attachments/310653236870643712/1233785107135856711/image.png?ex=662e5b6c&is=662d09ec&hm=6528c2b6fc5d10a06049af2ec8e8daa3280baa6e5fbd8e42d8d00f8df3c25fe4&",
          "https://media.discordapp.net/attachments/310653236870643712/1233802497177554964/cooltext456949440675671.gif?ex=662e6b9e&is=662d1a1e&hm=7e0aaa8ffb728471045280eacc5d23553a318ca4afa196a1fbf544ab5a83141b",
        ],
        page_urls: [
          "https://discord.com/channels/310432830138089472/310653236870643712/1233785107316478063",
        ],
        profile_urls: [
          "https://discord.gg/danbooru",
        ],
        bad_links: [
          "https://cdn.discordapp.com/attachments/310653236870643712/1233785107135856711/image.png?ex=662e5b6c&is=662d09ec&hm=6528c2b6fc5d10a06049af2ec8e8daa3280baa6e5fbd8e42d8d00f8df3c25fe4&",
        ],
        bad_sources: [
          "https://discord.com/channels/310432830138089472/310432830138089472",
          "https://discord.gg/danbooru",
        ],
      )
    end
    context "when extracting attributes" do
      url_parser_should_work("https://discord.gg/danbooru", profile_url: "https://discord.gg/danbooru")
      url_parser_should_work("https://discord.com/invite/danbooru", profile_url: "https://discord.gg/danbooru")
      url_parser_should_work("https://discordapp.com/invite/danbooru", profile_url: "https://discord.gg/danbooru")
    end
  end
end
