require 'test_helper'

module Sources
  class RedditTest < ActiveSupport::TestCase
    context "A reddit post" do
      strategy_should_work(
        "https://www.reddit.com/gallery/ttyccp",
        image_urls: [
          "https://i.redd.it/p5utgk06ryq81.png",
          "https://i.redd.it/qtdv0k06ryq81.png",
          "https://i.redd.it/0m8f6k06ryq81.png",
          "https://i.redd.it/oc5y8k06ryq81.png",
        ],
        artist_name: "Darksin31",
        profile_url: "https://www.reddit.com/user/Darksin31",
        page_url: "https://www.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/",
        artist_commentary_title: "Maria Nearl Versus the Left-Armed Knight (@dankestsin)"
      )
    end

    context "A reddit post with username instead of subreddit" do
      strategy_should_work(
        "https://www.reddit.com/user/blank_page_drawings/comments/nfjz0d/a_sleepy_orc/",
        image_urls: ["https://i.redd.it/ruh00hxilxz61.png"],
        page_url: "https://www.reddit.com/user/blank_page_drawings/comments/nfjz0d/a_sleepy_orc/",
        artist_commentary_title: "A sleepy orc",
        profile_url: "https://www.reddit.com/user/blank_page_drawings"
      )
    end

    context "A reddit post with an external image" do
      strategy_should_work(
        "https://www.reddit.com/r/baramanga/comments/n9cgs3/you_can_now_find_me_on_twitter_too_blankpage/",
        image_urls: ["https://external-preview.redd.it/VlT1G4JoqAmP_7DG5UKRCJP8eTRef7dCrRvu2ABm_Xg.png?auto=webp&v=enabled&s=65794505bc32d29741d5e1d16fcf3b9be48e50cb"]
      )
    end

    context "A crosspost" do
      strategy_should_work(
        "https://www.reddit.com/gallery/yc0b8g",
        image_urls: ["https://i.redd.it/eao0je8wzlv91.jpg"],
        page_url: "https://www.reddit.com/r/furrymemes/comments/ybr04z/_/",
        profile_url: "https://www.reddit.com/user/lightmare69",
        artist_name: "lightmare69",
        artist_commentary_title: "\u{1FAF5}😐"
      )
    end

    context "An age-restricted post" do
      strategy_should_work(
        "https://www.reddit.com/r/Genshin_Impact/comments/u9zilq/cookie_shinobu",
        image_urls: ["https://i.redd.it/bxh5xkp088v81.jpg"],
        profile_url: "https://www.reddit.com/user/onethingidkwhy",
        artist_name: "onethingidkwhy",
        artist_commentary_title: "cookie shinobu"
      )
    end

    context "A reddit image" do
      strategy_should_work(
        "https://i.redd.it/oc5y8k06ryq81.png",
        image_urls: ["https://i.redd.it/oc5y8k06ryq81.png"],
        download_size: 940_616,
        page_url: nil
      )
    end

    context "A reddit image sample" do
      strategy_should_work(
        "https://preview.redd.it/qtdv0k06ryq81.png?width=960&crop=smart&auto=webp&s=3b1505f76f3c8b7ce47da5ab2dd17c511d3c2a44",
        image_urls: ["https://i.redd.it/qtdv0k06ryq81.png"],
        download_size: 699_898,
        page_url: nil
      )
    end

    context "A redditmedia url" do
      strategy_should_work(
        "https://i.redditmedia.com/9cYFBDQ3QsqWnF9v7EhW5uOcQNHz1Ak9_E1zVNeSLek.png?s=6fee1bb56e7d926847dc3ece01a1ffd4",
        image_urls: ["https://i.redditmedia.com/9cYFBDQ3QsqWnF9v7EhW5uOcQNHz1Ak9_E1zVNeSLek.png?s=6fee1bb56e7d926847dc3ece01a1ffd4"]
      )
    end

    context "An external preview url" do
      strategy_should_work(
        "https://external-preview.redd.it/92G2gkb545UNlA-PywJqM_F-4TT0xngvmf_gb9sFDqk.jpg?auto=webp&s=0f1e3d0603dbaabe1ead7352202d0de1653d76f6",
        image_urls: ["https://external-preview.redd.it/92G2gkb545UNlA-PywJqM_F-4TT0xngvmf_gb9sFDqk.jpg?auto=webp&s=0f1e3d0603dbaabe1ead7352202d0de1653d76f6"]
      )
    end

    context "Reddit:" do
      should "Parse Reddit URLs correctly" do
        assert(Source::URL.image_url?("https://i.redd.it/p5utgk06ryq81.png"))
        assert(Source::URL.image_url?("https://preview.redd.it/qoyhz3o8yde71.jpg?width=1440&format=pjpg&auto=webp&s=5cbe3b0b097d6e7263761c461dae19a43038db22"))
        assert(Source::URL.image_url?("https://external-preview.redd.it/92G2gkb545UNlA-PywJqM_F-4TT0xngvmf_gb9sFDqk.jpg?auto=webp&s=0f1e3d0603dbaabe1ead7352202d0de1653d76f6"))
        assert(Source::URL.image_url?("https://g.redditmedia.com/f-OWw5C5aVumPS4HXVFhTspgzgQB4S77mO-6ad0rzpg.gif?fm=mp4&mp4-fragmented=false&s=ed3d767bf3b0360a50ddd7f503d46225"))
        assert(Source::URL.image_url?("https://i.redditmedia.com/9cYFBDQ3QsqWnF9v7EhW5uOcQNHz1Ak9_E1zVNeSLek.png?s=6fee1bb56e7d926847dc3ece01a1ffd4"))

        assert(Source::URL.page_url?("https://www.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/"))
        assert(Source::URL.page_url?("https://old.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/"))
        assert(Source::URL.page_url?("https://i.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/"))
        assert(Source::URL.page_url?("https://www.reddit.com/r/arknights/comments/ttyccp/"))
        assert(Source::URL.page_url?("https://www.reddit.com/comments/ttyccp"))
        assert(Source::URL.page_url?("https://www.reddit.com/gallery/ttyccp"))
        assert(Source::URL.page_url?("https://www.reddit.com/ttyccp"))
        assert(Source::URL.page_url?("https://redd.it/ttyccp"))

        assert(Source::URL.profile_url?("https://www.reddit.com/user/xSlimes"))
        assert(Source::URL.profile_url?("https://www.reddit.com/u/Valshier"))
      end
    end
  end
end
