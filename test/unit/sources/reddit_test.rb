require 'test_helper'

module Sources
  class RedditTest < ActiveSupport::TestCase
    context "A reddit gallery post" do
      strategy_should_work(
        "https://www.reddit.com/gallery/ttyccp",
        image_urls: [
          "https://i.redd.it/p5utgk06ryq81.png",
          "https://i.redd.it/qtdv0k06ryq81.png",
          "https://i.redd.it/0m8f6k06ryq81.png",
          "https://i.redd.it/oc5y8k06ryq81.png",
        ],
        media_files: [
          { file_size: 608_908 },
          { file_size: 699_898 },
          { file_size: 535_822 },
          { file_size: 940_616 },
        ],
        page_url: "https://www.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/",
        profile_url: "https://www.reddit.com/user/Darksin31",
        profile_urls: %w[https://www.reddit.com/user/Darksin31],
        artist_name: "Darksin31",
        tag_name: "darksin31",
        other_names: ["Darksin31"],
        tags: [
          ["OC Fanart", "https://www.reddit.com/r/arknights/?f=flair_name:\"OC Fanart\""],
        ],
        dtext_artist_commentary_title: "Maria Nearl Versus the Left-Armed Knight (@dankestsin)",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A reddit multi-image post" do
      strategy_should_work(
        "https://www.reddit.com/r/leagueoflegends/comments/e7yzhe/pulling_ahris_cheeks/",
        image_urls: %w[
          https://i.redd.it/hpe45fcwzg341.jpg
          https://i.redd.it/3edn5rjvzg341.png
          https://i.redd.it/7yydis0zxg341.png
        ],
        media_files: [
          { file_size: 397_084 },
          { file_size: 478_971 },
          { file_size: 501_993 },
        ],
        page_url: "https://www.reddit.com/r/leagueoflegends/comments/e7yzhe/pulling_ahris_cheeks/",
        profile_url: "https://www.reddit.com/user/MelancholicMelanie",
        profile_urls: %w[https://www.reddit.com/user/MelancholicMelanie],
        artist_name: "MelancholicMelanie",
        tag_name: "melancholicmelanie",
        other_names: ["MelancholicMelanie"],
        tags: [],
        dtext_artist_commentary_title: "Pulling Ahri's Cheeks",
        dtext_artist_commentary_desc: <<~EOS.chomp
          I found these adorable drawings on Tumblr. If you find any more like these please send them my way :3

          "[image]":[https://i.redd.it/hpe45fcwzg341.jpg]

          "[image]":[https://i.redd.it/3edn5rjvzg341.png]

          "[image]":[https://i.redd.it/7yydis0zxg341.png]
        EOS
      )
    end

    context "A reddit post with username instead of subreddit" do
      strategy_should_work(
        "https://www.reddit.com/user/blank_page_drawings/comments/nfjz0d/a_sleepy_orc/",
        image_urls: %w[https://i.redd.it/ruh00hxilxz61.png],
        media_files: [{ file_size: 1_837_090 }],
        page_url: "https://www.reddit.com/user/blank_page_drawings/comments/nfjz0d/a_sleepy_orc/",
        profile_url: "https://www.reddit.com/user/blank_page_drawings",
        profile_urls: %w[https://www.reddit.com/user/blank_page_drawings],
        artist_name: "blank_page_drawings",
        tag_name: "blank_page_drawings",
        other_names: ["blank_page_drawings"],
        tags: [],
        dtext_artist_commentary_title: "A sleepy orc",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A reddit post with an external image" do
      strategy_should_work(
        "https://www.reddit.com/r/baramanga/comments/n9cgs3/you_can_now_find_me_on_twitter_too_blankpage/",
        image_urls: %w[https://external-preview.redd.it/VlT1G4JoqAmP_7DG5UKRCJP8eTRef7dCrRvu2ABm_Xg.png?auto=webp&s=6510f9f0a69563988aed7af04f750f92fc35f629],
        media_files: [{ file_size: 1_008_084 }],
        page_url: "https://www.reddit.com/r/baramanga/comments/n9cgs3/you_can_now_find_me_on_twitter_too_blankpage/",
        profile_url: "https://www.reddit.com/user/blank_page_drawings",
        profile_urls: %w[https://www.reddit.com/user/blank_page_drawings],
        artist_name: "blank_page_drawings",
        tag_name: "blank_page_drawings",
        other_names: ["blank_page_drawings"],
        tags: [
          ["Non-Explicit", "https://www.reddit.com/r/baramanga/?f=flair_name:\"Non-Explicit\""],
          ["nsfw", "https://www.reddit.com/r/baramanga/?f=flair_name:\"nsfw\""],
        ],
        dtext_artist_commentary_title: "You can now find me on Twitter too ! (@blankpage_)",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A crosspost" do
      strategy_should_work(
        "https://www.reddit.com/gallery/yc0b8g",
        image_urls: [],
        page_url: "https://www.reddit.com/r/MonsterMusume/comments/yc0b8g/rachnera_moment/",
        profile_url: nil,
        profile_urls: [],
        artist_name: nil,
        tag_name: nil,
        other_names: [],
        tags: [
          ["Meme/Shitpost", "https://www.reddit.com/r/MonsterMusume/?f=flair_name:\"Meme%2FShitpost\""],
        ],
        dtext_artist_commentary_title: "Rachnera moment",
        dtext_artist_commentary_desc: ""
      )
    end

    context "An age-restricted post" do
      strategy_should_work(
        "https://www.reddit.com/r/Genshin_Impact/comments/u9zilq/cookie_shinobu",
        image_urls: %w[https://i.redd.it/bxh5xkp088v81.jpg],
        media_files: [{ file_size: 490_282 }],
        page_url: "https://www.reddit.com/r/Genshin_Impact/comments/u9zilq/cookie_shinobu/",
        profile_url: "https://www.reddit.com/user/onethingidkwhy",
        profile_urls: %w[https://www.reddit.com/user/onethingidkwhy],
        artist_name: "onethingidkwhy",
        tag_name: "onethingidkwhy",
        other_names: ["onethingidkwhy"],
        tags: [
          ["OC", "https://www.reddit.com/r/Genshin_Impact/?f=flair_name:\"OC\""],
          ["nsfw", "https://www.reddit.com/r/Genshin_Impact/?f=flair_name:\"nsfw\""],
        ],
        dtext_artist_commentary_title: "cookie shinobu",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A post from a banned subreddit" do
      strategy_should_work(
        "https://www.reddit.com/r/ArknightsHQ/comments/qoy11i/utages_beauty/",
        image_urls: [],
        page_url: "https://www.reddit.com/r/ArknightsHQ/comments/qoy11i/utages_beauty",
        profile_urls: [],
        artist_name: nil,
        tag_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A reddit image" do
      strategy_should_work(
        "https://i.redd.it/oc5y8k06ryq81.png",
        image_urls: ["https://i.redd.it/oc5y8k06ryq81.png"],
        media_files: [{ file_size: 940_616 }],
        page_url: nil
      )
    end

    context "A reddit image sample" do
      strategy_should_work(
        "https://preview.redd.it/qtdv0k06ryq81.png?width=960&crop=smart&auto=webp&s=3b1505f76f3c8b7ce47da5ab2dd17c511d3c2a44",
        image_urls: ["https://i.redd.it/qtdv0k06ryq81.png"],
        media_files: [{ file_size: 699_898 }],
        page_url: nil
      )
    end

    context "A redditmedia url" do
      strategy_should_work(
        "https://i.redditmedia.com/9cYFBDQ3QsqWnF9v7EhW5uOcQNHz1Ak9_E1zVNeSLek.png?s=6fee1bb56e7d926847dc3ece01a1ffd4",
        image_urls: ["https://i.redditmedia.com/9cYFBDQ3QsqWnF9v7EhW5uOcQNHz1Ak9_E1zVNeSLek.png?s=6fee1bb56e7d926847dc3ece01a1ffd4"],
        media_files: [{ file_size: 248_843 }],
        page_url: nil
      )
    end

    context "An external preview url" do
      strategy_should_work(
        "https://external-preview.redd.it/92G2gkb545UNlA-PywJqM_F-4TT0xngvmf_gb9sFDqk.jpg?auto=webp&s=0f1e3d0603dbaabe1ead7352202d0de1653d76f6",
        image_urls: ["https://external-preview.redd.it/92G2gkb545UNlA-PywJqM_F-4TT0xngvmf_gb9sFDqk.jpg?auto=webp&s=0f1e3d0603dbaabe1ead7352202d0de1653d76f6"],
        media_files: [{ file_size: 568_366 }],
        page_url: nil
      )
    end

    context "A reddit.com/media non-sample url" do
      strategy_should_work(
        "https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fds05uzmtd6d61.jpg",
        image_urls: ["https://i.redd.it/ds05uzmtd6d61.jpg"],
        media_files: [{ size: 248_183 }],
        page_url: nil
      )
    end

    context "A reddit.com/media sample url" do
      strategy_should_work(
        "https://www.reddit.com/media?url=https%3A%2F%2Fpreview.redd.it%2Fz90lvr65c11a1.jpg%3Fwidth%3D2569%26format%3Dpjpg%26auto%3Dwebp%26s%3D9a81537379db979c285e44b64a548014c45c6cc9",
        image_urls: ["https://i.redd.it/z90lvr65c11a1.jpg"],
        media_files: [{ size: 820_454 }],
        page_url: nil
      )
    end

    context "A reddit mobile app share url" do
      strategy_should_work(
        "https://www.reddit.com/r/tales/s/RtMDlrF5yo",
        image_urls: %w[https://i.redd.it/ds05uzmtd6d61.jpg],
        media_files: [{ file_size: 248_183 }],
        page_url: "https://www.reddit.com/r/tales/comments/l3oi00/drew_sheena_for_someone_after_a_long_art_block/",
        profile_url: "https://www.reddit.com/user/aelgis",
        profile_urls: %w[https://www.reddit.com/user/aelgis],
        artist_name: "aelgis",
        tag_name: "aelgis",
        other_names: ["aelgis"],
        tags: [
          ["Fan Art", "https://www.reddit.com/r/tales/?f=flair_name:\"Fan Art\""],
        ],
        dtext_artist_commentary_title: "Drew Sheena for someone after a long art block :')",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A www.redditmedia.com/mediaembed/ URL" do
      strategy_should_work(
        "https://www.redditmedia.com/mediaembed/wi4nfq",
        image_urls: [],
        page_url: "https://www.reddit.com/r/nier/comments/wi4nfq/i_rebuilt_2bs_room_in_blender_and_made_ultrawide/",
        profile_url: "https://www.reddit.com/user/magisterium_art",
        profile_urls: %w[https://www.reddit.com/user/magisterium_art],
        artist_name: "magisterium_art",
        tag_name: "magisterium_art",
        other_names: ["magisterium_art"],
        tags: [
          ["Fanart", "https://www.reddit.com/r/nier/?f=flair_name:\"Fanart\""],
        ],
        dtext_artist_commentary_title: "I rebuilt 2B's room in Blender and made ultrawide and 4K wallpapers out of it.",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A reddit comment URL" do
      strategy_should_work(
        "https://www.reddit.com/r/BocchiTheRock/comments/1cruel0/comment/l43980q/",
        image_urls: %w[https://i.redd.it/tvapvd0fph0d1.png],
        media_files: [{ file_size: 1_763_231 }],
        page_url: "https://www.reddit.com/r/BocchiTheRock/comments/1cruel0/thank_you_for_the_great_responses_to_my_seika/",
        profile_url: "https://www.reddit.com/user/-Thu-",
        profile_urls: %w[https://www.reddit.com/user/-Thu-],
        artist_name: "-Thu-",
        tag_name: "thu",
        other_names: ["-Thu-"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp
          How about some education from her instead?
        EOS
      )
    end

    context "A reddit comment image URL" do
      strategy_should_work(
        "https://preview.redd.it/thank-you-for-the-great-responses-to-my-seika-drawings-here-v0-tvapvd0fph0d1.png?width=2549&format=png&auto=webp&s=115a8f1c99df4a0ddb8c61f769a28548abe4ee17",
        image_urls: %w[https://i.redd.it/tvapvd0fph0d1.png],
        media_files: [{ file_size: 1_763_231 }],
        page_url: nil
      )
    end

    context "A reddit post with rich text commentary" do
      strategy_should_work(
        "https://www.reddit.com/r/grandorder/comments/1cnaruv/cerejeira_relaxing_commission/",
        image_urls: %w[https://i.redd.it/vsdab04cq8zc1.jpeg],
        media_files: [{ file_size: 294_559 }],
        page_url: "https://www.reddit.com/r/grandorder/comments/1cnaruv/cerejeira_relaxing_commission/",
        profile_url: "https://www.reddit.com/user/Yatsu003",
        profile_urls: %w[https://www.reddit.com/user/Yatsu003],
        artist_name: "Yatsu003",
        tag_name: "yatsu003",
        other_names: ["Yatsu003"],
        tags: [
          ["Fluff", "https://www.reddit.com/r/grandorder/?f=flair_name:\"Fluff\""],
        ],
        dtext_artist_commentary_title: "Cerejeira relaxing (commission)",
        dtext_artist_commentary_desc: <<~EOS.chomp
          Just imagine her taking a load off after a stressful day.

          Artist: @kyriamask
        EOS
      )
    end

    context "A reddit post with a complex commentary with embedded images" do
      strategy_should_work(
        "https://www.reddit.com/r/LearnToReddit/comments/qgk0nt/how_to_format_posts_and_comments/",
        image_urls: %w[
          https://i.redd.it/6elegzumuvv71.png
          https://i.redd.it/ijov1js0vvv71.png
          https://i.redd.it/5jhkl2o4vvv71.png
          https://i.redd.it/q9m395duxvv71.png
        ],
        media_files: [
          { file_size: 44_817 },
          { file_size: 5_319 },
          { file_size: 14_496 },
          { file_size: 3_996 },
        ],
        page_url: "https://www.reddit.com/r/LearnToReddit/comments/qgk0nt/how_to_format_posts_and_comments/",
        profile_url: "https://www.reddit.com/user/SolariaHues",
        profile_urls: %w[https://www.reddit.com/user/SolariaHues],
        artist_name: "SolariaHues",
        tag_name: "solariahues",
        other_names: ["SolariaHues"],
        tags: [
          ["LTR Guide", "https://www.reddit.com/r/LearnToReddit/?f=flair_name:\"LTR Guide\""],
        ],
        dtext_artist_commentary_title: "How to format posts and comments",
        dtext_artist_commentary_desc: <<~EOS.chomp
          h1. Formatting in new Reddit

          [b]In new Reddit[/b] the 'Fancy pants editor' is the default mode for post and comment creation and means you can use the formatting buttons, though you can switch to markdown mode if you wish (more on that below).

          This image shows the formatting bar and the button to switch to markdown mode.

          "[image]":[https://i.redd.it/6elegzumuvv71.png]

          And you can switch back to Fancy pants too.

          "[image]":[https://i.redd.it/ijov1js0vvv71.png]

          Each button does something different. Hover your pointer over them to see what they do.

          "[image]":[https://i.redd.it/5jhkl2o4vvv71.png]

          In order the formatting buttons are:

          Bold, Italics, Link, Strikethrough, Inline code, Superscript, Spoiler, Heading, Bullets, Numbered bullets, quote, Code block, Table, Image, Video.

          They work much like the formatting buttons in a Word document editor.

          h1. Markdown formatting

          [b]In old Reddit, on mobile, or markdown mode[/b] you'll need to use the Markdown language to format your posts and comments (some 3rd party mobile apps for Reddit have a few formatting buttons).

          In old Reddit there is a Formatting help button which brings up some formatting options to help you.

          "[image]":[https://i.redd.it/q9m395duxvv71.png]

          Here are some common uses:

          [i]Italics[/i] are created using single asterix around the word you wish to italicise [code]*italics*[/code]

          [b]Bold[/b] is the same but with double the asterix’ [code]**Bold**[/code]

          For lists use an asterix, plus, or minus as your bullet points [code]+ List item[/code]

          * List item 1
          * List item 2

          For spoilers, use [code]>!spoiler!<[/code] which becomes [spoiler]spoiler[/spoiler] <--click or tap

          (make sure not to leave a space between [code]>![/code] and your text or the formatting won't work correctly for those viewing old.reddit)

          To insert a link use [code][link]([/code]<https://www.reddit.com/wiki/markdown>[code])[/code] , which becomes: "link":[https://www.reddit.com/wiki/markdown]

          For quotes start the paragraph you're quoting with `>`

          [code]>this is the start of a paragraph[/code]

          [quote]
          this is the start of a paragraph
          [/quote]

          h2. More markdown

          For further formatting help see: "Reddit's guide":[https://www.reddit.com/wiki/markdown] | "Reddit's commenting guide":[https://www.reddit.com/wiki/commenting] | "Raerth's guide":[https://www.reddit.com/r/raerth/comments/cw70q/reddit_comment_formatting/] | "Markdown primer":[https://www.reddit.com/r/reddit.com/comments/6ewgt/reddit_markdown_primer_or_how_do_you_do_all_that/c03nik6/] | "Preview your post":[https://redditpreview.com/]

          [b]Or to tag another Redditor or subreddit:[/b]

          For Subreddits, you start with r/ and fill in the sub name and it automatically links to the subreddit

          For usernames, you use u/ in the same way, similar to using @ on Twitter.

          For example <https://www.reddit.com/r/NewToReddit/> or <https://www.reddit.com/user/llamageddon01/>

          ---

          Edit - "our guide to sharing code using formatting":[https://www.reddit.com/r/LearnToReddit/comments/yynumu/how_to_share_code/]
        EOS
      )
    end

    context "Reddit:" do
      should "Parse Reddit URLs correctly" do
        assert(Source::URL.image_url?("https://i.redd.it/p5utgk06ryq81.png"))
        assert(Source::URL.image_url?("https://preview.redd.it/qoyhz3o8yde71.jpg?width=1440&format=pjpg&auto=webp&s=5cbe3b0b097d6e7263761c461dae19a43038db22"))
        assert(Source::URL.image_url?("https://preview.redd.it/thank-you-for-the-great-responses-to-my-seika-drawings-here-v0-tvapvd0fph0d1.png?width=2549&format=png&auto=webp&s=115a8f1c99df4a0ddb8c61f769a28548abe4ee17"))
        assert(Source::URL.image_url?("https://external-preview.redd.it/92G2gkb545UNlA-PywJqM_F-4TT0xngvmf_gb9sFDqk.jpg?auto=webp&s=0f1e3d0603dbaabe1ead7352202d0de1653d76f6"))
        assert(Source::URL.image_url?("https://g.redditmedia.com/f-OWw5C5aVumPS4HXVFhTspgzgQB4S77mO-6ad0rzpg.gif?fm=mp4&mp4-fragmented=false&s=ed3d767bf3b0360a50ddd7f503d46225"))
        assert(Source::URL.image_url?("https://i.redditmedia.com/9cYFBDQ3QsqWnF9v7EhW5uOcQNHz1Ak9_E1zVNeSLek.png?s=6fee1bb56e7d926847dc3ece01a1ffd4"))
        assert(Source::URL.image_url?("https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fds05uzmtd6d61.jpg"))

        assert(Source::URL.page_url?("https://www.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/"))
        assert(Source::URL.page_url?("https://old.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/"))
        assert(Source::URL.page_url?("https://i.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/"))
        assert(Source::URL.page_url?("https://www.reddit.com/r/arknights/comments/ttyccp/"))
        assert(Source::URL.page_url?("https://www.reddit.com/comments/ttyccp"))
        assert(Source::URL.page_url?("https://www.reddit.com/gallery/ttyccp"))
        assert(Source::URL.page_url?("https://www.reddit.com/ttyccp"))
        assert(Source::URL.page_url?("https://redd.it/ttyccp"))
        assert(Source::URL.page_url?("https://www.reddit.com/r/tales/s/RtMDlrF5yo"))
        assert(Source::URL.page_url?("https://www.redditmedia.com/mediaembed/wi4nfq"))
        assert(Source::URL.page_url?("https://www.reddit.com/r/BocchiTheRock/comments/1cruel0/comment/l43980q/"))
        assert(Source::URL.page_url?("https://www.reddit.com/comments/1cruel0/comment/l43980q/"))

        assert(Source::URL.profile_url?("https://www.reddit.com/user/xSlimes"))
        assert(Source::URL.profile_url?("https://www.reddit.com/u/Valshier"))
      end
    end
  end
end
