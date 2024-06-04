# frozen_string_literal: true

# Pixiv Factory images may be used in Booth.pm posts (Ex: https://dai-xt.booth.pm/items/5701118)
#
# @see Source::Extractor::PixivFactory
module Source
  class URL::PixivFactory < Source::URL
    attr_reader :full_image_url, :image_id, :collection_name

    def self.match?(url)
      url.host == "factory.pixiv.net" || ([url.domain, *url.path_segments] in "ctfassets.net", "91hllu7j5j6t", *)
    end

    def parse
      case [subdomain, domain, *path_segments]

      # https://factory.pixiv.net/files/uploads/i/conceptual_drawing/3a6f3742-03b6-4968-9599-20dc2c0e1172/lightweight_f2605b12ed.png (sample)
      # https://factory.pixiv.net/files/uploads/i/conceptual_drawing/3a6f3742-03b6-4968-9599-20dc2c0e1172/canvas_f2605b12ed.png (full)
      in "factory", "pixiv.net", "files", "uploads", "i", "conceptual_drawing", uuid, /^\w+_(\h+)\.\w+$/
        hash = $1
        @full_image_url = "https://factory.pixiv.net/files/uploads/i/conceptual_drawing/3a6f3742-03b6-4968-9599-20dc2c0e1172/canvas_#{hash}.#{file_ext}"

      # https://factory.pixiv.net/resources/images/13760863/thumb (sample)
      # https://factory.pixiv.net/resources/images/13760863/canvas (full)
      in "factory", "pixiv.net", "resources", "images", image_id, _
        @image_id = image_id
        @full_image_url = "https://factory.pixiv.net/resources/images/#{image_id}/canvas"

      # https://factory.pixiv.net/_next/image?url=https%3A%2F%2Fimages.ctfassets.net%2F91hllu7j5j6t%2F55IY8dLGAZnQuRIdQQLtE9%2Fc4705fa83c046b5938beb6d2470550f8%2FThumbnail_hasuimo2.jpg&w=384&q=75
      in "factory", "pixiv.net", "_next", "image"
        @full_image_url = Source::URL.parse(params[:url]).try(:full_image_url)

      # Docs: https://www.contentful.com/developers/docs/references/images-api/#/reference/retrieval/image/retrieve-an-image/console
      # https://images.ctfassets.net/91hllu7j5j6t/55IY8dLGAZnQuRIdQQLtE9/c4705fa83c046b5938beb6d2470550f8/Thumbnail_hasuimo2.jpg?w=384&q=75 (sample)
      # https://images.ctfassets.net/91hllu7j5j6t/55IY8dLGAZnQuRIdQQLtE9/c4705fa83c046b5938beb6d2470550f8/Thumbnail_hasuimo2.jpg (full)
      # https://downloads.ctfassets.net/91hllu7j5j6t/55IY8dLGAZnQuRIdQQLtE9/c4705fa83c046b5938beb6d2470550f8/Thumbnail_hasuimo2.jpg (full)
      in _, "ctfassets.net", *rest
        @full_image_url = without(:params).to_s

      # https://factory.pixiv.net/palette/collections/imys_tachie#image-13760863
      in "factory", "pixiv.net", "palette", "collections", collection_name
        @collection_name = collection_name
        @image_id = fragment&.slice(/^image-(\d+)$/, 1)

      else
        nil
      end
    end

    def image_url?
      super || full_image_url.present?
    end

    def page_url
      if collection_name.present? && image_id.present?
        "https://factory.pixiv.net/palette/collections/#{collection_name}#image-#{image_id}"
      elsif collection_name.present?
        "https://factory.pixiv.net/palette/collections/#{collection_name}"
      end
    end
  end
end
