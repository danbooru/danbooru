# frozen_string_literal: true

# Source extractor for 4chan.org.
#
# TODO:
#
# * If given only an image URL, scrape the board catalog to find which thread it belongs to.
# * If the thread is expired, scrape data from archive sites.
# * If the image or video is a soundpost, remux the file to include the sound (https://github.com/rcc11/4chan-sounds-player#creating-sound-images)
#
# @see https://github.com/4chan/4chan-API
# @see https://github.com/4chan/4chan-API/blob/master/pages/Threads.md
module Source
  class Extractor
    class FourChan < Source::Extractor
      def image_urls
        if parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        # If this is a post URL, or an image URL for which we can find the post
        elsif post.present? && post["tim"].present? && post["ext"].present?
          ["https://i.4cdn.org/#{board}/#{post["tim"]}#{post["ext"]}"]
        # If this is a thread URL
        elsif thread_id.present? && post_id_from_url.nil?
          api_response.map do |post|
            "https://i.4cdn.org/#{board}/#{post["tim"]}#{post["ext"]}" if post["tim"].present? && post["ext"].present?
          end.compact
        # If this is a thumbnail image URL and we can't get the full image URL from the API
        elsif parsed_url.image_url?
          [url.to_s]
        else
          []
        end
      end

      def page_url
        if board.present? && thread_id.present? && post_id.present?
          "https://#{domain}/#{board}/thread/#{thread_id}#p#{post_id}"
        elsif board.present? && thread_id.present?
          "https://#{domain}/#{board}/thread/#{thread_id}"
        end
      end

      def artist_commentary_title
        if post.present?
          "#{post["name"]}#{post["trip"]} #{post["now"]} No.#{post["no"]}"
        end
      end

      def artist_commentary_desc
        commentary = String.new

        if post["filename"].present?
          commentary << "<a href=\"https://i.4cdn.org/#{board}/#{post["tim"]}#{post["ext"]}\">#{post["filename"]}#{post["ext"]}</a> (#{post["fsize"].to_fs(:human_size)}, #{post["w"]}x#{post["h"]})<br>"
        end

        if post["com"].present?
          commentary << post["com"]
        end

        commentary.presence
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://4chan.org") do |element|
          if element.name == "a" && element["class"] == "quotelink"
            # `<a href="#p1234" class="quotelink">&gt;&gt;1234</a>`
            if element["href"].starts_with?("#")
              element["href"] = "https://#{domain}/#{board}/thread/#{thread_id}#{element["href"]}"
            # `<a href="/vt/thread/1234#p5678" class="quotelink">&gt;&gt;5678</a>`
            elsif element["href"].starts_with?("/")
              element["href"] = "https://#{domain}#{element["href"]}"
            end
          end
        end
      end

      def domain
        if parsed_url.domain in "4chan.org" | "4channel.org"
          "boards.#{parsed_url.domain}"
        elsif parsed_referer&.domain in "4chan.org" | "4channel.org"
          "boards.#{parsed_referer.domain}"
        end
      end

      def board
        parsed_url.board || parsed_referer&.board
      end

      def thread_id
        parsed_url.thread_id || parsed_referer&.thread_id
      end

      def image_id
        parsed_url.image_id || parsed_referer&.image_id
      end

      def post_id
        post_id_from_url || post_id_from_api
      end

      def post_id_from_url
        parsed_url.post_id || parsed_referer&.post_id
      end

      def post_id_from_api
        post["no"]
      end

      memoize def post
        api_response.find do |post|
          (image_id.present? && post["tim"] == image_id) || post["no"] == post_id_from_url
        end.to_h
      end

      memoize def api_response
        http.cache(1.minute).parsed_get(api_url)&.dig(:posts) || []
      end

      def api_url
        "https://a.4cdn.org/#{board}/thread/#{thread_id}.json" if board.present? && thread_id.present?
      end
    end
  end
end
