# frozen_string_literal: true

require "test_helper"

module Sources
  class DiscordTest < ActiveSupport::TestCase
    context "Discord:" do
      should "parse Discord URLs correctly" do
        assert(Source::URL.image_url?("https://cdn.discordapp.com/attachments/310653236870643712/1233785107135856711/image.png?ex=662e5b6c&is=662d09ec&hm=6528c2b6fc5d10a06049af2ec8e8daa3280baa6e5fbd8e42d8d00f8df3c25fe4&"))
        assert(Source::URL.image_url?("https://media.discordapp.net/attachments/310653236870643712/1233802497177554964/cooltext456949440675671.gif?ex=662e6b9e&is=662d1a1e&hm=7e0aaa8ffb728471045280eacc5d23553a318ca4afa196a1fbf544ab5a83141b"))
        assert(Source::URL.page_url?("https://discord.com/channels/310432830138089472/310653236870643712/1233785107316478063"))
        assert(Source::URL.profile_url("https://discord.gg/danbooru"))

        assert_equal("https://discord.gg/danbooru", Source::URL.profile_url("https://discord.gg/danbooru"))
        assert_equal("https://discord.gg/danbooru", Source::URL.profile_url("https://discord.com/invite/danbooru"))
        assert_equal("https://discord.gg/danbooru", Source::URL.profile_url("https://discordapp.com/invite/danbooru"))

        assert(Source::URL.parse("https://cdn.discordapp.com/attachments/310653236870643712/1233785107135856711/image.png?ex=662e5b6c&is=662d09ec&hm=6528c2b6fc5d10a06049af2ec8e8daa3280baa6e5fbd8e42d8d00f8df3c25fe4&").bad_link?)
        assert(Source::URL.parse("https://discord.com/channels/310432830138089472/310432830138089472").bad_source?)
        assert(Source::URL.parse("https://discord.gg/danbooru").bad_source?)
      end
    end
  end
end
