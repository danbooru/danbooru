# frozen_string_literal: true

# @see Source::URL::Pixai
module Source
  class Extractor
    class Pixai < Extractor
      API_URL = "https://api.pixai.art/graphql"
      GRAPHQL_REQUEST = <<-GRAPHQL
        query getArtwork($id: ID!) {
          artwork(id: $id) {
            ...ArtworkBase
          }
        }

        fragment ArtworkBase on Artwork {
          id
          title
          authorId
          authorName
          author {
            ...UserBase
          }
          mediaId
          prompts
          createdAt
          updatedAt
          media {
            ...MediaBase
          }
          isNsfw
          hidePrompts
          tags {
            id
            name
          }
          extra
          likedCount
          liked
          views
          commentCount
        }

        fragment UserBase on User {
          id
          email
          emailVerified
          username
          displayName
          createdAt
          updatedAt
          avatarMedia {
            ...MediaBase
          }
          followedByMe
          followingMe
          followerCount
          followingCount
          isAdmin
        }

        fragment MediaBase on Media {
          id
          type
          width
          height
          urls {
            variant
            url
          }
          imageType
          fileUrl
          duration
          thumbnailUrl
          hlsUrl
          size
        }
      GRAPHQL

      def match?
        Source::URL::Pixai === parsed_url
      end

      def image_urls
        if parsed_url.image_url?
          [parsed_url.full_image_url].compact
        else
          image_url_from_response
        end
      end

      def page_url
        "https://pixai.art/artwork/#{artwork_id}" if artwork_id.present?
      end

      def profile_url
        "https://pixai.art/@#{artist_name}" if artist_name.present?
      end

      def tag_name
        api_response.dig("artwork", "author", "displayName")
      end

      def artist_name
        api_response.dig("artwork", "author", "username")
      end

      def artist_commentary_title
        api_response.dig("artwork", "title")
      end

    def image_url_from_response
        api_response.dig("artwork", "media", "urls").to_a.filter_map do |media|
          media["url"] if media["variant"] == "PUBLIC"
        end
      end

      def api_response
        return {} unless artwork_id.present?

        headers = {
          Referer: "https://pixai.art/",
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36",
        }

        response = http.headers(headers).post(API_URL, json: {
          query: GRAPHQL_REQUEST,
          variables: {
            id: artwork_id,
          }
        })

        return {} unless response.status == 200

        response.parse["data"]
      end

      def artwork_id
        parsed_url.artwork_id || parsed_referer&.artwork_id
      end

      memoize :api_response
    end
  end
end
