# frozen_string_literal: true

# @see Source::URL::Mihuashi
module Source
  class Extractor
    class Mihuashi < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        elsif work.present?
          image_url = work[:url]
          [Source::URL.parse(image_url).try(:full_image_url) || image_url]
        elsif stall.present?
          [
            stall[:cover_url],
            *stall[:example_images].to_a,
          ].uniq.map do |url|
            Source::URL.parse(url).try(:full_image_url) || url
          end
        elsif project.present?
          project[:example_images].to_a.pluck(:url).map do |url|
            Source::URL.parse(url).try(:full_image_url) || url
          end
        elsif character_card.present?
          [
            character_card[:image_url],
            *character_card[:example_images].to_a.pluck(:url),
          ].uniq.map do |url|
            Source::URL.parse(url).try(:full_image_url) || url
          end
        elsif activity_work.present?
          activity_work[:images].to_a.pluck(:url).map do |url|
            Source::URL.parse(url).try(:full_image_url) || url
          end
        else
          []
        end
      end

      def page_url
        if work.present?
          "https://www.mihuashi.com/artworks/#{work[:id]}"
        elsif activity_work.present?
          if activity_work[:artwork_type].present?
            "https://www.mihuashi.com/activities/#{a_work_activity}/artworks/#{activity_work[:id]}?type=#{activity_work[:artwork_type]}"
          else
            "https://www.mihuashi.com/activities/#{a_work_activity}/artworks/#{activity_work[:id]}"
          end
        else
          parsed_url.page_url || parsed_referer&.page_url
        end
      end

      def account_url
        "https://www.mihuashi.com/users/#{Danbooru::URL.escape(username)}" if username.present?
      end

      def profile_url
        "https://www.mihuashi.com/profiles/#{user_id}" if user_id.present?
      end

      def profile_urls
        [profile_url, account_url].compact_blank.uniq
      end

      def tags
        if work.present?
          work[:tags].to_a.map do |tag|
            [tag[:name], "https://www.mihuashi.com/search?tab=artwork&q=#{Danbooru::URL.escape(tag[:name])}"]
          end
        else
          []
        end
      end

      def artist_commentary_title
        if stall.present?
          stall[:name]
        elsif project.present?
          project[:name]
        elsif character_card.present?
          character_card[:name]
        elsif activity_work.present?
          activity_work[:title]
        end
      end

      def artist_commentary_desc
        if work.present?
          work[:description]
        elsif stall.present?
          stall.dig(:about, :introduction)
        elsif project.present?
          project.dig(:template, :summary)
        elsif character_card.present?
          character_card[:summary]
        elsif activity_work.present?
          activity_work[:description]
        end
      end

      def user_id
        user[:id] || parsed_url.user_id || parsed_referer&.user_id unless project.present? || character_card.present?
      end

      def username
        user[:name] || parsed_url.username || parsed_referer&.username unless project.present? || character_card.present?
      end

      def other_names
        [username, *name_changelogs].compact_blank.uniq
      end

      def user
        if work.present?
          work[:author]
        elsif stall.present?
          stall[:owner]
        elsif activity_work.present?
          activity_work[:owner]
        else
          {}
        end
      end

      def work_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def stall_id
        parsed_url.stall_id || parsed_referer&.stall_id
      end

      def project_id
        parsed_url.project_id || parsed_referer&.project_id
      end

      def character_id
        parsed_url.character_id || parsed_referer&.character_id
      end

      def a_work_id
        parsed_url.a_work_id || parsed_referer&.a_work_id
      end

      def a_work_activity
        parsed_url.a_work_activity || parsed_referer&.a_work_activity
      end

      memoize def work
        return {} unless work_id.present?

        http.cache(1.minute).parsed_get("https://www.mihuashi.com/api/v1/artworks/#{work_id}/")&.dig(:artwork) || {}
      end

      memoize def stall
        return {} unless stall_id.present?

        http.cookies(aliyungf_tc: tc_cookie).cache(1.minute).parsed_get("https://www.mihuashi.com/api/v1/stalls/#{stall_id}/")&.dig(:stall) || {}
      end

      memoize def project
        return {} unless project_id.present?

        http.cache(1.minute).parsed_get("https://www.mihuashi.com/api/v1/projects/#{project_id}/")&.dig(:project) || {}
      end

      memoize def character_card
        return {} unless character_id.present?

        http.cache(1.minute).parsed_get("https://www.mihuashi.com/api/v1/character_cards/#{character_id}/")&.dig(:character_card) || {}
      end

      memoize def activity_work
        return {} unless a_work_id.present?

        http.cache(1.minute).parsed_get("https://www.mihuashi.com/api/activity/v1/activities/#{a_work_activity}/artworks/#{a_work_id}/")&.dig(:artwork) || {}
      end

      memoize def name_changelogs
        return {} unless user_id.present?

        http.cache(1.minute).parsed_get("https://www.mihuashi.com/api/v1/users/#{user_id}/name_changelogs")&.dig(:name_changelogs).to_a.pluck(:from_name)
      end

      memoize def cookies
        response = http.cache(1.minute).get("https://www.mihuashi.com/api/v1/configure/vacation")
        response.cookies.to_h { |c| [c.name, c.value] }
      end

      def tc_cookie
        cookies["aliyungf_tc"]
      end
    end
  end
end
