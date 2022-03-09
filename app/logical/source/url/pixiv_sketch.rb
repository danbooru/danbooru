# frozen_string_literal: true

module Source
  class URL::PixivSketch < Source::URL
    attr_reader :work_id, :username, :full_image_url

    def self.match?(url)
      url.host.in?(%w[sketch.pixiv.net img-sketch.pixiv.net img-sketch.pximg.net])
    end

    def parse
      case [host, *path_segments]

      # https://sketch.pixiv.net/items/5835314698645024323
      in "sketch.pixiv.net", "items", work_id
        @work_id = work_id

      # https://img-sketch.pixiv.net/uploads/medium/file/4463372/8906921629213362989.jpg (page: https://sketch.pixiv.net/items/5835314698645024323)
      # https://img-sketch.pximg.net/c!/w=540,f=webp:jpeg/uploads/medium/file/4463372/8906921629213362989.jpg
      # https://img-sketch.pixiv.net/c/f_540/uploads/medium/file/9986983/8431631593768139653.jpg
      in *, "uploads", "medium", "file", dir, file if image_url?
        @full_image_url = "https://img-sketch.pixiv.net/uploads/medium/file/#{dir}/#{file}"

      # https://sketch.pixiv.net/@user_ejkv8372
      # https://sketch.pixiv.net/@user_ejkv8372/followings
      in "sketch.pixiv.net", /^@/ => username, *rest
        @username = username.delete_prefix("@")

      else
      end
    end

    def image_url?
      url.host.in?(%w[img-sketch.pixiv.net img-sketch.pximg.net])
    end

    def page_url
      # https://sketch.pixiv.net/items/5835314698645024323
      "https://sketch.pixiv.net/items/#{work_id}" if work_id.present?
    end

    def api_url
      # https://sketch.pixiv.net/api/items/5835314698645024323.json (won't work in the browser; use curl)
      "https://sketch.pixiv.net/api/items/#{work_id}.json" if work_id.present?
    end
  end
end
