module Sources
  module Strategies
    class PixivWhitecube < Base
      attr_reader :artist_commentary_title, :artist_commentary_desc, :ugoira_frame_data, :ugoira_content_type

      # sample: http://www.pixiv.net/whitecube/user/277898/illust/59182257
      WHITECUBE_ILLUST = %r!^https?://www\.pixiv\.net/whitecube/user/\d+/illust/\d+!i

      def self.url_match?(url)
        url =~ WHITECUBE_ILLUST
      end

      def referer_url
        @url
      end

      def site_name
        "Pixiv Whitecube"
      end

      def unique_id
        @pixiv_moniker
      end

      def fake_referer
        "http://www.pixiv.net"
      end

      def normalizable_for_artist_finder?
        true
      end

      def normalize_for_artist_finder!
        "http://img.pixiv.net/img/#{@moniker}/"
      end

      def get
        @illust_id = illust_id_from_url
        @data = query_pixiv_api(@illust_id)

        @artist_name = @data.name
        @profile_url = "https://www.pixiv.net/whitecube/user/" + @data.user_id.to_s
        @pixiv_moniker = @data.moniker
        @zip_url, @ugoira_frame_data, @ugoira_content_type = get_zip_url_from_api(@data)
        @tags = @data.tags
        @page_count = @data.page_count
        @artist_commentary_title = @data.artist_commentary_title
        @artist_commentary_desc = @data.artist_commentary_desc

        is_manga = @page_count > 1

        if !@zip_url
          @image_url = @data.pages.first
        end
      end

      def file_url
        @image_url || @zip_url
      end

      def rewrite_thumbnails(url)
        url
      end

      def illust_id_from_url
        # http://www.pixiv.net/whitecube/user/277898/illust/59182257
        if url =~ %r!/whitecube/user/\d+/illust/(\d+)!
          $1

        else
          raise Sources::Error.new("Couldn't get illust ID from URL: #{url}")
        end
      end

      def query_pixiv_api(illust_id)
        @data ||= PixivApiClient.new.works(illust_id)
      end

      def get_zip_url_from_api(data)
        if data.json["metadata"] && data.json["metadata"]["zip_urls"]
          zip_url = data.json["metadata"]["zip_urls"]["ugoira600x600"].sub("_ugoira600x600.zip", "_ugoira1920x1080.zip")
          frame_data = data.json["metadata"]["frames"]

          return [zip_url, frame_data, "image/png"]
        end
      end
    end
  end
end
