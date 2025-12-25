# frozen_string_literal: true

module Source
  class URL
    class PixivComic < Source::URL
      attr_reader :full_image_url, :magazine_id, :work_id, :story_id, :novel_work_id, :novel_story_id

      def self.match?(url)
        url.host.in?(%w[comic.pixiv.net img-comic.pximg.net public-img-comic.pximg.net img-novel.pximg.net public-img-novel.pximg.net])
      end

      def parse
        case [subdomain, domain, *path_segments]

        # https://public-img-comic.pximg.net/images/magazine_cover/e772MnFuZZ5oQsadLQ2b/317.jpg?20240120120001
        # https://public-img-comic.pximg.net/images/magazine_logo/e772MnFuZZ5oQsadLQ2b/317.png?20240120120001
        in *, "images", ("magazine_cover" | "magazine_logo") => image_type, hash, _ if image_url?
          @magazine_id = filename
          @full_image_url = "https://public-img-comic.pximg.net/images/#{image_type}/#{hash}/#{basename}"

        # https://img-comic.pximg.net/c/q90_gridshuffle32:32/images/page/162153/iMnq837lBFlyCIpIstcp/1.jpg?20240112151247
        # https://img-comic.pximg.net/images/page/9869/V52hshKjl05juBvdbHJ5/2.jpg?20151030104009
        in *, "images", "page", story_id, hash, _ if image_url?
          @story_id = story_id
          @full_image_url = "https://img-comic.pximg.net/images/page/#{story_id}/#{hash}/#{basename}"

        # https://public-img-comic.pximg.net/c!/f=webp:auto,w=96,q=75/images/story_thumbnail/92O1JVc8DrrTTTfKdl2R/167869.jpg?20240426131638
        in *, "images", "story_thumbnail", hash, _ if image_url?
          @story_id = filename

        # https://public-img-comic.pximg.net/c!/q=90,f=webp%3Ajpeg/images/work_thumbnail/10137.jpg?20240217160416
        # https://public-img-comic.pximg.net/c!/w=200,f=webp%3Ajpeg/images/work_main/10137.jpg?20240217160416
        # https://public-img-comic.pximg.net/images/work_main/10137.jpg?20240217160416
        # https://img-comic.pximg.net/images/work_main/10137.jpg?20240217160416
        in *, "images", ("work_main" | "work_thumbnail"), _ if image_url?
          @work_id = filename
          @full_image_url = "https://public-img-comic.pximg.net/images/work_main/#{basename}"

        # https://img-novel.pximg.net/c!/f=webp:auto,w=384,q=75/img-novel/work_main/BJruKIb2nWvhTadwsL68/3877.jpg?20240430174032
        in *, "img-novel", "work_main", hash, _ if image_url?
          @novel_work_id = filename
          @full_image_url = "https://img-novel.pximg.net/img-novel/work_main/#{hash}/#{basename}?#{query}"

        # https://img-novel.pximg.net/img-novel/page/11588/GRqnlQ258aa3CFxpRIys/1.jpg?20240426103009
        in *, "img-novel", "page", novel_story_id, hash, _ if image_url?
          @novel_story_id = novel_story_id
          @full_image_url = "https://img-novel.pximg.net/img-novel/page/#{novel_story_id}/#{hash}/#{basename}?#{query}"

        # https://comic.pixiv.net/magazines/317
        in "comic", "pixiv.net", "magazines", magazine_id
          @magazine_id = magazine_id

        # https://comic.pixiv.net/works/10137
        in "comic", "pixiv.net", "works", work_id
          @work_id = work_id

        # https://comic.pixiv.net/viewer/stories/162153
        in "comic", "pixiv.net", "viewer", "stories", story_id
          @story_id = story_id

        # https://comic.pixiv.net/novel/works/3877
        in "comic", "pixiv.net", "novel", "works", novel_work_id
          @novel_work_id = novel_work_id

        # https://comic.pixiv.net/novel/viewer/stories/11588
        in "comic", "pixiv.net", "novel", "viewer", "stories", novel_story_id
          @novel_story_id = novel_story_id

        # https://comic.pixiv.net/store/variants/5abf7kye5
        # https://comic.pixiv.net/store/viewers/d4cbqapvr
        # https://public-img-comic.pximg.net/c!/h=226,a=0/img-comic-store/variant/956540/buyctwvtt.jpg?timestamp=1713720467
        # https://public-img-comic.pximg.net/c!/f=webp:auto,w=384,h=521,a=3,q=75/img-comic-store/variant/1236533/5abf7kye5.jpg?timestamp=1713720557
        else
          nil
        end
      end

      def page_url
        if magazine_id.present?
          "https://comic.pixiv.net/magazines/#{magazine_id}"
        elsif work_id.present?
          "https://comic.pixiv.net/works/#{work_id}"
        elsif story_id.present?
          "https://comic.pixiv.net/viewer/stories/#{story_id}"
        elsif novel_work_id.present?
          "https://comic.pixiv.net/novel/works/#{novel_work_id}"
        elsif novel_story_id.present?
          "https://comic.pixiv.net/novel/viewer/stories/#{novel_story_id}"
        end
      end
    end
  end
end
