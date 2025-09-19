# frozen_string_literal: true

module Source
  class URL
    class Mihuashi < Source::URL
      attr_reader :username, :user_id, :work_id, :stall_id, :project_id, :character_id, :full_image_url

      def self.match?(url)
        url.domain == "mihuashi.com"
      end

      def parse
        case [subdomain, domain, *path_segments]
        
        # https://image-assets.mihuashi.com/permanent/29105|-2024/05/29/16/FuE-9jWo-aPKXOq2KP2ZsR5Nxnqa.jpg
        # https://image-assets.mihuashi.com/permanent/2521440|-2025/07/12/18/lmmkwWRHf4RwLdm3mRanVRNUk2Oy_1123.png
        # https://image-assets.mihuashi.com/permanent/29105|-2025/05/30/15/Flz917NRVbHcZeG9xW1KklVM_s3y_1046.jpg!artwork.detail
        # https://image-assets.mihuashi.com/permanent/1434430|-2024/10/29/10/FoqjZ9N00zu6cT9OgmDPnSCYjAiQ_0140.jpg!artwork.square
        # https://image-assets.mihuashi.com/permanent/5716548|-2025/07/11/20/lrItT-MRSxSjnXvyD5CNze8JucPI_2129.png!mobile.square.large
        # https://image-assets.mihuashi.com/permanent/3684329|-2025/05/17/17/liJ2bnv1jJYdC5AihIPXobAmpeue_3326.jpg!w600.1x
        # https://image-assets.mihuashi.com/permanent/3684329|-2025/05/18/12/Fk7FRRsUA6QW80rthbEJULPuA5nQ_5546.jpg!sq300.2x
        # https://image-assets.mihuashi.com/pfop/permanent/4329541|-2024/07/12/18/Fu2oKtHkplA-waTASBzUpF6EozkB.jpg
        in "image-assets", "mihuashi.com", *, "permanent", /^(\d+)\|-\d{4}$/ => dir, /^\d{2}$/, /^\d{2}$/, /^\d{2}$/, /^([A-Za-z0-9_-]{28,}\.\w+)(?:!.+)?$/ => file
          @full_image_url = to_s.split("!").first.gsub("pfop/", "")
          @user_id = dir.match(/^(\d+)\|-\d{4}$/)[1]

        # https://www.mihuashi.com/artworks/15092919
        # https://www.mihuashi.com/artworks/13693110
        in _, "mihuashi.com", "artworks", work_id
          @work_id = work_id

        # https://www.mihuashi.com/stalls/880743
        in _, "mihuashi.com", "stalls", stall_id
          @stall_id = stall_id

        # https://www.mihuashi.com/projects/6380467
        # https://www.mihuashi.com/projects/6380753
        # https://www.mihuashi.com/projects/6401121 (login required)
        in _, "mihuashi.com", "projects", project_id
          @project_id = project_id

        # https://www.mihuashi.com/character-card/13373e0997be5d906df9ce292da8ddf6552a340a
        # https://www.mihuashi.com/character-card/4dc65278776db4741a897d7445f48a6b57ce251c/project
        # https://www.mihuashi.com/character-card/af3843d93dd2754d8f8ab75bf82ee9f02843131a/wardrobes/300790
        in _, "mihuashi.com", "character-card", character_id, *rest
          @character_id = character_id

        # https://www.mihuashi.com/profiles/29105
        # https://www.mihuashi.com/profiles/29105?role=painter
        in _, "mihuashi.com", "profiles", user_id
          @user_id = user_id

        # https://www.mihuashi.com/users/spirtie
        in _, "mihuashi.com", "users", username
          @username = username

        else
          nil
        end
      end

      def image_url?
        subdomain == "image-assets"
      end

      def page_url
        if work_id.present?
          "https://www.mihuashi.com/artworks/#{work_id}"
        elsif stall_id.present?
          "https://www.mihuashi.com/stalls/#{stall_id}"
        elsif project_id.present?
          "https://www.mihuashi.com/projects/#{project_id}"
        elsif character_id.present?
          "https://www.mihuashi.com/character-card/#{character_id}"
        end
      end

      def profile_url
        if username.present?
          "https://www.mihuashi.com/users/#{Danbooru::URL.escape(username)}"
        elsif user_id.present?
          "https://www.mihuashi.com/profiles/#{user_id}"
        end
      end
    end
  end
end
