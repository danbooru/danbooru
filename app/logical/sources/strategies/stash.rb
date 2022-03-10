# frozen_string_literal: true

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
      def match?
        Source::URL::Stash === parsed_url || Source::URL::Stash === parsed_referer
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
        if Source::URL::Stash === parsed_url
          parsed_url.page_url
        elsif Source::URL::Stash === parsed_referer
          parsed_referer.page_url
        end
      end
    end
  end
end
