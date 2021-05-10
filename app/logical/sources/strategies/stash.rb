# Page URLs:
# * https://sta.sh/0wxs31o7nn2 (single image)
# * https://sta.sh/21leo8mz87ue (folder)
#
# Image URLs:
# * https://orig00.deviantart.net/0fd2/f/2018/252/9/c/a_pepe_by_noizave-dcmga0s.png
#
# Ref:
# * https://github.com/danbooru/danbooru/issues/3877
# * https://www.deviantartsupport.com/en/article/what-is-stash-3391708
# * https://www.deviantart.com/developers/http/v1/20160316/stash_item/4662dd8b10e336486ea9a0b14da62b74
#
module Sources
  module Strategies
    class Stash < DeviantArt
      STASH = %r{\Ahttps?://sta\.sh/(?<post_id>[0-9a-zA-Z]+)}i

      def domains
        ["deviantart.net", "sta.sh"]
      end

      def match?
        parsed_urls.map(&:domain).any?("sta.sh")
      end

      def site_name
        "Sta.sh"
      end

      def canonical_url
        page_url
      end

      def page_url
        page_url_from_image_url
      end

      def page_url_from_image_url
        "https://sta.sh/#{stash_id}"
      end

      def self.stash_id_from_url(url)
        if url =~ STASH
          $~[:post_id].downcase
        else
          nil
        end
      end

      def stash_id
        [url, referer_url].map { |x| self.class.stash_id_from_url(x) }.compact.first
      end
    end
  end
end
