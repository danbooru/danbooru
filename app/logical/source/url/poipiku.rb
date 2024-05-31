# frozen_string_literal: true

class Source::URL::Poipiku < Source::URL
  attr_reader :user_id, :post_id, :image_dir, :image_id, :image_hash, :original_file_ext

  def self.match?(url)
    url.domain == "poipiku.com"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://img.poipiku.com/user_img02/006849873/008271386_016865825_S968sAh7Y.jpeg_640.jpg (sample)
    # https://img-org.poipiku.com/user_img02/006849873/008271386_016865825_S968sAh7Y.jpeg (original)
    # https://poipiku.com/6849873/8271386.html (page URL)
    in ("img" | "img-org"), "poipiku.com", image_dir, user_id, /^(\d+)_(\d+)_(\w+)\.([a-z]+)/
      @image_dir = image_dir
      @user_id = user_id.to_i
      @post_id = $1.to_i
      @image_id = $2.to_i
      @image_hash = $3
      @original_file_ext = $4

    # https://img.poipiku.com/user_img03/000020566/007185704_nb1cTuA1I.jpeg_640.jpg (sample)
    # https://img-org.poipiku.com/user_img03/000020566/007185704_nb1cTuA1I.jpeg (original)
    # https://poipiku.com/20566/7204115.html (actual page URL; https://poipiku.com/20566/007185704.html redirects to this)
    in ("img" | "img-org"), "poipiku.com", image_dir, user_id, /^(\d+)_(\w+)\.([a-z]+)/
      @image_dir = image_dir
      @user_id = user_id.to_i
      @post_id = $1.to_i
      @image_hash = $2
      @original_file_ext = $3

    # https://img.poipiku.com/user_img02/000003310/000007036.jpeg_640.jpg (sample)
    # https://img-org.poipiku.com/user_img02/000003310/000007036.jpeg (original)
    # https://poipiku.com/3310/7036.html (page URL)
    in ("img" | "img-org"), "poipiku.com", image_dir, user_id, /^(\d+)\.([a-z]+)/
      @image_dir = image_dir
      @user_id = user_id.to_i
      @post_id = $1.to_i
      @original_file_ext = $2

    # https://poipiku.com/6849873/8271386.html
    in _, "poipiku.com", user_id, /(\d+)\.html$/i
      @user_id = user_id
      @post_id = $1.to_i

    # https://poipiku.com/IllustListPcV.jsp?ID=9056
    # https://poipiku.com/IllustListGridPcV.jsp?ID=9056
    in _, "poipiku.com", ("IllustListPcV.jsp" | "IllustListGridPcV.jsp" | "ActivityListPcV.jsp") if params[:ID].present?
      @user_id = params[:ID]

    # https://poipiku.com/6849873
    in _, "poipiku.com", /^\d+$/ => user_id
      @user_id = user_id

    else
      nil
    end
  end

  def image_url?
    subdomain.in?(%w[img img-org])
  end

  def full_image_url
    # https://img-org.poipiku.com/user_img02/006849873/008271386_016865825_S968sAh7Y.jpeg
    if image_dir && user_id && post_id && image_id && image_hash && original_file_ext
      "https://img-org.poipiku.com/#{image_dir}/#{"%.9d" % user_id}/#{"%.9d" % post_id}_#{"%.9d" % image_id}_#{image_hash}.#{original_file_ext}"

    # https://img-org.poipiku.com/user_img03/000013318/007865949_WuckPeoQk.png
    elsif image_dir && user_id && post_id && image_hash && original_file_ext
      "https://img-org.poipiku.com/#{image_dir}/#{"%.9d" % user_id}/#{"%.9d" % post_id}_#{image_hash}.#{original_file_ext}"

    # https://img-org.poipiku.com/user_img02/000003310/000007036.jpeg
    elsif image_dir && user_id && post_id && original_file_ext
      "https://img-org.poipiku.com/#{image_dir}/#{"%.9d" % user_id}/#{"%.9d" % post_id}.#{original_file_ext}"

    end
  end

  def page_url
    # https://poipiku.com/6849873/8271386.html
    "https://poipiku.com/#{user_id}/#{post_id}.html" if user_id && post_id
  end

  def profile_url
    # https://poipiku.com/6849873/
    "https://poipiku.com/#{user_id}/" if user_id
  end
end
