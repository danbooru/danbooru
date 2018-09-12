require 'csv'

module Sources
  module Strategies
    class Pixiv < Base
      MONIKER = %r!(?:[a-zA-Z0-9_-]+)!
      PROFILE = %r!\Ahttps?://www\.pixiv\.net/member\.php\?id=[0-9]+\z!
      DATE =    %r!(?<date>\d{4}/\d{2}/\d{2}/\d{2}/\d{2}/\d{2})!i
      EXT =     %r!(?:jpg|jpeg|png|gif)!i

      WEB =     %r!(?:\A(?:https?://)?www\.pixiv\.net)!
      I12 =     %r!(?:\A(?:https?://)?i[0-9]+\.pixiv\.net)!
      IMG =     %r!(?:\A(?:https?://)?img[0-9]*\.pixiv\.net)!
      PXIMG =   %r!(?:\A(?:https?://)?i\.pximg\.net)!
      TOUCH =   %r!(?:\A(?:https?://)?touch\.pixiv\.net)!
      UGOIRA =  %r!#{PXIMG}/img-zip-ugoira/img/#{DATE}/(?<illust_id>\d+)_ugoira1920x1080\.zip\z!i
      ORIG_IMAGE = %r!#{PXIMG}/img-original/img/#{DATE}/(?<illust_id>\d+)_p(?<page>\d+)\.#{EXT}\z!i
      STACC_PAGE = %r!\A#{WEB}/stacc/#{MONIKER}/?\z!i
      NOVEL_PAGE = %r!(?:\Ahttps?://www\.pixiv\.net/novel/show\.php\?id=(\d+))!
      FANBOX_ACCOUNT = %r!(?:\Ahttps?://www\.pixiv\.net/fanbox/creator/\d+\z)!
      FANBOX_IMAGE = %r!(?:\Ahttps?://fanbox\.pixiv\.net/images/post/(\d+))!
      FANBOX_PAGE = %r!(?:\Ahttps?://www\.pixiv\.net/fanbox/creator/\d+/post/(\d+))!

      def self.match?(*urls)
        urls.compact.any? { |x| x.match?(/#{WEB}|#{IMG}|#{I12}|#{TOUCH}|#{PXIMG}|#{FANBOX_IMAGE}|#{FANBOX_ACCOUNT}/i) }
      end

      def self.to_dtext(text)
        text = text.gsub(%r!https?://www\.pixiv\.net/member_illust\.php\?mode=medium&illust_id=([0-9]+)!i) do |match|
          pixiv_id = $1
          %(pixiv ##{pixiv_id} "»":[/posts?tags=pixiv:#{pixiv_id}])
        end

        text = text.gsub(%r!https?://www\.pixiv\.net/member\.php\?id=([0-9]+)!i) do |match|
          member_id = $1
          profile_url = "https://www.pixiv.net/member.php?id=#{member_id}"
          search_params = {"search[url_matches]" => profile_url}.to_param

          %("user/#{member_id}":[#{profile_url}] "»":[/artists?#{search_params}])
        end

        text = text.gsub(/\r\n|\r|\n/, "<br>")
        DText.from_html(text)
      end

      def site_name
        "Pixiv"
      end

      def image_urls
        image_urls_sub
      rescue PixivApiClient::BadIDError
        [url]
      end

      def preview_urls
        image_urls.map do |url|
          case url
          when ORIG_IMAGE
            "https://i.pximg.net/c/240x240/img-master/img/#{$~[:date]}/#{$~[:illust_id]}_p#{$~[:page]}_master1200.jpg"
          when UGOIRA
            "https://i.pximg.net/c/240x240/img-master/img/#{$~[:date]}/#{$~[:illust_id]}_master1200.jpg"
          else
            url
          end
        end
      end

      def page_url
        if novel_id.present?
          return "https://www.pixiv.net/novel/show.php?id=#{novel_id}&mode=cover"
        end

        if fanbox_id.present?
          return "https://www.pixiv.net/fanbox/creator/#{metadata.user_id}/post/#{fanbox_id}"
        end

        if fanbox_account_id.present?
          return "https://www.pixiv.net/fanbox/creator/#{fanbox_account_id}"
        end

        if illust_id.present?
          return "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{illust_id}"
        end

        return url

      rescue PixivApiClient::BadIDError
        nil
      end
      
      def canonical_url
        return image_url
      end

      def profile_url
        [url, referer_url].each do |x|
          if x =~ PROFILE
            return x
          end
        end

        "https://www.pixiv.net/member.php?id=#{metadata.user_id}"
      rescue PixivApiClient::BadIDError
        nil
      end

      def artist_name
        metadata.name
      rescue PixivApiClient::BadIDError
        nil
      end

      def artist_commentary_title
        metadata.artist_commentary_title
      rescue PixivApiClient::BadIDError
        nil
      end

      def artist_commentary_desc
        metadata.artist_commentary_desc
      rescue PixivApiClient::BadIDError
        nil
      end
      
      def headers
        if fanbox_id.present?
          # need the session to download fanbox images
          return {
            "Referer" => "https://www.pixiv.net/fanbox",
            "Cookie" => HTTP::Cookie.cookie_value(agent.cookies)
          }
        end

        return {
          "Referer" => "https://www.pixiv.net"
        }
      end

      def normalized_for_artist_finder?
        url =~ PROFILE || url =~ STACC_PAGE
      end

      def normalizable_for_artist_finder?
        illust_id.present? || novel_id.present? || fanbox_id.present? || fanbox_account_id.present?
      end

      def unique_id
        moniker
      end

      def tags
        metadata.tags.map do |tag|
          [tag, "https://www.pixiv.net/search.php?s_mode=s_tag_full&#{{word: tag}.to_param}"]
        end
      rescue PixivApiClient::BadIDError
        []
      end
      memoize :tags

      def translate_tag(tag)
        normalized_tag = tag.gsub(/\d+users入り\z/i, "")
        translated_tags = super(normalized_tag)

        if translated_tags.empty? && normalized_tag.include?("/")
          translated_tags = normalized_tag.split("/").flat_map { |tag| super(tag) }
        end

        translated_tags
      end

      def related_posts_search_query
        illust_id.present? ? "pixiv:#{illust_id}" : "source:#{canonical_url}"
      end

    public

      def image_urls_sub
        # there's too much normalization bullshit we have to deal with
        # raw urls, so just fetch the canonical url from the api every
        # time.

        if manga_page.present?
          return [metadata.pages[manga_page]]
        end

        if metadata.pages.is_a?(Hash)
          return [ugoira_zip_url]
        end

        return metadata.pages
      end

      # in order to prevent recursive loops, this method should not make any
      # api calls and only try to extract the illust_id from the url. therefore,
      # even though it makes sense to reference page_url here, it will only look
      # at (url, referer_url).
      def illust_id
        # http://img18.pixiv.net/img/evazion/14901720.png
        #
        # http://i2.pixiv.net/img18/img/evazion/14901720.png
        # http://i2.pixiv.net/img18/img/evazion/14901720_m.png
        # http://i2.pixiv.net/img18/img/evazion/14901720_s.png
        # http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png
        # http://i1.pixiv.net/img07/img/pasirism/18557054_big_p1.png
        #
        # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg
        # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png
        #
        # http://i1.pixiv.net/c/600x600/img-master/img/2014/10/02/13/51/23/46304396_p0_master1200.jpg
        # http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p0.png
        #
        # http://i1.pixiv.net/img-zip-ugoira/img/2014/10/03/17/29/16/46323924_ugoira1920x1080.zip
        if url =~ %r!/(\d+)(?:_\w+)?\.(?:jpg|jpeg|png|gif|zip)!i
          return $1
        end

        [url, referer_url].each do |x|
          # http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054
          # http://www.pixiv.net/member_illust.php?mode=big&illust_id=18557054
          # http://www.pixiv.net/member_illust.php?mode=manga&illust_id=18557054
          # http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=18557054&page=1
          if x =~ /illust_id=(\d+)/i
            return $1
          end

          # http://www.pixiv.net/i/18557054
          if x =~ %r!pixiv\.net/i/(\d+)!i
            return $1
          end
        end

        return nil
      end
      memoize :illust_id

      def novel_id
        [url, referer_url].each do |x|
          if x =~ NOVEL_PAGE
            return $1
          end
        end

        return nil
      end
      memoize :novel_id

      def fanbox_id
        [url, referer_url].each do |x|
          if x =~ FANBOX_PAGE
            return $1
          end

          if x =~ FANBOX_IMAGE
            return $1
          end
        end

        return nil
      end
      memoize :fanbox_id

      def fanbox_account_id
        [url, referer_url].each do |x|
          if x =~ FANBOX_ACCOUNT
            return x
          end
        end

        return nil
      end
      memoize :fanbox_account_id

      def agent
        PixivWebAgent.build
      end
      memoize :agent

      def metadata
        if novel_id.present?
          return PixivApiClient.new.novel(novel_id)
        end

        if fanbox_id.present?
          return PixivApiClient.new.fanbox(fanbox_id)
        end

        return PixivApiClient.new.work(illust_id)
      end
      memoize :metadata

      def moniker
        # we can sometimes get the moniker from the url
        if url =~ %r!#{IMG}/img/(#{MONIKER})!i
          return $1
        end

        if url =~ %r!#{I12}/img[0-9]+/img/(#{MONIKER})!i
          return $1
        end

        if url =~ %r!#{WEB}/stacc/(#{MONIKER})/?$!i
          return $1
        end

        return metadata.moniker
      end
      memoize :moniker

      def data
        return {
          ugoira_frame_data: ugoira_frame_data
        }
      end

      def ugoira_zip_url
        if metadata.pages.is_a?(Hash) && metadata.pages["ugoira600x600"]
          return metadata.pages["ugoira600x600"].sub("_ugoira600x600.zip", "_ugoira1920x1080.zip")
        end
      end
      memoize :ugoira_zip_url

      def ugoira_frame_data
        return metadata.json.dig("metadata", "frames")
      end
      memoize :ugoira_frame_data

      def ugoira_content_type
        case metadata.json["image_urls"].to_s
        when /\.jpg/
          return "image/jpeg"

        when /\.png/
          return "image/png"

        when /\.gif/
          return "image/gif"
        end

        raise Sources::Error.new("content type not found for (#{url}, #{referer_url})")
      end
      memoize :ugoira_content_type

      # Returns the current page number of the manga. This will not
      # make any api calls and only looks at (url, referer_url).
      def manga_page
        # http://i2.pixiv.net/img04/img/syounen_no_uta/46170939_p0.jpg
        # http://i1.pixiv.net/c/600x600/img-master/img/2014/09/24/23/25/08/46168376_p0_master1200.jpg
        # http://i1.pixiv.net/img-original/img/2014/09/25/23/09/29/46183440_p0.jpg
        if url =~ %r!/\d+_p(\d+)(?:_\w+)?\.#{EXT}!i
          return $1.to_i
        end

        # http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46170939&page=0
        [url, referer_url].each do |x|
          if x =~ /page=(\d+)/i
            return $1.to_i
          end
        end

        return nil
      end
      memoize :manga_page
    end
  end
end
