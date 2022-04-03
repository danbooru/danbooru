# frozen_string_literal: true

module Source
  class URL
    class Reddit < Source::URL
      attr_reader :subreddit, :work_id, :title, :username

      def self.match?(url)
        url.domain.in?(["reddit.com", "redd.it"])
      end

      def parse
        case [subdomain, domain, *path_segments]

        # https://i.redd.it/p5utgk06ryq81.png
        # https://preview.redd.it/qoyhz3o8yde71.jpg?width=1440&format=pjpg&auto=webp&s=5cbe3b0b097d6e7263761c461dae19a43038db22
        # https://external-preview.redd.it/92G2gkb545UNlA-PywJqM_F-4TT0xngvmf_gb9sFDqk.jpg?auto=webp&s=0f1e3d0603dbaabe1ead7352202d0de1653d76f6
        # https://g.redditmedia.com/f-OWw5C5aVumPS4HXVFhTspgzgQB4S77mO-6ad0rzpg.gif?fm=mp4&mp4-fragmented=false&s=ed3d767bf3b0360a50ddd7f503d46225
        # https://i.redditmedia.com/9cYFBDQ3QsqWnF9v7EhW5uOcQNHz1Ak9_E1zVNeSLek.png?s=6fee1bb56e7d926847dc3ece01a1ffd4
        in *rest if image_url?
          # pass

        # https://www.reddit.com/user/xSlimes
        # https://www.reddit.com/u/Valshier
        in _, "reddit.com", ("user" | "u"), username
          @username = username

        # https://www.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/
        # https://old.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/
        # https://i.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/
        in _, "reddit.com", "r", subreddit, "comments", work_id, title
          @subreddit = subreddit
          @work_id = work_id
          @title = title

        # https://www.reddit.com/r/arknights/comments/ttyccp/
        in _, "reddit.com", "r", subreddit, "comments", work_id
          @subreddit = subreddit
          @work_id = work_id

        # https://www.reddit.com/comments/ttyccp
        # https://www.reddit.com/gallery/ttyccp
        in _, "reddit.com", ("comments" | "gallery"), work_id
          @work_id = work_id

        # https://www.reddit.com/ttyccp
        in _, "reddit.com" , work_id
          @work_id = work_id

        # https://redd.it/ttyccp
        in nil, "redd.it" , work_id
          @work_id = work_id

        else
        end
      end

      def image_url?
        domain == "redditmedia.com" || (domain == "redd.it" && subdomain.in?(%w[i preview external-preview]))
      end

      def page_url
        if subreddit.present? && work_id.present? && title.present?
          "https://www.reddit.com/r/#{subreddit}/comments/#{work_id}/#{title}"
        elsif subreddit.present? && work_id.present?
          "https://www.reddit.com/r/#{subreddit}/comments/#{work_id}"
        elsif work_id.present?
          "https://www.reddit.com/comments/#{work_id}"
        end
      end

      def profile_url
        "https://www.reddit.com/user/#{username}" if username.present?
      end
    end
  end
end
