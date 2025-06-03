require "test_helper"

module Source::Tests::URL
  class RedditUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://i.redd.it/p5utgk06ryq81.png",
          "https://preview.redd.it/qoyhz3o8yde71.jpg?width=1440&format=pjpg&auto=webp&s=5cbe3b0b097d6e7263761c461dae19a43038db22",
          "https://preview.redd.it/thank-you-for-the-great-responses-to-my-seika-drawings-here-v0-tvapvd0fph0d1.png?width=2549&format=png&auto=webp&s=115a8f1c99df4a0ddb8c61f769a28548abe4ee17",
          "https://external-preview.redd.it/92G2gkb545UNlA-PywJqM_F-4TT0xngvmf_gb9sFDqk.jpg?auto=webp&s=0f1e3d0603dbaabe1ead7352202d0de1653d76f6",
          "https://g.redditmedia.com/f-OWw5C5aVumPS4HXVFhTspgzgQB4S77mO-6ad0rzpg.gif?fm=mp4&mp4-fragmented=false&s=ed3d767bf3b0360a50ddd7f503d46225",
          "https://i.redditmedia.com/9cYFBDQ3QsqWnF9v7EhW5uOcQNHz1Ak9_E1zVNeSLek.png?s=6fee1bb56e7d926847dc3ece01a1ffd4",
          "https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fds05uzmtd6d61.jpg",
        ],
        page_urls: [
          "https://www.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/",
          "https://old.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/",
          "https://i.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/",
          "https://www.reddit.com/r/arknights/comments/ttyccp/",
          "https://www.reddit.com/comments/ttyccp",
          "https://www.reddit.com/gallery/ttyccp",
          "https://www.reddit.com/ttyccp",
          "https://redd.it/ttyccp",
          "https://www.reddit.com/r/tales/s/RtMDlrF5yo",
          "https://www.redditmedia.com/mediaembed/wi4nfq",
          "https://www.reddit.com/r/BocchiTheRock/comments/1cruel0/comment/l43980q/",
          "https://www.reddit.com/comments/1cruel0/comment/l43980q/",
          "https://old.reddit.com/r/Xenoblade_Chronicles/comments/11etwdd/monolith_soft_2023_brochure_art/jahip48/",
        ],
        profile_urls: [
          "https://www.reddit.com/user/xSlimes",
          "https://www.reddit.com/u/Valshier",
        ],
      )
    end
  end
end
