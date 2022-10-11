# frozen_string_literal: true

class Source::URL::Gelbooru < Source::URL
  attr_reader :post_id, :md5, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[gelbooru.com])
  end

  def parse
    case [domain, *path_segments]

    # https://gelbooru.com/index.php?page=post&s=view&id=7798045
    # https://www.gelbooru.com/index.php?page=post&s=view&id=7798045
    in "gelbooru.com", "index.php" if params[:page] == "post" && params[:s] == "view" && params[:id].present?
      @post_id = params[:id].to_i

    # https://gelbooru.com/index.php?page=post&s=list&md5=99d9977d6c3aa185083a2da22bd8acfb
    in "gelbooru.com", "index.php" if params[:page] == "post" && params[:s] == "list" && params[:md5].present?
      @md5 = params[:md5]

    # https://gelbooru.com/index.php?page=dapi&s=post&q=index&id=7798045&json=1
    in "gelbooru.com", "index.php" if params[:page] == "dapi" && params[:q] == "index" && params[:id].present?
      @post_id = params[:id].to_i

    # https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg
    # http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png
    # https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg
    # https://video-cdn3.gelbooru.com/images/62/95/6295154d082f04009160261b90e7176e.mp4
    # https://img2.gelbooru.com//images/a9/64/a96478bbf9bc3f0584f2b5ddf56025fa.webm
    # https://gelbooru.com/thumbnails/08/06/thumbnail_08066c138e7e138a47489a0934c29156.jpg
    in "gelbooru.com", ("images" | "samples" | "thumbnails"), h1, h2, /\A(?:\w+_)?(\h{32})\.(jpeg|jpg|png|gif|mp4|webm)\z/i
      @md5 = $1
      @full_image_url = "https://#{host}/images/#{h1}/#{h2}/#{md5}.#{file_ext}"

    else
      nil
    end
  end

  def image_url?
    full_image_url.present?
  end

  def page_url
    if post_id.present?
      "https://gelbooru.com/index.php?page=post&s=view&id=#{post_id}"
    elsif md5.present?
      "https://gelbooru.com/index.php?page=post&s=list&md5=#{md5}"
    end
  end

  def api_url
    "https://gelbooru.com/index.php?page=dapi&s=post&q=index&id=#{post_id}&json=1" if post_id.present?
  end
end
