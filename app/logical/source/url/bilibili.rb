# frozen_string_literal: true

# Unsupported:
# * https://www.bilibili.com/festival/arknights2022?bvid=BV1sr4y1e7gQ
# * https://game.bilibili.com/sssj/#character
# * http://i0.hdslb.com/Wallpaper/bilibili_chun.jpg
# * https://www.bilibili.com/html/bizhi.html

module Source
  class URL
    class Bilibili < Source::URL
      attr_reader :file, :t_work_id, :h_work_id, :video_id, :article_id, :artist_id

      def self.match?(url)
        url.domain.in?(%w[bilibili.com biliimg.com hdslb.com])
      end

      def parse
        case [subdomain, domain, *path_segments]

        # https://i0.hdslb.com/bfs/new_dyn/675526fd8baa2f75d7ea0e7ea957bc0811742550.jpg@1036w.webp
        # https://i0.hdslb.com/bfs/new_dyn/716a9733fc804d11d823cfacb7a3c78b11742550.jpg@208w_208h_1e_1c.webp
        # https://album.biliimg.com/bfs/new_dyn/4cf244d3fb706a5726b6383143960931504164361.jpg
        in _, ("hdslb.com" | "biliimg.com"), "bfs", "new_dyn", /^(\w{32}(\d{8,})\.\w+)(?:@\w+\.\w+)?$/ => file
          @file = $1
          @artist_id = $2

        # https://i0.hdslb.com/bfs/album/37f77871d417c76a08a9467527e9670810c4c442.gif@1036w.webp
        # https://i0.hdslb.com/bfs/album/37f77871d417c76a08a9467527e9670810c4c442.gif
        # https://i0.hdslb.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg@942w_1334h_progressive.webp
        # https://i0.hdslb.com/bfs/article/watermark/dccf0575ae604b5f96e9593a38241b897e10fc4b.png
        # https://i0.hdslb.com/bfs/article/card/f33ebbfe66a0f8ac4868f48b5b6f3ce478d0234c.png
        # https://album.biliimg.com/bfs/article/48e75b3871fa5ed62b4e3a16bf60f52f96b1b3b1.jpg@942w_1334h_progressive.webp
        in  _, ("hdslb.com" | "biliimg.com"), "bfs", *subdirs, /^(\w{40}\.\w+)(?:@\w+\.\w+)?$/ => file
          @file = $1

        # https://i0.hdslb.com/bfs/activity-plat/static/2cf2b9af5d3c5781d611d6e36f405144/E738vcDvd3.png
        # https://album.biliimg.com/bfs/activity-plat/static/2cf2b9af5d3c5781d611d6e36f405144/E738vcDvd3.png
        in  _, ("hdslb.com" | "biliimg.com"), "bfs", subsite, "static", subpath, /^\w+\.\w+$/ => file
        # pass

        # https://t.bilibili.com/686082748803186697
        # https://t.bilibili.com/723052706467414039?spm_id_from=333.999.0.0 (quoted repost)
        in "t", "bilibili.com", /^\d+$/ => t_work_id
          @t_work_id = t_work_id

        # https://m.bilibili.com/dynamic/612214375070704555
        in "m", "bilibili.com", "dynamic", /^\d+$/ => t_work_id
          @t_work_id = t_work_id

        # https://www.bilibili.com/opus/684571925561737250
        in _, "bilibili.com", "opus", /^\d+$/ => t_work_id
          @t_work_id = t_work_id

        # https://h.bilibili.com/83341894
        in "h", "bilibili.com", /^\d+$/ => h_work_id
          @h_work_id = h_work_id

        # https://www.bilibili.com/p/h5/8773541
        in ("www" | ""), "bilibili.com", "p", "h5", /^\d+$/ => h_work_id
          @h_work_id = h_work_id

        # https://www.bilibili.com/read/cv7360489
        in ("www" | ""), "bilibili.com", "read", /^cv(\d+)$/
          @article_id = $1

        # https://space.bilibili.com/355143
        # https://space.bilibili.com/476725595/dynamic
        # https://space.bilibili.com/476725595/video
        in "space", "bilibili.com", /^\d+$/ => artist_id, *rest
          @artist_id = artist_id

        # https://www.bilibili.com/video/av598699440/
        # https://www.bilibili.com/video/BV1dY4y1u7Vi/
        # http://www.bilibili.tv/video/av439451/
        in ("www" | "m" | ""), ("bilibili.com" | "bilibili.tv"), "video", video_id
          @video_id = video_id

        # https://www.bilibili.com/s/video/BV18b4y1X7av
        in ("www" | "m" | ""), ("bilibili.com" | "bilibili.tv"), "s", "video", video_id
          @video_id = video_id

        # https://i0.hdslb.com/bfs/article/card/1-1card416202622_web.png
        else
          nil
        end
      end

      def image_url?
        url.domain.in?(%w[biliimg.com hdslb.com])
      end

      def full_image_url
        if file.present?
          original_url.gsub(/(\.\w+)@\w+\.\w+$/, "\\1")
        end
      end

      def page_url
        if t_work_id.present?
          "https://t.bilibili.com/#{t_work_id}"
        elsif h_work_id.present?
          "https://h.bilibili.com/#{h_work_id}"
        elsif article_id.present?
          "https://www.bilibili.com/read/cv#{article_id}/"
        elsif video_id.present?
          "https://www.bilibili.com/video/#{video_id}/"
        end
      end

      def profile_url
        if artist_id.present?
          "https://space.bilibili.com/#{artist_id}"
        end
      end
    end
  end
end
