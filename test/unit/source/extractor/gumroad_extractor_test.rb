require "test_helper"

module Source::Tests::Extractor
  class GumroadExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Gumroad product page url" do
      strategy_should_work(
        "https://shuisongbrush.gumroad.com/l/ambocd",
        page_url: "https://shuisongbrush.gumroad.com/l/ambocd",
        image_urls: %w[
          https://public-files.gumroad.com/ttijiftzbninovvk6af32kxbn5mq
          https://public-files.gumroad.com/df41wk35kqju3xx15udyh0vfs4dk
          https://public-files.gumroad.com/ee952maawt3mrl8f5rnxzt309kqq
          https://public-files.gumroad.com/1571cxz46b9bxfclc4l0xj1nzman
          https://public-files.gumroad.com/dahx7r507saa7jmod0o9jsb5xz8q
          https://public-files.gumroad.com/kbml8kik11mwoo3v6tgqej50ims7
          https://public-files.gumroad.com/09i9nkpjeu4p7q3ef5nkimvn9emy
          https://public-files.gumroad.com/mvrkzjp8o8pg5tk68gjma6qtqufm
        ],
        profile_url: "https://shuisongbrush.gumroad.com",
        display_name: "shuisongbrush水松",
        username: "shuisongbrush",
        tag_name: "shuisongbrush",
        other_names: ["shuisongbrush水松", "shuisongbrush"],
        tags: [],
        artist_commentary_title: "31 Water-Based Marker Brushes for Procreate Complete Workflow Brush Pack Sketch • Line Art • Coloring • Details By Shuisong",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h2. What's Included

          This brush pack includes [b]31 handcrafted Water-Based Marker Brushes[/b] for Procreate, thoughtfully designed to support every stage of the illustration process—from the first sketch to the final details.

          h3. [b]31 Main Brushes[/b]

          * [b]7 Sketch & Line Art Brushes[/b][br]Perfect for sketching, drafting, and clean line work.
          * [b]5 Round Tip Marker Brushes[/b][br]Ideal for smooth coloring, lettering, and expressive strokes.
          * [b]9 Chisel Tip Marker Brushes[/b][br]Great for broad strokes, flat fills, and authentic marker effects.
          * [b]7 Detail & Accent Brushes[/b][br]Designed for highlights, textures, decorative elements, and finishing touches.
          * [b]3 Print Texture Brushes[/b][br]Create realistic print textures, grain, and vintage-style printing effects.

          [hr]

          h3. 🎁 Bonus Freebies

          As a special bonus, you'll also receive:

          * [b]11 High-Resolution Paper Texture Brushes[/b]
          * [b]5 Exclusive Hidden Marker Brushes[/b]

          h2. [b]⚠️ Before Purchasing[/b]

          Please make sure you have one of the following:

          ✓ iPad + Procreate + Apple Pencil

          [b]Commercial Use Policy[/b]

          You are allowed to use artwork created with these brushes for personal and commercial projects.

          However, redistribution, resale, sharing, or transferring the brush files themselves is not permitted.
        EOS
      )
    end

    context "A Gumroad product image url without referer" do
      strategy_should_work(
        "https://public-files.gumroad.com/variants/6hbo93vnwie3ff26u5f4t6bnksm4/baaca0eb0e33dc4f9d45910b8c86623f0144cea0fe0c2093c546d17d535752eb",
        image_urls: ["https://public-files.gumroad.com/6hbo93vnwie3ff26u5f4t6bnksm4"],
        media_files: [{ file_size: 859_625 }],
        page_url: nil,
        profile_url: nil,
        display_name: nil,
        username: nil,
        tags: [],
        artist_commentary_title: nil,
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Gumroad product image url with referer" do
      strategy_should_work(
        "https://public-files.gumroad.com/ttijiftzbninovvk6af32kxbn5mq",
        referer: "https://shuisongbrush.gumroad.com/l/ambocd",
        image_urls: ["https://public-files.gumroad.com/ttijiftzbninovvk6af32kxbn5mq"],
        page_url: "https://shuisongbrush.gumroad.com/l/ambocd",
        profile_url: "https://shuisongbrush.gumroad.com",
        display_name: "shuisongbrush水松",
        username: "shuisongbrush",
        tag_name: "shuisongbrush",
        other_names: ["shuisongbrush水松", "shuisongbrush"],
        tags: [],
        artist_commentary_title: "31 Water-Based Marker Brushes for Procreate Complete Workflow Brush Pack Sketch • Line Art • Coloring • Details By Shuisong",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h2. What's Included

          This brush pack includes [b]31 handcrafted Water-Based Marker Brushes[/b] for Procreate, thoughtfully designed to support every stage of the illustration process—from the first sketch to the final details.

          h3. [b]31 Main Brushes[/b]

          * [b]7 Sketch & Line Art Brushes[/b][br]Perfect for sketching, drafting, and clean line work.
          * [b]5 Round Tip Marker Brushes[/b][br]Ideal for smooth coloring, lettering, and expressive strokes.
          * [b]9 Chisel Tip Marker Brushes[/b][br]Great for broad strokes, flat fills, and authentic marker effects.
          * [b]7 Detail & Accent Brushes[/b][br]Designed for highlights, textures, decorative elements, and finishing touches.
          * [b]3 Print Texture Brushes[/b][br]Create realistic print textures, grain, and vintage-style printing effects.

          [hr]

          h3. 🎁 Bonus Freebies

          As a special bonus, you'll also receive:

          * [b]11 High-Resolution Paper Texture Brushes[/b]
          * [b]5 Exclusive Hidden Marker Brushes[/b]

          h2. [b]⚠️ Before Purchasing[/b]

          Please make sure you have one of the following:

          ✓ iPad + Procreate + Apple Pencil

          [b]Commercial Use Policy[/b]

          You are allowed to use artwork created with these brushes for personal and commercial projects.

          However, redistribution, resale, sharing, or transferring the brush files themselves is not permitted.
        EOS
      )
    end

    context "A Gumroad post page url" do
      strategy_should_work(
        "https://movw2000.gumroad.com/p/new-product-b072093e-e628-4a92-9740-e9b4564d9901",
        page_url: "https://movw2000.gumroad.com/p/new-product-b072093e-e628-4a92-9740-e9b4564d9901",
        image_urls: %w[
          https://public-files.gumroad.com/nztoa76lk2wahffodnxwhqh49tkq
          https://public-files.gumroad.com/2unbiv4p4gysgn1v3n5ah5f9ux9p
        ],
        profile_url: "https://movw2000.gumroad.com",
        display_name: "DAKO",
        username: "movw2000",
        tag_name: "movw2000",
        other_names: ["DAKO", "movw2000"],
        tags: [],
        artist_commentary_title: nil,
        dtext_artist_commentary_desc: <<~EOS.chomp,
          2022 is coming to an end,

          and the products on gumroad will have a 20% discount from now until 12/31.

          Discount code : omuxoke
        EOS
      )
    end
  end
end
