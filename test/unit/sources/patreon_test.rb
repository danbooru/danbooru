# frozen_string_literal: true

require "test_helper"

module Sources
  class PatreonTest < ActiveSupport::TestCase
    context "Patreon:" do
      context "An expired sample image URL" do
        strategy_should_work(
          "https://c10.patreonusercontent.com/4/patreon-media/p/post/71057815/d48874de48aa49f7878d32144de631fc/eyJ3Ijo2MjB9/1.jpg?token-time=1668384000&token-hash=9ORWv7LJBzmvzmHTi_xGFQ47Uis9fNzTPp2WweThDj4%3D",
          image_urls: [%r{https://c10.patreonusercontent.com/4/patreon-media/p/post/71057815/d48874de48aa49f7878d32144de631fc/eyJhIjoxLCJwIjoxfQ%3D%3D/1.jpg}],
          media_files: [{ file_size: 184_501 }],
          page_url: "https://www.patreon.com/posts/71057815",
          profile_url: "https://www.patreon.com/1041uuu",
          profile_urls: %w[https://www.patreon.com/1041uuu https://www.patreon.com/user?u=4045578],
          artist_name: "1041uuu",
          tag_name: "1041uuu",
          other_names: ["1041uuu"],
          tags: [],
          dtext_artist_commentary_title: "sparkle",
          dtext_artist_commentary_desc: "I drew this as an promote commission for Adobe."
        )
      end

      context "An attachment image URL" do
        strategy_should_work(
          "https://www.patreon.com/file?h=23563293&i=3053667",
          image_urls: %w[https://www.patreon.com/file?h=23563293&i=3053667],
          media_files: [{ file_size: 6_980_169 }],
          page_url: "https://www.patreon.com/posts/23563293",
          profile_url: "https://www.patreon.com/koveliana",
          profile_urls: %w[https://www.patreon.com/koveliana https://www.patreon.com/user?u=2931440],
          artist_name: "Koveliana",
          tag_name: "koveliana",
          other_names: ["Koveliana"],
          tags: [],
          dtext_artist_commentary_title: "Precious Metal [ych]",
          dtext_artist_commentary_desc: "+3 outfits ^_^"
        )
      end

      context "A public post with a single image" do
        strategy_should_work(
          "https://www.patreon.com/posts/free-post-12497641",
          image_urls: [%r{https://c10.patreonusercontent.com/4/patreon-media/p/post/12497641/3d99f5f5b635428ca237fedf0f223f1a/eyJhIjoxLCJwIjoxfQ%3D%3D/1.JPG}],
          media_files: [{ file_size: 405_509 }],
          page_url: "https://www.patreon.com/posts/free-post-12497641",
          profile_url: "https://www.patreon.com/Reedandweep",
          profile_urls: %w[https://www.patreon.com/Reedandweep https://www.patreon.com/user?u=3204144],
          artist_name: "ReedandWeep",
          tag_name: "reedandweep",
          other_names: ["ReedandWeep"],
          tags: [
            ["AWMedia", "https://www.patreon.com/Reedandweep/posts?filters[tag]=AWMedia"],
          ],
          dtext_artist_commentary_title: "Free post!",
          dtext_artist_commentary_desc: <<~EOS.chomp
            AWMedia brought his camera to our night out in LA

            took a few pics ✨

            patrons comment below why you love pledging to my page!
          EOS
        )
      end

      context "A public post with an inline image that is a duplicate of the header image" do
        strategy_should_work(
          "https://www.patreon.com/posts/sailormoonredraw-37219108",
          image_urls: [%r{https://c10.patreonusercontent.com/4/patreon-media/p/post/37219108/ede9a2c74f3e45389f4ca233b86b597c/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png}],
          media_files: [
            { file_size: 687_920 },
          ],
          page_url: "https://www.patreon.com/posts/sailormoonredraw-37219108",
          profile_url: "https://www.patreon.com/haruhisky",
          profile_urls: %w[https://www.patreon.com/haruhisky https://www.patreon.com/user?u=7453087],
          artist_name: "haruhisky",
          tag_name: "haruhisky",
          other_names: ["haruhisky"],
          tags: [
            ["Sailor Moon", "https://www.patreon.com/haruhisky/posts?filters[tag]=Sailor Moon"],
          ],
          dtext_artist_commentary_title: "#sailormoonredraw",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A public post with multiple inline images" do
        strategy_should_work(
          "https://www.patreon.com/posts/ishtar-fgo-30623038",
          image_urls: [
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/30623038/0588a269179a40ebac77f6d6853d6bbc/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/30623038/ee83c86ecd85424e8798126bc7471970/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/30623038/b652dbe138f844f6af14068ea3fd78a0/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/30623038/da56dcc5b0684cc0802e4ed46f26c791/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
          ],
          media_files: [
            { file_size: 1_304_374 },
            { file_size: 256_576 },
            { file_size: 278_551 },
            { file_size: 294_563 },
          ],
          page_url: "https://www.patreon.com/posts/ishtar-fgo-30623038",
          profile_url: "https://www.patreon.com/haruhisky",
          profile_urls: %w[https://www.patreon.com/haruhisky https://www.patreon.com/user?u=7453087],
          artist_name: "haruhisky",
          tag_name: "haruhisky",
          other_names: ["haruhisky"],
          tags: [
            ["FGO", "https://www.patreon.com/haruhisky/posts?filters[tag]=FGO"],
          ],
          dtext_artist_commentary_title: "Ishtar (FGO)",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://www.patreon.com/posts/ishtar-fgo-30623038]

            In order to draw this picture, I used a drawing method called the Grizaille method.

            In this method, you first shade in monotone and then apply a colormap to it.

            By doing so, you can do a harmonious shading overall.

            "[image]":[https://www.patreon.com/posts/ishtar-fgo-30623038]

            "[image]":[https://www.patreon.com/posts/ishtar-fgo-30623038]

            "[image]":[https://www.patreon.com/posts/ishtar-fgo-30623038]
          EOS
        )
      end

      context "A public post with attachments" do
        strategy_should_work(
          "https://www.patreon.com/posts/precious-metal-23563293",
          image_urls: [
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/23563293/5bad89b8746d4606aa1947356235481b/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/23563293/fd8833ede0c0421db29f1edac9a390ed/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/23563293/1eb9a6724f4c48dda959265a00410dc4/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/23563293/af7225bc08644f2e9b317eec675b73d5/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
          ],
          media_files: [
            { file_size: 7_083_450 },
            { file_size: 6_980_169 },
            { file_size: 6_794_279 },
            { file_size: 6_973_655 },
          ],
          page_url: "https://www.patreon.com/posts/precious-metal-23563293",
          profile_url: "https://www.patreon.com/koveliana",
          profile_urls: %w[https://www.patreon.com/koveliana https://www.patreon.com/user?u=2931440],
          artist_name: "Koveliana",
          tag_name: "koveliana",
          other_names: ["Koveliana"],
          tags: [],
          dtext_artist_commentary_title: "Precious Metal [ych]",
          dtext_artist_commentary_desc: "+3 outfits ^_^"
        )
      end

      context "A public post with a poll and an inline image that is not in the text" do
        strategy_should_work(
          "https://www.patreon.com/posts/56127163",
          image_urls: [
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/56127163/824329aabdb14edab157f4390b28ce2c/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/56127163/df12807137174624aa766afeaa0b2624/eyJhIjoxLCJwIjoxfQ%3D%3D/1.jpg},
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/56127163/2d4d4bb5d8604c179ec395e872f52bb8/eyJhIjoxLCJwIjoxfQ%3D%3D/1.jpg},
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/56127163/cabbad943b5840e6884a72ef1be131dc/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
          ],
          media_files: [
            { file_size: 536_985 },
            { file_size: 1_540_435 },
            { file_size: 2_832_749 },
            { file_size: 1_037_050 },
          ],
          page_url: "https://www.patreon.com/posts/56127163",
          profile_url: "https://www.patreon.com/Rumblekatt",
          profile_urls: %w[https://www.patreon.com/Rumblekatt https://www.patreon.com/user?u=647065],
          artist_name: "Katrina Sass",
          tag_name: "rumblekatt",
          other_names: ["Katrina Sass", "Rumblekatt"],
          tags: [
            ["poll", "https://www.patreon.com/Rumblekatt/posts?filters[tag]=poll"],
            ["print", "https://www.patreon.com/Rumblekatt/posts?filters[tag]=print"],
            ["printable", "https://www.patreon.com/Rumblekatt/posts?filters[tag]=printable"],
          ],
          dtext_artist_commentary_title: "September Printable!!",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Hey Party people!!

            Here is this month's poll for which printable will be offered this month.

            The three options are!

            "[image]":[https://www.patreon.com/posts/56127163]

            Lucky Tiger!

            "[image]":[https://www.patreon.com/posts/56127163]

            Yu Yu Hakusho!

            "[image]":[https://www.patreon.com/posts/56127163]

            Dinosaurs!

            Whatever piece wins will be an available printable for Tadpole and Frog Patrons at the end of the month!

            h6. Poll: September Printable!!

            * Lucky Tiger
            * Yu Yu Hakusho
            * Dinosaurs!
          EOS
        )
      end

      # XXX The video is a .m3u8 playlist file, which is not uploadable.
      context "A public post with a video" do
        strategy_should_work(
          "https://www.patreon.com/posts/meu8-94714289",
          image_urls: [
            %r{https://stream.mux.com/NLrxTLdxyGStpOgapJAtB8uPGAaokEcj8YovML00y2DY.m3u8},
            %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/94714289/be3d8eb994ae44eca4baffcdc6dd25fc/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png},
          ],
          # media_files: [
          #   { file_size: 2_688 }, # XXX This filesize changes on every request
          #   { file_size: 1_174_587 },
          # ],
          page_url: "https://www.patreon.com/posts/meu8-94714289",
          profile_url: "https://www.patreon.com/Kurzgesagt",
          profile_urls: %w[https://www.patreon.com/Kurzgesagt https://www.patreon.com/user?u=43579],
          artist_name: "Kurzgesagt – In a Nutshell",
          tag_name: "kurzgesagt",
          other_names: ["Kurzgesagt – In a Nutshell", "Kurzgesagt"],
          tags: [
            ["thank you!", "https://www.patreon.com/Kurzgesagt/posts?filters[tag]=thank you!"],
          ],
          dtext_artist_commentary_title: "Happy Holidays – See you in 12,024!",
          dtext_artist_commentary_desc: <<~EOS.chomp
            The year 12,023 of the Human Era is nearing its end – and what a year it has been!
            Thank you for being on this journey with us and sharing our passion for the universe and the world we live in.
            We hope you have a wonderful end of the year and an amazing 12,024.
            Much love from all of us at kurzgesagt ❤
          EOS
        )
      end

      context "A paid post" do
        strategy_should_work(
          "https://www.patreon.com/posts/99630172",
          image_urls: [],
          page_url: "https://www.patreon.com/posts/99630172",
          profile_url: "https://www.patreon.com/1041uuu",
          profile_urls: %w[https://www.patreon.com/1041uuu https://www.patreon.com/user?u=4045578],
          artist_name: "1041uuu",
          tag_name: "1041uuu",
          other_names: ["1041uuu"],
          tags: [],
          dtext_artist_commentary_title: "(announce) SHOP open now !",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent post" do
        strategy_should_work(
          "https://www.patreon.com/posts/title-999999999",
          image_urls: [],
          page_url: "https://www.patreon.com/posts/title-999999999",
          profile_url: nil,
          profile_urls: [],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://c10.patreonusercontent.com/4/patreon-media/p/post/71057815/d48874de48aa49f7878d32144de631fc/eyJ3Ijo2MjB9/1.jpg?token-time=1668384000&token-hash=9ORWv7LJBzmvzmHTi_xGFQ47Uis9fNzTPp2WweThDj4%3D"))
        assert(Source::URL.image_url?("https://c10.patreonusercontent.com/4/patreon-media/p/user/4045578/3101d8b9ba8348c592b68227f23b3568/eyJ3IjoyMDB9/1.jpeg?token-time=2145916800&token-hash=SQjWsty-7_MZqPt8R9_ZuJfzkW5F2pO3aqRV8iwZUIA%3D"))
        assert(Source::URL.image_url?("https://www.patreon.com/file?h=23563293&i=3053667"))

        assert(Source::URL.page_url?("https://www.patreon.com/m/posts/sparkle-71057815"))
        assert(Source::URL.page_url?("https://www.patreon.com/posts/71057815"))
        assert(Source::URL.page_url?("https://www.patreon.com/posts/sparkle-71057815"))
        assert(Source::URL.page_url?("https://www.patreon.com/api/posts/71057815"))

        assert(Source::URL.profile_url?("https://www.patreon.com/1041uuu"))
        assert(Source::URL.profile_url?("https://www.patreon.com/checkout/1041uuu?rid=0"))
        assert(Source::URL.profile_url?("https://www.patreon.com/join/twistedgrim/checkout?rid=704013&redirect_uri=/posts/noi-dorohedoro-39394158"))
        assert(Source::URL.profile_url?("https://www.patreon.com/m/1041uuu/about"))
        assert(Source::URL.profile_url?("https://www.patreon.com/bePatron?u=4045578"))
        assert(Source::URL.profile_url?("https://www.patreon.com/user?u=5993691"))
        assert(Source::URL.profile_url?("https://www.patreon.com/user/posts?u=84592583"))
        assert(Source::URL.profile_url?("https://www.patreon.com/api/user/4045578"))
      end
    end
  end
end
