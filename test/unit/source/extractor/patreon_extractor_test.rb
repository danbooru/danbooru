require "test_helper"

module Source::Tests::Extractor
  class PatreonExtractorTest < ActiveSupport::ExtractorTestCase
    context "An expired sample image URL" do
      strategy_should_work(
        "https://c10.patreonusercontent.com/4/patreon-media/p/post/71057815/d48874de48aa49f7878d32144de631fc/eyJ3Ijo2MjB9/1.jpg?token-time=1668384000&token-hash=9ORWv7LJBzmvzmHTi_xGFQ47Uis9fNzTPp2WweThDj4%3D",
        image_urls: [%r{https://c10.patreonusercontent.com/4/patreon-media/p/post/71057815/d48874de48aa49f7878d32144de631fc/eyJhIjoxLCJwIjoxfQ%3D%3D/1.jpg}],
        media_files: [{ file_size: 449_004 }],
        page_url: "https://www.patreon.com/posts/71057815",
        profile_url: "https://www.patreon.com/1041uuu",
        profile_urls: %w[https://www.patreon.com/1041uuu https://www.patreon.com/user?u=4045578],
        display_name: "1041uuu",
        username: "1041uuu",
        tag_name: "1041uuu",
        other_names: ["1041uuu"],
        tags: [],
        dtext_artist_commentary_title: "sparkle",
        dtext_artist_commentary_desc: "I drew this as an promote commission for Adobe.",
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
        display_name: "Koveliana",
        username: "koveliana",
        tag_name: "koveliana",
        other_names: ["Koveliana"],
        tags: [],
        dtext_artist_commentary_title: "Precious Metal [ych]",
        dtext_artist_commentary_desc: "+3 outfits ^_^",
      )
    end

    context "A public post with a single image" do
      strategy_should_work(
        "https://www.patreon.com/posts/free-post-12497641",
        image_urls: [%r{https://c10.patreonusercontent.com/4/patreon-media/p/post/12497641/3d99f5f5b635428ca237fedf0f223f1a/eyJhIjoxLCJwIjoxfQ%3D%3D/1.JPG}],
        media_files: [{ file_size: 831_091 }],
        page_url: "https://www.patreon.com/posts/free-post-12497641",
        profile_url: "https://www.patreon.com/Reedandweep",
        profile_urls: %w[https://www.patreon.com/Reedandweep https://www.patreon.com/user?u=3204144],
        display_name: "ReedandWeep",
        username: "Reedandweep",
        tag_name: "reedandweep",
        other_names: ["ReedandWeep"],
        tags: [
          ["AWMedia", "https://www.patreon.com/Reedandweep/posts?filters[tag]=AWMedia"],
        ],
        dtext_artist_commentary_title: "Free post!",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "haruhisky",
        username: "haruhisky",
        tag_name: "haruhisky",
        other_names: ["haruhisky"],
        tags: [
          ["Sailor Moon", "https://www.patreon.com/haruhisky/posts?filters[tag]=Sailor Moon"],
        ],
        dtext_artist_commentary_title: "#sailormoonredraw",
        dtext_artist_commentary_desc: "",
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
        display_name: "haruhisky",
        username: "haruhisky",
        tag_name: "haruhisky",
        other_names: ["haruhisky"],
        tags: [
          ["FGO", "https://www.patreon.com/haruhisky/posts?filters[tag]=FGO"],
        ],
        dtext_artist_commentary_title: "Ishtar (FGO)",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "Koveliana",
        username: "koveliana",
        tag_name: "koveliana",
        other_names: ["Koveliana"],
        tags: [],
        dtext_artist_commentary_title: "Precious Metal [ych]",
        dtext_artist_commentary_desc: "+3 outfits ^_^",
      )
    end

    context "A post that is hidden because it is under review by Patreon" do
      strategy_should_work(
        "https://www.patreon.com/posts/56127163",
        image_urls: [],
        media_files: [],
        page_url: "https://www.patreon.com/posts/56127163",
        profile_url: "https://www.patreon.com/Rumblekatt",
        profile_urls: %w[https://www.patreon.com/Rumblekatt https://www.patreon.com/user?u=647065],
        display_name: "Katrina Sass",
        username: "Rumblekatt",
        tag_name: "rumblekatt",
        other_names: ["Katrina Sass", "Rumblekatt"],
        tags: [
          ["poll", "https://www.patreon.com/Rumblekatt/posts?filters[tag]=poll"],
          ["print", "https://www.patreon.com/Rumblekatt/posts?filters[tag]=print"],
          ["printable", "https://www.patreon.com/Rumblekatt/posts?filters[tag]=printable"],
        ],
        dtext_artist_commentary_title: "September Printable!!",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A public post with a poll" do
      strategy_should_work(
        "https://www.patreon.com/posts/october-art-140055441",
        image_urls: [],
        page_url: "https://www.patreon.com/posts/october-art-140055441",
        profile_urls: %w[https://www.patreon.com/Minhart https://www.patreon.com/user?u=185721414],
        display_name: "Min",
        username: "Minhart",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "October Art",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Hi guys!!

          I'm preparing next month art wooo! Maybe it'll be a challenge again🤔 Not sure yet, I was thinking of making it halloween themed.

          Let me know if it should be Raora again (haha) or someone else!

          h6. Poll: October Art

          * Draw Raora (yes again)
          * Draw someone else (let me know!)
        EOS
      )
    end

    context "A public posts with a commentary with lists and inline formatting" do
      strategy_should_work(
        "https://www.patreon.com/posts/closed-color-139862716",
        image_urls: [
          %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/139862716/2f3f875e393c40aea6ce07488ffa180b/eyJhIjoxLCJwIjoxfQ%3D%3D/1.jpg\?token-hash=.*&token-time=.*},
          %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/139862716/bb29955bc9c9489697b24340161739a1/eyJhIjoxLCJwIjoxfQ%3D%3D/1.jpg\?token-hash=.*&token-time=.*},
          %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/139862716/a3cf3e5919d84acbb7c15e579255e1c1/eyJhIjoxLCJwIjoxfQ%3D%3D/1.jpg\?token-hash=.*&token-time=.*},
          %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/139862716/26c6912241714bf4996164ed8edf71b2/eyJhIjoxLCJwIjoxfQ%3D%3D/1.png\?token-hash=.*&token-time=.*},
        ],
        media_files: [
          { file_size: 839_212 },
          { file_size: 1_940_488 },
          { file_size: 973_281 },
          { file_size: 4_168_265 },
        ],
        page_url: "https://www.patreon.com/posts/closed-color-139862716",
        profile_url: "https://www.patreon.com/PI_Art314",
        profile_urls: %w[https://www.patreon.com/PI_Art314 https://www.patreon.com/user?u=168690901],
        display_name: "Pi",
        username: "PI_Art314",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "(Closed) 🖌 Color Sketch Commissions 🎨✨",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          [i]All slots are now filled — thank you so much for your support![/i] 🥰🙏✨

          Hello everyone!

          Thank you for waiting 🥰 Commissions are now open!

          This time, I’m offering [b]color sketch commissions[/b]:

          * One character only
          * No background
          * A bit rougher finish compared to my usual works
          * [b]Pose cannot be revised[/b] (I will provide several pose options, and you may choose from them)

          💲 [b]Pricing[/b]

          * Thigh-up: $250
          * Full-body: $300

          ⏰ [b]Slots[/b]

          [s]Limited to 3 slots only (first come, first served)[/s]

          📩 [b]How to Apply[/b]

          If you would like to participate, please [b]switch to the “Color Sketch Commission (Half-body)” plan[/b].

          * Half-body: $250
          * For Full-body, please add $50 (for a total of $300) when you join.

          After confirming your subscription, please [b]contact me via Patreon message or Discord DM[/b].
          After that, I will deliver the sketches and the finished illustration [b]via Discord DM or Dropbox[/b].

          👉 [b]Apply here:[/b]
          [s]<https://www.patreon.com/checkout/PI_Art314?rid=26956166>[/s]

          💡 [b]Note[/b]

          Once your commission is confirmed, you may [b]cancel the plan afterwards[/b].
          (There is no need to keep paying every month, so please don’t worry.)

          Sexy themes are welcome within the following limits:

          * ❌ No depiction of nipples
          * ❌ No genitals or sexual acts

          Other Notes

          * Commercial use is prohibited.
          * Personal use, such as posting on social media, is permitted.
          * Illustrations created for commissions may be shared on social media and other platforms.
          * Commissioned illustrations may be further modified to create other works.

          I look forward to your requests! 🖌🥰🎨✨
        EOS
      )
    end

    context "A public post with a commentary with headings and quotes" do
      strategy_should_work(
        "https://www.patreon.com/posts/143480584",
        image_urls: [
          %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/143480584/943aff6d90e84f539161a144a6d2e3b6/eyJhIjoxLCJwIjoxfQ%3D%3D/1.jpg\?token-hash=.*&token-time=.*},
          %r{https://c10.patreonusercontent.com/4/patreon-media/p/post/143480584/e0876ee72822446e863cf16745fc7cf6/eyJhIjoxLCJwIjoxfQ%3D%3D/1.jpg\?token-hash=.*&token-time=.*},
        ],
        media_files: [
          { file_size: 381_670 },
          { file_size: 248_368 },
        ],
        page_url: "https://www.patreon.com/posts/143480584",
        profile_url: "https://www.patreon.com/easonx",
        profile_urls: %w[https://www.patreon.com/easonx https://www.patreon.com/user?u=9961216],
        display_name: "Easonx",
        username: "easonx",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "Ino Yamanaka and  wip..  (October)",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h3. I’m late again, everyone — here are the WIPs for the [b]second[/b] and [b]third[/b] October rewards: [b]Ino Yamanaka[/b] and [b]Kyoka Jiro[/b] (WIP)

          [quote]
          [i]As you can see, there isn’t much time left in November, and I’ll also be traveling with my family for a short trip at the end of the month. Because of that, the November rewards will be paused again, and I will pause the system’s billing for December.[/i]
          [/quote]

          [u]If you joined in [b]November[/b], once I finish all of the October rewards, I will upload them to the shop.[/u]
          [u](For a short period, the shop price will match the Patreon tier.)[/u]

          I know my time management is terrible — thank you so much to everyone who continues to support me. 💖

          --------------------------------------------------------------------------------

          各位我來遲了，這是十月的第二個獎勵與第三個獎勵的WIP 山中井野和耳郎響香(wip)

          *如各位所見，十一月所剩時間不多加上十一月底我要跟家人出去旅行一小段時間，因此十一月獎勵又將暫停一次，我會暫停系統十二月的收款。 如果你是十一月才加入，等我把十月獎勵都完成之後會一起上架至到商店。(上架短時間會與patreon價格相同)

          我知道我的時間控管很差，謝謝每一位願意支持我的人。
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
        display_name: "Kurzgesagt – In a Nutshell",
        username: "Kurzgesagt",
        tag_name: "kurzgesagt",
        other_names: ["Kurzgesagt – In a Nutshell", "Kurzgesagt"],
        tags: [
          ["thank you!", "https://www.patreon.com/Kurzgesagt/posts?filters[tag]=thank you!"],
        ],
        dtext_artist_commentary_title: "Happy Holidays – See you in 12,024!",
        dtext_artist_commentary_desc: <<~EOS.chomp,
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
        display_name: "1041uuu",
        username: "1041uuu",
        tag_name: "1041uuu",
        other_names: ["1041uuu"],
        tags: [],
        dtext_artist_commentary_title: "(announce) SHOP open now !",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deleted or nonexistent post" do
      strategy_should_work(
        "https://www.patreon.com/posts/title-999999999",
        image_urls: [],
        page_url: "https://www.patreon.com/posts/title-999999999",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
