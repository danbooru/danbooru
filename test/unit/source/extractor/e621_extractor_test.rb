require "test_helper"

module Source::Tests::Extractor
  class E621ExtractorTest < ActiveSupport::TestCase
    context "A normal post URL" do
      strategy_should_work(
        "https://e621.net/posts/3728701",
        image_urls: %w[https://static1.e621.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png],
        media_files: [{ file_size: 1_563_179 }],
        page_url: "https://e621.net/posts/3728701",
        profile_urls: %w[https://www.pixiv.net/users/1549213 https://www.pixiv.net/stacc/daga2626],
        display_name: "DAGASI",
        username: "daga2626",
        tags: [
          ["acting_like_a_cat", "https://e621.net/posts?tags=acting_like_a_cat"],
          ["ambiguous_feral", "https://e621.net/posts?tags=ambiguous_feral"],
          ["ambiguous_gender", "https://e621.net/posts?tags=ambiguous_gender"],
          ["bath", "https://e621.net/posts?tags=bath"],
          ["blush", "https://e621.net/posts?tags=blush"],
          ["bubble", "https://e621.net/posts?tags=bubble"],
          ["daww", "https://e621.net/posts?tags=daww"],
          ["disembodied_hand", "https://e621.net/posts?tags=disembodied_hand"],
          ["duo", "https://e621.net/posts?tags=duo"],
          ["fangs", "https://e621.net/posts?tags=fangs"],
          ["feral", "https://e621.net/posts?tags=feral"],
          ["fur", "https://e621.net/posts?tags=fur"],
          ["grass", "https://e621.net/posts?tags=grass"],
          ["heart_symbol", "https://e621.net/posts?tags=heart_symbol"],
          ["open_mouth", "https://e621.net/posts?tags=open_mouth"],
          ["plant", "https://e621.net/posts?tags=plant"],
          ["red_blush", "https://e621.net/posts?tags=red_blush"],
          ["soap", "https://e621.net/posts?tags=soap"],
          ["solo_focus", "https://e621.net/posts?tags=solo_focus"],
          ["suds", "https://e621.net/posts?tags=suds"],
          ["teeth", "https://e621.net/posts?tags=teeth"],
          ["uvula", "https://e621.net/posts?tags=uvula"],
          ["dagasi", "https://e621.net/posts?tags=dagasi"],
          ["nintendo", "https://e621.net/posts?tags=nintendo"],
          ["pokemon", "https://e621.net/posts?tags=pokemon"],
          ["generation_9_pokemon", "https://e621.net/posts?tags=generation_9_pokemon"],
          ["pokemon_(species)", "https://e621.net/posts?tags=pokemon_(species)"],
          ["sprigatito", "https://e621.net/posts?tags=sprigatito"],
          ["2022", "https://e621.net/posts?tags=2022"],
          ["digital_media_(artwork)", "https://e621.net/posts?tags=digital_media_(artwork)"],
          ["hi_res", "https://e621.net/posts?tags=hi_res"],
          ["rating:s", "https://e621.net/posts?tags=rating:s"],
        ],
        dtext_artist_commentary_title: "とても良い子に育ちました",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A sample URL" do
      strategy_should_work(
        "https://static1.e926.net/data/preview/6d/1a/6d1a6090ea82c2524212499797e7e53a.jpg",
        image_urls: %w[https://static1.e621.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png],
        media_files: [{ file_size: 1_563_179 }],
        page_url: "https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a",
      )
    end

    context "A self-uploaded post with external source" do
      strategy_should_work(
        "https://e621.net/posts/5497488",
        image_urls: %w[https://static1.e621.net/data/94/c3/94c307b4e9c680f99e85f7cc5c212b58.png],
        media_files: [{ file_size: 376_646 }],
        page_url: "https://e621.net/posts/5497488",
        profile_urls: %w[https://e621.net/users/103838 https://www.deviantart.com/marsminer/ https://inkbunny.net/MarsMiner https://martian-canine.newgrounds.com/ https://twitter.com/MarsMinerNsfw https://marsminersfw.newtumbl.com/ https://marsminernsfw.newtumbl.com/ https://mars-venussfw.tumblr.com/ https://marsminer-venusspring.tumblr.com/ https://foxearedastronaut.tumblr.com/ https://ouremptyworld.tumblr.com/ https://www.furaffinity.net/user/marsminer/ https://beta.furrynetwork.com/otterastronaut/ https://volsk.sofurry.com/ https://twitter.com/xVenusSpringx https://www.facebook.com/marsminervenusspring https://keefkeefthings.tumblr.com/ https://picarto.tv/MarsMiner https://www.twitch.tv/martiancanine https://derpibooru.org/profiles/marsminer https://www.patreon.com/martiancanine https://ko-fi.com/J3J35DMV https://streamlabs.com/MarsMiner https://discord.gg/0zeschOe4893oaue https://www.pillowfort.social/MarsMiner https://twitter.com/martiancanine https://twitter.com/mars_miner https://twitter.com/intent/user?user_id=729707557],
        display_name: "MarsMiner",
        username: "mars_miner",
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "Me assuming many different things that turn out to be wildly false. What an otter clown XD",
      )
    end

    context "A sourceless self-uploaded post" do
      strategy_should_work(
        "https://e621.net/posts/3250507",
        image_urls: %w[https://static1.e621.net/data/21/bc/21bc4c5cb770d6e3d28724b6f2ba3a5e.png],
        media_files: [{ file_size: 765_164 }],
        page_url: "https://e621.net/posts/3250507",
        profile_urls: %w[https://e621.net/users/366015 https://linktr.ee/bnbigus https://bnbigus.tumblr.com https://twitter.com/bnbigus https://www.patreon.com/Bnbigus https://www.furaffinity.net/user/bnbigus https://bnbigus.newgrounds.com https://discord.com/invite/8kpwCUm],
        display_name: nil,
        username: "bnbigus",
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A sourceless second-party post" do
      strategy_should_work(
        "https://e621.net/posts/5311521",
        image_urls: %w[https://static1.e621.net/data/fb/ce/fbce0d0a27d620f37c614ff992b8bc43.png],
        media_files: [{ file_size: 8_275_236 }],
        page_url: "https://e621.net/posts/5311521",
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil,
      )
    end

    context "A login-blocked post" do
      strategy_should_work(
        "https://e621.net/posts/3381431",
        image_urls: %w[https://static1.e621.net/data/8f/89/8f892998f59d7f74ab93abd551acd77d.png],
        media_files: [{ file_size: 2_676_305 }],
        page_url: "https://e621.net/posts/3381431",
        profile_urls: %w[https://inkbunny.net/TobyBaggins https://inkbunny.net/user.php?user_id=539625],
        display_name: nil,
        username: "TobyBaggins",
        dtext_artist_commentary_title: "Before We Start",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Fiadh was so nervous about the upcoming photoshoot that she couldn’t settle down. She kept pacing back and forth so much that Rosine thought the poor doe would collapse. So being the good friend she is, she took Fiadh's hand and told the photographer they would be back soon and led the girl to a private side room. "I am going to show you a relaxing technic before we start the photoshoot. Now take off those clothes, we don't want to get them wrinkled or dirty."

          "Take off my clothes," Fiadh gasp as she went wide eyed!

          A few minutes later, as the photographer was checking the equipment over, he smirked as he heard a loud shuttering moan from the other room. He knew just how well Rosine's "relaxing technic" worked and expected the young model would be glowing when she came out for her set.

          Rosine belongs to "BChalk":[https://inkbunny.net/BChalk]
          Fiadh belongs to me    "TobyBaggins":[https://inkbunny.net/TobyBaggins]
          This stunning work of art is by the wonderful "FoxInShadow":[https://inkbunny.net/FoxInShadow]who also designed both girls.

          --
          I can't wait to get more pictures of Fiadh and write more about her. hehe I hope you enjoy her as much as I do. 💖
        EOS
      )
    end

    context "A post with arttag without artist entry" do
      strategy_should_work(
        "https://e621.net/posts/1857735",
        image_urls: %w[https://static1.e621.net/data/af/2d/af2d4d798faf80f122018a552dde76e6.jpg],
        media_files: [{ file_size: 81_799 }],
        page_url: "https://e621.net/posts/1857735",
        profile_urls: %w[https://twitter.com/Sonicjeremy https://twitter.com/intent/user?user_id=852701820090822656],
        display_name: "JeremySide",
        username: "Sonicjeremy",
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "Spent the last couple days modelin some of the designs from \"@JeremeyChinshue\":[https://twitter.com/JeremeyChinshue]'s \"#somethingseries\":[https://twitter.com/hashtag/somethingseries]. It's one of the funniest video game parodies I've seen and I had a lotta fun making these guys.",
      )
    end
  end
end
