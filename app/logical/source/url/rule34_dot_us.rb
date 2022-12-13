# frozen_string_literal: true

# https://rule34.us is running a modified fork of Gelbooru 0.1, so its URL structure is similar but not identical to
# that of other Gelbooru-based sites.
#
# @see Source::URL::Gelbooru
class Source::URL::Rule34DotUs < Source::URL
  attr_reader :post_id, :md5, :image_type, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[rule34.us])
  end

  def site_name
    "Rule34.us"
  end

  def parse
    case [domain, *path_segments]

    # https://rule34.us/index.php?r=posts/view&id=6204967
    in _, "index.php" if params[:r] == "posts/view" && params[:id].present?
      @post_id = params[:id].to_i

    # https://rule34.us/hotlink.php?hash=236690fd962fa394edf9894450261dac
    in _, "hotlink.php" if params[:hash]&.match?(/\A\h{32}\z/)
      @md5 = params[:hash]

    # https://img2.rule34.us/thumbnails/23/66/thumbnail_236690fd962fa394edf9894450261dac.jpg
    # https://img2.rule34.us/images/23/66/236690fd962fa394edf9894450261dac.png
    # https://video.rule34.us/images/d8/1d/d81d79f0292cdb096a8653efa001342d.webm
    # no samples
    in _, ("images" | "thumbnails") => image_type, /\A\h{2}\z/ => h1, /\A\h{2}\z/ => h2, /\A(?:thumbnail_)?(\h{32})\.\w+\z/i
      @md5 = $1
      @image_type = image_type
      @full_image_url = url.to_s if image_type == "images"

    else
      nil
    end
  end

  def image_url?
    image_type.present?
  end

  def page_url
    if post_id.present?
      "https://rule34.us/index.php?r=posts/view&id=#{post_id}"
    elsif md5.present?
      "https://rule34.us/hotlink.php?hash=#{md5}"
    end
  end
end
