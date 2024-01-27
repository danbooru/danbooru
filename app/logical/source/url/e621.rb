# frozen_string_literal: true

class Source::URL::E621 < Source::URL
  attr_reader :user_id, :post_id, :md5, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[e621.net e926.net])
  end

  def parse
    case [domain, *path_segments]

    # https://e621.net/users/205980
    in _, "users", user_id
      @user_id = user_id

    # https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a
    in _, "posts" if params[:md5].present?
      @md5 = params[:md5]

    # https://e621.net/posts/3728701
    in _, "posts", post_id
      @post_id = post_id

    # https://static1.e621.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png
    in _, "data", /\A\h{2}\z/ => h1, /\A\h{2}\z/ => h2, /\A(\h{32})\.\w+\z/i
      @md5 = $1
      @image_url = true
      @full_image_url = url.to_s

    # https://static1.e621.net/data/preview/6d/1a/6d1a6090ea82c2524212499797e7e53a.jpg
    # https://static1.e621.net/data/crop/6d/1a/6d1a6090ea82c2524212499797e7e53a.jpg
    # https://static1.e621.net/data/sample/6d/1a/6d1a6090ea82c2524212499797e7e53a.jpg
    # https://static1.e621.net/data/sample/ae/ae/aeaed0dfba6468ec992c6e5cc46763c1_720p.mp4
    in _, "data", sample_type, /\A\h{2}\z/ => h1, /\A\h{2}\z/ => h2, /\A(\h{32})(?:_\w+)?\.\w+\z/i
      @md5 = $1
      @image_url = true

    else
      nil
    end
  end

  def site_name
    "e621"
  end

  def image_url?
    @image_url.present?
  end

  def page_url
    if post_id.present?
      "https://e621.net/posts/#{post_id}"
    elsif md5.present?
      "https://e621.net/posts?md5=#{md5}"
    end
  end

  def profile_url
    "https://e621.net/users/#{user_id}" if user_id.present?
  end
end
