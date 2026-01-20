require "test_helper"

module Source::Tests::Extractor
  class ToyhouseExtractorTest < ActiveSupport::ExtractorTestCase
    context "A thumbnail image URL" do
      strategy_should_work(
        "https://f2.toyhou.se/file/f2-toyhou-se/thumbnails/73744030_WfK.png",
        image_urls: %w[https://f2.toyhou.se/file/f2-toyhou-se/watermarks/73744030_WfKyU9fkJ.png],
        media_files: [{ file_size: 2_294_417 }],
        page_url: "https://toyhou.se/~images/73744030",
        profile_url: "https://toyhou.se/lilcudds",
        profile_urls: %w[https://toyhou.se/lilcudds],
        display_name: "lilcudds",
        username: nil,
        tags: [
          ["cudlil", "https://toyhou.se/2712983.cudlil/19136829.art-by-me"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "her current design was a wip, these colors are off! !",
      )
    end

    context "A full image URL" do
      strategy_should_work(
        "https://f2.toyhou.se/file/f2-toyhou-se/images/58037599_Ov5j4w66lQRw9G4.png",
        image_urls: %w[https://f2.toyhou.se/file/f2-toyhou-se/images/58037599_Ov5j4w66lQRw9G4.png],
        media_files: [{ file_size: 735_586 }],
        page_url: "https://toyhou.se/~images/58037599",
        profile_url: "https://toyhou.se/427Deer",
        profile_urls: %w[https://toyhou.se/427Deer],
        display_name: "427Deer",
        username: nil,
        tags: [
          ["June (Human)", "https://toyhou.se/19108771.june-human-"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A character image URL" do
      strategy_should_work(
        "https://f2.toyhou.se/file/f2-toyhou-se/characters/19108771?1670101610",
        image_urls: %w[https://f2.toyhou.se/file/f2-toyhou-se/characters/19108771?1670101610],
        media_files: [{ file_size: 23_176 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A post by the artist credited to themselves" do
      strategy_should_work(
        "https://toyhou.se/2712983.cudlil/19136829.art-by-me#73744030",
        image_urls: %w[https://f2.toyhou.se/file/f2-toyhou-se/watermarks/73744030_WfKyU9fkJ.png],
        media_files: [{ file_size: 2_294_417 }],
        page_url: "https://toyhou.se/2712983.cudlil/19136829.art-by-me/73744030",
        profile_url: "https://toyhou.se/lilcudds",
        profile_urls: %w[https://toyhou.se/lilcudds],
        display_name: "lilcudds",
        username: nil,
        tags: [
          ["cudlil", "https://toyhou.se/2712983.cudlil/19136829.art-by-me"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "her current design was a wip, these colors are off! !",
      )
    end

    context "A post with multiple characters and credited to a different Toyhou.se user" do
      strategy_should_work(
        "https://toyhou.se/2712983.cudlil/19136838.art-by-others/58116407",
        image_urls: %w[https://f2.toyhou.se/file/f2-toyhou-se/watermarks/58116407_mAmE0QkZN.png?1700502692],
        media_files: [{ file_size: 1_127_805 }],
        page_url: "https://toyhou.se/2712983.cudlil/19136838.art-by-others/58116407",
        profile_url: "https://toyhou.se/mrstinky_org",
        profile_urls: %w[https://toyhou.se/mrstinky_org],
        display_name: "mrstinky_org",
        username: nil,
        tags: [
          ["cudlil", "https://toyhou.se/2712983.cudlil/19136838.art-by-others"],
          ["bear bro", "https://toyhou.se/19228770.bear-bro"],
          ["cuddles", "https://toyhou.se/19228781.cuddles"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A post credited to a different artist on a different site" do
      strategy_should_work(
        "https://toyhou.se/~images/58116270",
        image_urls: %w[https://f2.toyhou.se/file/f2-toyhou-se/watermarks/58116270_BOOKN8MO8.jpg?1700502658],
        media_files: [{ file_size: 895_860 }],
        page_url: "https://toyhou.se/~images/58116270",
        profile_url: "https://twitter.com/Gaziter",
        profile_urls: %w[https://twitter.com/Gaziter],
        display_name: "Gaziter",
        username: nil,
        tags: [
          ["cudlil", "https://toyhou.se/2712983.cudlil/19136838.art-by-others"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          i don't own the other 3 characters featured!! my persona is the bottom left char
        EOS
      )
    end

    context "A post credited to an artist without a display name" do
      strategy_should_work(
        "https://toyhou.se/1.firestarter/gallery#153",
        image_urls: %w[https://f2.toyhou.se/file/f2-toyhou-se/images/153_bHwg5E1xvWGjmeU.png?1499247051],
        media_files: [{ file_size: 889_161 }],
        page_url: "https://toyhou.se/1.firestarter/153",
        profile_url: "https://www.furaffinity.net/user/keii",
        profile_urls: %w[https://www.furaffinity.net/user/keii],
        display_name: nil,
        username: nil,
        tags: [
          ["Firestarter", "https://toyhou.se/1.firestarter"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    # XXX Galleries aren't supported.
    context "A character gallery" do
      strategy_should_work(
        "https://toyhou.se/2712983.cudlil/19136838.art-by-others",
        image_urls: [],
        page_url: "https://toyhou.se/2712983.cudlil/19136838.art-by-others",
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deleted or nonexistent post" do
      strategy_should_work(
        "https://toyhou.se/~images/999999999",
        image_urls: [],
        media_files: [],
        page_url: "https://toyhou.se/~images/999999999",
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
