require "test_helper"

module Sources
  class FoundationTest < ActiveSupport::TestCase
    context "A foundation post" do
      strategy_should_work(
        "https://foundation.app/@dadachyo/~/103724",
        page_url: "https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/103724",
        media_files: [{ file_size: 13_908_349 }],
        image_urls: ["https://f8n-ipfs-production.imgix.net/QmPhpz6E9TFRpvdVTviM8Hy9o9rxrnPW5Ywj471NnSNkpi/nft.jpg"],
        profile_url: "https://foundation.app/@dadachyo",
        profile_urls: ["https://foundation.app/0xb4D9073800c7935351ACDC1e46F0CF670853eA99", "https://foundation.app/@dadachyo"],
        display_name: "DADACHYO",
        username: "dadachyo",
        other_names: ["DADACHYO"],
        dtext_artist_commentary_title: "Rose tea",
        dtext_artist_commentary_desc: <<~EOS.chomp
          Digital artists had not been fully recognized for their artistic value, because people thought digital-artworks only existed online and could be copied indefinitely.

          However, digital-artworks are appreciated its own value through NFT. I am so happy to see the possibility to continue my art activities thru NTF.

          I figure out that purchasing my artwork means not only simply having the artwork, but also sharing my growth.
          Even if I leave someday in the future, I believe my artwork will be with you in the digital world forever, and it will comfort you with the power of art whenever you want.

          Each of us has a tough day for various reasons.
          I hope art will hug you who have a hard time, give you a good inspiration, and brighten up your every single day beautifully.

          I’d truly appreciate many people who are encouraging the creative activities for art and supporting the artists.
          Thanks to all, I am brave to keep going for my artwork.

          June 26, 2018
          3460 x 4188
          Photoshop

          Artist DADACHYO
        EOS
      )
    end

    context "A foundation image url" do
      strategy_should_work(
        "https://f8n-ipfs-production.imgix.net/QmPhpz6E9TFRpvdVTviM8Hy9o9rxrnPW5Ywj471NnSNkpi/nft.jpg",
        image_urls: ["https://f8n-ipfs-production.imgix.net/QmPhpz6E9TFRpvdVTviM8Hy9o9rxrnPW5Ywj471NnSNkpi/nft.jpg"],
        media_files: [{ file_size: 13_908_349 }],
        page_url: nil
      )
    end

    context "A foundation gif" do
      strategy_should_work(
        "https://foundation.app/@patch_oxxo/shine/1",
        image_urls: ["https://f8n-ipfs-production.imgix.net/QmWQpt9opcue5F7Q2vTT5P5jPYo1xHhEs7RDxgXzWFHcfK/nft.gif"],
        media_files: [{ file_size: 52_352_138 }],
        page_url: "https://foundation.app/mint/eth/0xcef77277219F5d47cc5247D77caa8717E0B99cdd/1",
        profile_url: "https://foundation.app/@patch_oxxo",
        profile_urls: %w[https://foundation.app/@patch_oxxo https://foundation.app/0x707063a10B41Ba676c5Ab8fcA13BF26BE8B4F49a],
        display_name: "Patch",
        username: "patch_oxxo",
        other_names: %w[Patch patch_oxxo],
        dtext_artist_commentary_title: "Prologue",
        dtext_artist_commentary_desc: <<~EOS.chomp
          I don't like crowded trains, so I go to school a little early in the morning. That day, I closed my eyes for a moment, feeling the noise of the morning, but then I realized that I couldn't hear anything around me.
        EOS
      )
    end

    context "A foundation.app/@username/foo-bar-1234 URL" do
      strategy_should_work(
        "https://foundation.app/@asuka111art/dinner-with-cats-82426",
        page_url: "https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/82426",
        image_urls: ["https://f8n-ipfs-production.imgix.net/Qma7Lz2LfFb4swoqzr1V43oRGh9xikgigM11g3EukdU61R/nft.png"],
        profile_url: "https://foundation.app/@asuka111art",
        profile_urls: ["https://foundation.app/@asuka111art", "https://foundation.app/0x9A94f94626352566e0A9105F1e3DA0439E3e3783"],
        display_name: "ASUKA111",
        username: "asuka111art",
        other_names: %w[ASUKA111 asuka111art],
        dtext_artist_commentary_title: "Dinner with cats - 猫の夕食",
        dtext_artist_commentary_desc: <<~EOS.chomp
          Delicious meal with cats. Original Artwork from 2017.

          3850x5250px
          PNG

          1/1 Edition.
        EOS
      )
    end

    context "A f8n-production-collection-assets.imgix.net URL" do
      strategy_should_work(
        "https://f8n-production-collection-assets.imgix.net/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png?q=80&auto=format%2Ccompress&cs=srgb&h=640",
        page_url: "https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711",
        image_urls: ["https://f8n-ipfs-production.imgix.net/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png"],
        profile_url: "https://foundation.app/@mochiiimo",
        profile_urls: ["https://foundation.app/0x7E2ef75C0C09b2fc6BCd1C68B6D409720CcD58d2", "https://foundation.app/@mochiiimo"],
        display_name: "Mochii",
        username: "mochiiimo",
        other_names: %w[Mochii mochiiimo],
        dtext_artist_commentary_title: "Lazy evening",
        dtext_artist_commentary_desc: "A quiet evening, chilling by the sunlight after a long and busy day.."
      )
    end

    context "A foundation post with a video hosted on imgix" do
      strategy_should_work(
        "https://foundation.app/@huwari/~/109433",
        page_url: "https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/109433",
        image_urls: ["https://f8n-ipfs-production.imgix.net/QmPXiZg6JkmJnJy1LmDzqqYACzEaXudELiaJ8i5iwbkoTs/nft.mp4"],
        media_files: [{ file_size: 11_265_862 }],
        display_name: "ふわり",
        username: "huwari",
        other_names: %w[ふわり huwari],
        profile_url: "https://foundation.app/@huwari",
        profile_urls: ["https://foundation.app/@huwari", "https://foundation.app/0xaa2f2eDE4D502F59b3706d2E2dA873C8A00A3d4d"],
        dtext_artist_commentary_title: "scarf",
        dtext_artist_commentary_desc: "A girl wearing a scarf."
      )
    end

    context "A foundation post with a video hosted on foundation" do
      strategy_should_work(
        "https://foundation.app/@mcbess/ladies/4",
        image_urls: ["https://assets.foundation.app/0x21Afa9aB02B6Fb7cb483ff3667c39eCdd6D9Ea73/4/nft.mp4"],
        page_url: "https://foundation.app/mint/eth/0x21Afa9aB02B6Fb7cb483ff3667c39eCdd6D9Ea73/4",
        display_name: "mcbess",
        username: "mcbess",
      )
    end

    context "A foundation post with a video hosted on cloudfront" do
      strategy_should_work(
        "https://foundation.app/@nixeu/foundation/109126",
        image_urls: ["https://f8n-ipfs-production.imgix.net/QmXiCEoBLcpfvpEwAEanLXe3Tjr5ykYJFzCVfpzDDQzdBD/nft.mp4"],
        page_url: "https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/109126",
        display_name: "NIXEU",
        username: "nixeu"
      )
    end

    context "A post that belongs to a collection" do
      strategy_should_work(
        "https://foundation.app/@KILLERGF/kgfgen/4",
        image_urls: ["https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png"],
        page_url: "https://foundation.app/mint/eth/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4",
        display_name: "KILLER GF",
        username: "KILLERGF"
      )
    end

    context "A /mint/eth/ collection post" do
      strategy_should_work(
        "https://foundation.app/mint/eth/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4",
        image_urls: ["https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png"],
        page_url: "https://foundation.app/mint/eth/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4",
        display_name: "KILLER GF",
        username: "KILLERGF"
      )
    end

    context "A post with a non-alphanumeric username (1)" do
      strategy_should_work(
        "https://foundation.app/@brandon.dalmer/~/6792",
        image_urls: ["https://f8n-ipfs-production.imgix.net/QmVnpe39qodMjTe8v3fijPfB1tjwhT8hgobtgLPtsangqc/nft.png"],
        page_url: "https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/6792",
        display_name: "Brandon A. Dalmer",
        username: "brandon.dalmer"
      )
    end

    context "A post with a non-alphanumeric username (2)" do
      strategy_should_work(
        "https://foundation.app/@~/~/6792",
        image_urls: ["https://f8n-ipfs-production.imgix.net/QmVnpe39qodMjTe8v3fijPfB1tjwhT8hgobtgLPtsangqc/nft.png"],
        page_url: "https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/6792",
        display_name: "Brandon A. Dalmer",
        username: "brandon.dalmer"
      )
    end

    context "parsing UTF-8 commentaries" do
      strategy_should_work(
        "https://foundation.app/@SimaEnaga/~/107338",
        image_urls: ["https://f8n-ipfs-production.imgix.net/QmczQgCxW6Gzx6YnE4qpyMCeHnFZnSJTJPCAVc6N97crHz/nft.jpg"],
        page_url: "https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/107338",
        display_name: "SimaEnaga",
        username: "SimaEnaga",
        dtext_artist_commentary_desc: <<~EOS.chomp
          【須佐之男尊/Susanoo-no-Mikoto】
          He is the youngest child of the three brothers and has older sister "Amaterasu" and older brother "Tsukuyomi". They are children whose father is "Izanagi" and mother is "Izanami".They live in the Land of gods known as "Takamagahara".
          He carried out a number of violence and caused trouble to people.
          As a result, he was expelled from Takamagahara and moved to the human world.

          【Meaning】
          There is a theory that "須佐/susa" is a word
          that means "凄まじい/susamajii (tremendous)" in Japanese.
          ”之/no” is a conjunction "of".
          “男/o” means ”male”.
          ”尊/mikoto” is a word that after the name of a god or a noble (Lord; Highness).
          Colloquially, "The crazy guy." lol

          【Concept】
          He carries the bronze sword “Kusanagi-no Tsurugi”. This is one of the "three sacred treasures" and is the most famous sword in Japan. “Kusanagi-no Tsurugi” is dedicated to Atsuta Shrine in Aichi Prefecture, Japan.
          The sword is now sealed and no one has seen it.
        EOS
      )
    end

    should "parse Foundation URLs correctly" do
      assert(Source::URL.image_url?("https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png"))
      assert(Source::URL.image_url?("https://f8n-production-collection-assets.imgix.net/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png"))
      assert(Source::URL.image_url?("https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png"))
      assert(Source::URL.image_url?("https://assets.foundation.app/0x21Afa9aB02B6Fb7cb483ff3667c39eCdd6D9Ea73/4/nft.mp4"))
      assert(Source::URL.image_url?("https://assets.foundation.app/7i/gs/QmU8bbsjaVQpEKMDWbSZdDD6GsPmRYBhQtYRn8bEGv7igs/nft_q4.mp4"))
      assert(Source::URL.image_url?("https://d2ybmb80bbm9ts.cloudfront.net/zd/BD/QmXiCEoBLcpfvpEwAEanLXe3Tjr5ykYJFzCVfpzDDQzdBD/nft_q4.mp4"))

      assert(Source::URL.page_url?("https://foundation.app/@asuka111art/dinner-with-cats-82426"))
      assert(Source::URL.page_url?("https://foundation.app/@mochiiimo/~/97376"))
      assert(Source::URL.page_url?("https://foundation.app/mint/eth/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4"))
      assert(Source::URL.page_url?("https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/109433"))

      assert(Source::URL.profile_url?("https://foundation.app/@mochiiimo"))
      assert(Source::URL.profile_url?("https://foundation.app/0x7E2ef75C0C09b2fc6BCd1C68B6D409720CcD58d2"))
    end
  end
end
