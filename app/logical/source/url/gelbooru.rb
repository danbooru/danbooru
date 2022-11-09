# frozen_string_literal: true

# This covers both Gelbooru and Safebooru.
class Source::URL::Gelbooru < Source::URL
  attr_reader :post_id, :md5, :image_type, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[safebooru.org gelbooru.com])
  end

  def parse
    case [domain, *path_segments]

    # https://gelbooru.com/index.php?page=post&s=view&id=7798045
    # https://www.gelbooru.com/index.php?page=post&s=view&id=7798045
    # https://safebooru.org/index.php?page=post&s=view&id=4196948
    in _, "index.php" if params[:page] == "post" && params[:s] == "view" && params[:id].present?
      @post_id = params[:id].to_i

    # https://gelbooru.com/index.php?page=post&s=list&md5=99d9977d6c3aa185083a2da22bd8acfb
    # https://safebooru.org/index.php?page=post&s=list&md5=99d9977d6c3aa185083a2da22bd8acfb
    in _, "index.php" if params[:page] == "post" && params[:s] == "list" && params[:md5].present?
      @md5 = params[:md5]

    # https://gelbooru.com/index.php?page=dapi&s=post&q=index&id=7798045&json=1
    # https://safebooru.org/index.php?page=dapi&s=post&q=index&id=4196948&json=1
    in _, "index.php" if params[:page] == "dapi" && params[:q] == "index" && params[:id].present?
      @post_id = params[:id].to_i

    # https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg
    # https://video-cdn3.gelbooru.com/images/62/95/6295154d082f04009160261b90e7176e.mp4
    # https://img2.gelbooru.com//images/a9/64/a96478bbf9bc3f0584f2b5ddf56025fa.webm
    # https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg
    # https://gelbooru.com/thumbnails/08/06/thumbnail_08066c138e7e138a47489a0934c29156.jpg
    in _, ("images" | "samples" | "thumbnails") => image_type, /\A\h{2}\z/ => h1, /\A\h{2}\z/ => h2, /\A(?:sample_|thumbnail_)?(\h{32})\.\w+\z/i
      @md5 = $1
      @image_type = image_type
      @full_image_url = url.to_s if image_type == "images"

    # http://simg2.gelbooru.com//samples/619/sample_fe84fb3f86020e120f4b4712fcbd3abf.jpeg?755046
    # http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png
    # https://safebooru.org//images/4016/64779fbfc87020ed5fd94854fe973bc0.jpeg
    # https://safebooru.org//samples/4016/sample_64779fbfc87020ed5fd94854fe973bc0.jpg?4196692
    # https://safebooru.org/thumbnails/4016/thumbnail_64779fbfc87020ed5fd94854fe973bc0.jpg?4196692
    in _, ("images" | "samples" | "thumbnails") => image_type, /\A\d+\z/ => directory, /\A(?:sample_|thumbnail_)?(\h{32})\.\w+\z/
      @md5 = $1
      @post_id = query if query&.match?(/\A\d+\z/)
      @image_type = image_type
      @full_image_url = url.to_s if image_type == "images"

    # Safebooru uses an unknown 40-byte hash for most image URLs.
    # https://safebooru.org//images/4016/d2f50befcdc304cbd9030f2d0832029f5fe8cccc.png
    # https://safebooru.org//samples/4016/sample_ffc6c5705d31422ddbaa7478deb560c985d2ee71.jpg?4196970
    # https://safebooru.org/thumbnails/4016/thumbnail_8d0664867c59acb3103bccd9a9a5562a193eadcd.jpg?4196980
    in "safebooru.org", ("images" | "samples" | "thumbnails") => image_type, /\A\d+\z/ => directory, /\A(?:sample_|thumbnail_)?(\h{40})\.\w+\z/
      @hash = $1
      @post_id = query if query&.match?(/\A\d+\z/)
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
      "https://#{domain}/index.php?page=post&s=view&id=#{post_id}"
    elsif md5.present?
      "https://#{domain}/index.php?page=post&s=list&md5=#{md5}"
    end
  end

  def api_url
    # https://gelbooru.com//index.php?page=dapi&s=post&q=index&tags=id:7903922
    # https://safebooru.org/index.php?page=dapi&s=post&q=index&tags=id:4197087
    if post_id.present?
      # "https://#{domain}/index.php?page=dapi&s=post&q=index&id=#{post_id}&json=1"
      "https://#{domain}/index.php?page=dapi&s=post&q=index&tags=id:#{post_id}"
    # https://gelbooru.com//index.php?page=dapi&s=post&q=index&tags=md5:338078144fe77c9e5f35dbb585e749ec
    # https://safebooru.org/index.php?page=dapi&s=post&q=index&tags=md5:8c1fe66ff46d03725caa30135ad70e7e
    elsif md5.present?
      "https://#{domain}/index.php?page=dapi&s=post&q=index&tags=md5:#{md5}"
    end
  end
end
