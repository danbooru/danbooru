# frozen_string_literal: true

class Source::URL::Enty < Source::URL
  RESERVED_NAMES = %w[blogs en messages posts products ranking search series service_navigations signout titles users]

  attr_reader :work_id, :image_id, :username, :user_id, :file

  def self.match?(url)
    url.domain == "enty.jp" || url.host == "entyjp.s3-ap-northeast-1.amazonaws.com"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # Thumbnail
    # https://img01.enty.jp/uploads/post/thumbnail/141598/post_show_b6c7d85c-b63c-4950-9152-e4bf30678022.png
    in "img01", "enty.jp", "uploads", "post", "thumbnail", work_id, file
      @work_id = work_id
      @file = file

    # Sample image
    # https://img01.enty.jp/uploads/ckeditor/pictures/194353/content_20211227_130_030_100.png
    in "img01", "enty.jp", "uploads", "ckeditor", "pictures", image_id, file
      @image_id = image_id
      @file = file

    # Full image
    # https://entyjp.s3-ap-northeast-1.amazonaws.com/uploads/post/attachment/141598/20211227_130_030_100.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIMO6YQGDXLXXJKQA%2F20221224%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Date=20221224T235529Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&X-Amz-Signature=42857026422339a2ba9ea362d91e2b34cc0718fbeee529166e8bfa80f757bb94
    in _, "amazonaws.com", "uploads", "post", "attachment", work_id, file
      @work_id = work_id
      @file = file

    # Profile banner
    # https://img01.enty.jp/uploads/entertainer/wallpaper/2044/post_show_enty_top.png
    in "img01", "enty.jp", "uploads", "entertainer", "wallpaper", user_id, file
      @user_id = user_id
      @file = file

    # https://enty.jp/posts/141598?ref=newest_post_pc
    in _, "enty.jp", "posts", work_id
      @work_id = work_id

    # https://enty.jp/en/posts/141598?ref=newest_post_pc
    in _, "enty.jp", ("en" | "ja"), "posts", work_id
      @work_id = work_id

    # https://enty.jp/kouyoumatsunaga?active_tab=posts#2
    in _, "enty.jp", username unless username in RESERVED_NAMES
      @username = username

    # https://enty.jp/en/kouyoumatsunaga?active_tab=posts#2
    in _, "enty.jp", ("en" | "ja"), username unless username in RESERVED_NAMES
      @username = username

    else
    end
  end

  def image_url?
    file.present?
  end

  def page_url
    "https://enty.jp/posts/#{work_id}" if work_id.present?
  end

  def profile_url
    "https://enty.jp/#{username}" if username.present?
  end
end
