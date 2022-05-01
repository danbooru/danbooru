require 'test_helper'

module Sources
  class RedditTest < ActiveSupport::TestCase
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
