# frozen_string_literal: true

# The class is called `Danbooru2` instead of `Danbooru` to avoid ambiguity with the top-level `Danbooru` class.
class Source::URL::Danbooru2 < Source::URL
  attr_reader :user_id, :post_id, :md5, :image_url, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[donmai.us donmai.moe])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://danbooru.donmai.us/users/1
    # https://danbooru.donmai.us/users/1.json
    in _, _, "users", /\A(\d+)/
      @user_id = $1

    # https://danbooru.donmai.us/posts/1
    # https://danbooru.donmai.us/posts/1.json
    in _, _, "posts", /\A(\d+)/
      @post_id = $1

    # https://danbooru.donmai.us/posts?md5=8d819da4871c3ca39f428999df8220ce
    in _, _, "posts" if params[:md5].present? && params[:md5].match?(/\A\h{32}\z/)
      @md5 = params[:md5]

    # https://cdn.donmai.us/sample/8d/81/__sonetto_reverse_1999_drawn_by_beishang_yutou__sample-8d819da4871c3ca39f428999df8220ce.jpg
    # https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg
    # https://cdn.donmai.us/8d/81/8d819da4871c3ca39f428999df8220ce.jpg
    # https://danbooru.donmai.us/data/8d/81/8d819da4871c3ca39f428999df8220ce.jpg
    in _, _, *subdirs, /(\h{32})\.\w+\z/i
      @md5 = $1
      @image_url = true
      @full_image_url = full_image_url_for(file_ext) if subdirs.first.match?(/\A(original|\h{2})\z/)

    else
      nil
    end
  end

  def site_name
    "Danbooru"
  end

  def candidate_full_image_urls
    %w[jpg png gif mp4 webm webp avif zip swf].map { |ext| full_image_url_for(ext) }
  end

  def full_image_url_for(file_ext)
    if image_url? && md5.present?
      "https://cdn.donmai.us/original/#{md5[0..1]}/#{md5[2..3]}/#{md5}.#{file_ext}"
    end
  end

  def image_url?
    @image_url.present?
  end

  def page_url
    if post_id.present?
      "https://danbooru.donmai.us/posts/#{post_id}"
    elsif md5.present?
      "https://danbooru.donmai.us/posts?md5=#{md5}"
    end
  end

  def profile_url
    "https://danbooru.donmai.us/users/#{user_id}" if user_id.present?
  end
end
