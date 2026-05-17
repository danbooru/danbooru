# frozen_string_literal: true

class Source::URL::Hitomi < Source::URL
  site "Hitomi", url: "https://hitomi.la"

  attr_reader :gallery_id, :image_id

  def self.match?(url)
    url.domain == "hitomi.la"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://la.hitomi.la/galleries/1054851/001_main_image.jpg
    in _, "hitomi.la", "galleries", gallery_id, /^(\d+)\w*\./
      @gallery_id = gallery_id
      @image_id = $1.to_i

    # https://aa.hitomi.la/galleries/883451/t_rena1g.png
    in _, "hitomi.la", "galleries", gallery_id, _
      @gallery_id = gallery_id

    else
      nil
    end
  end

  def page_url
    if gallery_id.present? && image_id.present?
      "https://hitomi.la/reader/#{gallery_id}.html##{image_id}"
    elsif gallery_id.present?
      "https://hitomi.la/galleries/#{gallery_id}.html"
    end
  end
end
