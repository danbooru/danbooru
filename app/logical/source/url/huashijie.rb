# frozen_string_literal: true

module Source
  class URL
    class Huashijie < Source::URL
      attr_reader :user_id, :work_id, :full_image_url

      def self.match?(url)
        url.domain.in?(%w[huashijie.art pandapaint.net])
      end

      def parse
        case [subdomain, domain, *path_segments]

        # https://bsyimg.pandapaint.net/v2/work_cover/user/13649297/1714634091547.jpg
        # https://bsyimgv2.pandapaint.net/v2/work_cover/user/14619015/1727160145437.jpg
        # https://bsyimgv2.pandapaint.net/v2/work_cover/user/14619015/1713709783854.jpg?image_process=format,WEBP
        # https://bsyimgv2.pandapaint.net/v2/album_cover/user/17873127/1736262275939.png?x-oss-process=style/work_cover&image_process=format,WEBP
        # https://bsyimgv2.pandapaint.net/v2/avatar/user/17873127/1733919514805.jpg?x-oss-process=style/work_cover_med&image_process=format,WEBP
        # https://bsyimg.pandapaint.net/v2/background/user/17873127/1734188851723.jpg
        # https://bsyimg.pandapaint.net/v2/video/user/13236644/1751972885632.mp4
        in ("bsyimg" | "bsyimgv2"), "pandapaint.net", "v2", _, "user", user_id, file
          @user_id = user_id
          @full_image_url = without(:query).to_s

        # https://www.huashijie.art/work/detail/237016516
        # https://www.huashijie.art/work/detail/235129335
        # https://www.huashijie.art/work/detail/215560340
        in ("www" | nil), "huashijie.art", "work", "detail", work_id
          @work_id = work_id

        # https://static.huashijie.art/w_d/235129335
        in "static", "huashijie.art", "w_d", work_id
          @work_id = work_id

        # https://static.huashijie.art/hsj/wap/#/detail?workId=235129335
        in "static", "huashijie.art", "hsj", "wap" if fragment&.starts_with?("/detail")
          @work_id = fragment&.slice(%r{^/detail\?workId=(\d+)$}, 1)

        # https://www.huashijie.art/user/index/13649297
        in ("www" | nil), "huashijie.art", "user", "index", user_id
          @user_id = user_id

        # https://static.huashijie.art/hsj/wap/#/usercenter?userId=13649297
        in "static", "huashijie.art", "hsj", "wap" if fragment&.starts_with?("/usercenter")
          @user_id = fragment&.slice(%r{^/usercenter\?userId=(\d+)$}, 1)

        # https://www.huashijie.art/album/2514902
        else
          nil
        end
      end

      def image_url?
        host.in?(%w[bsyimg.pandapaint.net bsyimgv2.pandapaint.net])
      end

      def page_url
        "https://www.huashijie.art/work/detail/#{work_id}" if work_id.present?
      end

      def profile_url
        "https://www.huashijie.art/user/index/#{user_id}" if user_id.present?
      end
    end
  end
end
