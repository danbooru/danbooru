# frozen_string_literal: true

module Source
  class URL
    class Reddit < Source::URL
      attr_reader :subreddit, :work_id, :comment_id, :share_id, :title, :username, :full_image_url

      def self.match?(url)
        url.domain.in?(%w[reddit.com redd.it redditmedia.com])
      end

      def parse
        case [subdomain, domain, *path_segments]

        # https://i.redd.it/p5utgk06ryq81.png
        # https://preview.redd.it/qoyhz3o8yde71.jpg?width=1440&format=pjpg&auto=webp&s=5cbe3b0b097d6e7263761c461dae19a43038db22
        # https://preview.redd.it/thank-you-for-the-great-responses-to-my-seika-drawings-here-v0-tvapvd0fph0d1.png?width=2549&format=png&auto=webp&s=115a8f1c99df4a0ddb8c61f769a28548abe4ee17 (image in comment)
        in ("i" | "preview"), "redd.it", _
          @title, _, image_id = filename.rpartition("-")
          @full_image_url = "https://i.redd.it/#{image_id}.#{file_ext}"

        # https://www.reddit.com/media?url=https%3A%2F%2Fi.redd.it%2Fds05uzmtd6d61.jpg
        in _, "reddit.com", "media" if params[:url].present?
          @full_image_url = Source::URL.parse(params[:url]).try(:full_image_url)

        # https://external-preview.redd.it/92G2gkb545UNlA-PywJqM_F-4TT0xngvmf_gb9sFDqk.jpg?auto=webp&s=0f1e3d0603dbaabe1ead7352202d0de1653d76f6
        # https://external-preview.redd.it/VlT1G4JoqAmP_7DG5UKRCJP8eTRef7dCrRvu2ABm_Xg.png?width=1080&crop=smart&auto=webp&s=d074e9cbfcb2780e6ec0d948daff3cadc91c2a50
        # https://g.redditmedia.com/f-OWw5C5aVumPS4HXVFhTspgzgQB4S77mO-6ad0rzpg.gif?fm=mp4&mp4-fragmented=false&s=ed3d767bf3b0360a50ddd7f503d46225
        # https://i.redditmedia.com/9cYFBDQ3QsqWnF9v7EhW5uOcQNHz1Ak9_E1zVNeSLek.png?s=6fee1bb56e7d926847dc3ece01a1ffd4
        # https://b.thumbs.redditmedia.com/1NSCseZgx3HZIHS0IYMJlAJ5QGcBul4O3TDAPh4f6is.jpg
        in *rest if image_url?
        # pass

        # https://www.reddit.com/user/blank_page_drawings/comments/nfjz0d/a_sleepy_orc/
        in _, "reddit.com", ("user" | "u"), username, "comments", work_id, title
          @username = username
          @work_id = work_id
          @title = title

        # https://www.reddit.com/user/xSlimes
        # https://www.reddit.com/u/Valshier
        in _, "reddit.com", ("user" | "u"), username
          @username = username

        # https://www.reddit.com/r/tales/s/RtMDlrF5yo
        in _, "reddit.com", "r", subreddit, "s", share_id
          @subreddit = subreddit
          @share_id = share_id

        # https://www.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/
        # https://old.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/
        # https://i.reddit.com/r/arknights/comments/ttyccp/maria_nearl_versus_the_leftarmed_knight_dankestsin/
        in _, "reddit.com", "r", subreddit, "comments", work_id, title
          @subreddit = subreddit
          @work_id = work_id
          @title = title

        # https://www.reddit.com/r/BocchiTheRock/comments/1cruel0/comment/l43980q/
        in _, "reddit.com", "r", subreddit, "comments", work_id, "comment", comment_id
          @subreddit = subreddit
          @work_id = work_id
          @comment_id = comment_id

        # https://www.reddit.com/r/arknights/comments/ttyccp/
        in _, "reddit.com", "r", subreddit, "comments", work_id
          @subreddit = subreddit
          @work_id = work_id

        # https://www.reddit.com/comments/1cruel0/comment/l43980q/
        in _, "reddit.com", "comments", work_id, "comment", comment_id
          @work_id = work_id
          @comment_id = comment_id

        # https://www.reddit.com/comments/ttyccp
        # https://www.reddit.com/gallery/ttyccp
        in _, "reddit.com", ("comments" | "gallery"), work_id
          @work_id = work_id

        # https://www.reddit.com/ttyccp
        in _, "reddit.com" , work_id
          @work_id = work_id

        # https://www.redditmedia.com/mediaembed/wi4nfq
        in _, "redditmedia.com" , "mediaembed", work_id
          @work_id = work_id

        # https://redd.it/ttyccp
        in nil, "redd.it" , work_id
          @work_id = work_id

        else
          nil
        end
      end

      def extractor_class
        if comment_id.present?
          Source::Extractor::RedditComment
        else
          Source::Extractor::Reddit
        end
      end

      def image_url?
        super || full_image_url.present?
      end

      def page_url
        if subreddit.present? && work_id.present? && title.present?
          "https://www.reddit.com/r/#{subreddit}/comments/#{work_id}/#{title}"
        elsif username.present? && work_id.present? && title.present?
          "https://www.reddit.com/user/#{username}/comments/#{work_id}/#{title}"
        elsif subreddit.present? && work_id.present? && comment_id.present?
          "https://www.reddit.com/r/#{subreddit}/comments/#{work_id}/comment/#{comment_id}"
        elsif subreddit.present? && work_id.present?
          "https://www.reddit.com/r/#{subreddit}/comments/#{work_id}"
        elsif subreddit.present? && share_id.present?
          "https://www.reddit.com/r/#{subreddit}/s/#{share_id}"
        elsif work_id.present? && comment_id.present?
          "https://www.reddit.com/comments/#{work_id}/comment/#{comment_id}"
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
