require "test_helper"

module Source::Tests::Extractor
  class RedgifsExtractorTest < ActiveSupport::TestCase
    setup do
      # Cache token across tests so that we don't get IP banned for requesting bearer tokens too frequently.
      @bearer_token ||= Source::Extractor::Redgifs.new(nil).bearer_token
      Cache.put("redgifs-bearer-token", @bearer_token)
    end

    context "A sample video URL" do
      strategy_should_work(
        "https://thumbs44.redgifs.com/ThunderousVerifiableScoter-mobile.mp4?expires=1715892000&signature=v2:c89b477640c90093677fe353622dffc7624869e28a7444b050f4b2cb52f1ed3c&for=198.54.135&hash=7011125643",
        image_urls: %w[https://media.redgifs.com/ThunderousVerifiableScoter.mp4],
        media_files: [{ file_size: 2_491_883 }],
        page_url: "https://www.redgifs.com/watch/thunderousverifiablescoter",
        profile_urls: %w[https://www.redgifs.com/users/kreamu],
        display_name: "kreamu",
        username: "kreamu",
        tags: [
          ["3D", "https://www.redgifs.com/gifs/3d"],
          ["Animation", "https://www.redgifs.com/gifs/animation"],
          ["Hentai", "https://www.redgifs.com/gifs/hentai"],
          ["SFM", "https://www.redgifs.com/gifs/sfm"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "An individual image from an image gallery" do
      strategy_should_work(
        "https://thumbs44.redgifs.com/JauntyHandmadePoodle-large.jpg?expires=1715898000&signature=v2:fdcee3e97772b01f3061b7ebd09b9bcc37a05c36a7195c77e3e7fb91da8db472&for=198.54.135&hash=7011125643",
        image_urls: %w[https://media.redgifs.com/JauntyHandmadePoodle-large.jpg],
        media_files: [{ file_size: 1_263_405 }],
        page_url: "https://www.redgifs.com/watch/diligentfluidbichonfrise",
        profile_urls: %w[https://www.redgifs.com/users/throwmeafterdark],
        display_name: "throwmeafterdark",
        username: "throwmeafterdark",
        tags: [
          ["Ass", "https://www.redgifs.com/gifs/ass"],
          ["Babe", "https://www.redgifs.com/gifs/babe"],
          ["Creampie", "https://www.redgifs.com/gifs/creampie"],
          ["Cum", "https://www.redgifs.com/gifs/cum"],
          ["Freeuse", "https://www.redgifs.com/gifs/freeuse"],
          ["Jeans", "https://www.redgifs.com/gifs/jeans"],
          ["Panties", "https://www.redgifs.com/gifs/panties"],
          ["Pawg", "https://www.redgifs.com/gifs/pawg"],
          ["cumslut", "https://www.redgifs.com/gifs/cumslut"],
          ["r/RearPussy", "https://www.redgifs.com/gifs/r%2Frearpussy"],
          ["creampies", "https://www.redgifs.com/niches/creampies"],
          ["phat-ass-white-girls", "https://www.redgifs.com/niches/phat-ass-white-girls"],
          ["pussy", "https://www.redgifs.com/niches/pussy"],
          ["pussy-from-behind", "https://www.redgifs.com/niches/pussy-from-behind"],
          ["thick-booty", "https://www.redgifs.com/niches/thick-booty"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "A naughty story in 6 parts 💦💦",
      )
    end

    context "An image gallery" do
      strategy_should_work(
        "https://www.redgifs.com/watch/diligentfluidbichonfrise",
        image_urls: %w[
          https://media.redgifs.com/DiligentFluidBichonfrise-large.jpg
          https://media.redgifs.com/JauntyHandmadePoodle-large.jpg
          https://media.redgifs.com/LameDirectHornedtoad-large.jpg
          https://media.redgifs.com/DrearyMatureZebu-large.jpg
          https://media.redgifs.com/FemaleWelldocumentedFox-large.jpg
          https://media.redgifs.com/RigidGoldShrew-large.jpg
        ],
        media_files: [
          { file_size: 1_533_554 },
          { file_size: 1_263_405 },
          { file_size: 984_512 },
          { file_size: 961_618 },
          { file_size: 1_187_181 },
          { file_size: 935_412 },
        ],
        page_url: "https://www.redgifs.com/watch/diligentfluidbichonfrise",
        profile_urls: %w[https://www.redgifs.com/users/throwmeafterdark],
        display_name: "throwmeafterdark",
        username: "throwmeafterdark",
        tags: [
          ["Ass", "https://www.redgifs.com/gifs/ass"],
          ["Babe", "https://www.redgifs.com/gifs/babe"],
          ["Creampie", "https://www.redgifs.com/gifs/creampie"],
          ["Cum", "https://www.redgifs.com/gifs/cum"],
          ["Freeuse", "https://www.redgifs.com/gifs/freeuse"],
          ["Jeans", "https://www.redgifs.com/gifs/jeans"],
          ["Panties", "https://www.redgifs.com/gifs/panties"],
          ["Pawg", "https://www.redgifs.com/gifs/pawg"],
          ["cumslut", "https://www.redgifs.com/gifs/cumslut"],
          ["r/RearPussy", "https://www.redgifs.com/gifs/r%2Frearpussy"],
          ["creampies", "https://www.redgifs.com/niches/creampies"],
          ["phat-ass-white-girls", "https://www.redgifs.com/niches/phat-ass-white-girls"],
          ["pussy", "https://www.redgifs.com/niches/pussy"],
          ["pussy-from-behind", "https://www.redgifs.com/niches/pussy-from-behind"],
          ["thick-booty", "https://www.redgifs.com/niches/thick-booty"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "A naughty story in 6 parts 💦💦",
      )
    end

    context "An individual post from an image gallery" do
      strategy_should_work(
        "https://www.redgifs.com/watch/jauntyhandmadepoodle",
        image_urls: %w[https://media.redgifs.com/JauntyHandmadePoodle-large.jpg],
        media_files: [{ file_size: 1_263_405 }],
        page_url: "https://www.redgifs.com/watch/diligentfluidbichonfrise",
        profile_urls: %w[https://www.redgifs.com/users/throwmeafterdark],
        display_name: "throwmeafterdark",
        username: "throwmeafterdark",
        tags: [
          ["Ass", "https://www.redgifs.com/gifs/ass"],
          ["Babe", "https://www.redgifs.com/gifs/babe"],
          ["Creampie", "https://www.redgifs.com/gifs/creampie"],
          ["Cum", "https://www.redgifs.com/gifs/cum"],
          ["Freeuse", "https://www.redgifs.com/gifs/freeuse"],
          ["Jeans", "https://www.redgifs.com/gifs/jeans"],
          ["Panties", "https://www.redgifs.com/gifs/panties"],
          ["Pawg", "https://www.redgifs.com/gifs/pawg"],
          ["cumslut", "https://www.redgifs.com/gifs/cumslut"],
          ["r/RearPussy", "https://www.redgifs.com/gifs/r%2Frearpussy"],
          ["creampies", "https://www.redgifs.com/niches/creampies"],
          ["phat-ass-white-girls", "https://www.redgifs.com/niches/phat-ass-white-girls"],
          ["pussy", "https://www.redgifs.com/niches/pussy"],
          ["pussy-from-behind", "https://www.redgifs.com/niches/pussy-from-behind"],
          ["thick-booty", "https://www.redgifs.com/niches/thick-booty"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "A naughty story in 6 parts 💦💦",
      )
    end

    context "A video post" do
      strategy_should_work(
        "https://www.redgifs.com/watch/thunderousverifiablescoter",
        image_urls: %w[https://media.redgifs.com/ThunderousVerifiableScoter.mp4],
        media_files: [{ file_size: 2_491_883 }],
        page_url: "https://www.redgifs.com/watch/thunderousverifiablescoter",
        profile_urls: %w[https://www.redgifs.com/users/kreamu],
        display_name: "kreamu",
        username: "kreamu",
        tags: [
          ["3D", "https://www.redgifs.com/gifs/3d"],
          ["Animation", "https://www.redgifs.com/gifs/animation"],
          ["Hentai", "https://www.redgifs.com/gifs/hentai"],
          ["SFM", "https://www.redgifs.com/gifs/sfm"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "An expired bearer token should automatically be refreshed" do
      setup do
        Cache.put("redgifs-bearer-token", "invalid")
      end

      strategy_should_work(
        "https://www.redgifs.com/watch/thunderousverifiablescoter",
        image_urls: %w[https://media.redgifs.com/ThunderousVerifiableScoter.mp4],
        page_url: "https://www.redgifs.com/watch/thunderousverifiablescoter",
        profile_urls: %w[https://www.redgifs.com/users/kreamu],
        display_name: "kreamu",
      )
    end

    context "A deleted or nonexistent post" do
      strategy_should_work(
        "https://www.redgifs.com/watch/bad",
        image_urls: [],
        page_url: "https://www.redgifs.com/watch/bad",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tag_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
