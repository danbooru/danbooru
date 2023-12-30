# frozen_string_literal: true

class Source::URL::CiEn < Source::URL
  attr_reader :creator_id, :article_id, :image_type

  def self.match?(url)
    url.host.in?(%w[ci-en.jp ci-en.net ci-en.dlsite.com media.ci-en.jp])
  end

  def parse
    case host

    in ("ci-en.jp" | "ci-en.net" | "ci-en.dlsite.com")
      case [*path_segments]

      # https://ci-en.net/creator/11019/article/921762
      # https://ci-en.dlsite.com/creator/5290/article/998146
      in "creator", creator_id, "article", article_id, *rest
        @creator_id = creator_id
        @article_id = article_id

      # https://ci-en.net/creator/11019
      # https://ci-en.net/creator/11019/article
      # https://ci-en.dlsite.com/creator/5290
      in "creator", creator_id, *rest
        @creator_id = creator_id

      else
        nil
      end

    in "media.ci-en.jp"
      case [*path_segments]

      # https://media.ci-en.jp/private/attachment/creator/00011019/62a643d6423c18ec1be16826d687cefb47d8304de928a07c6389f8188dfe6710/image-800.jpg?px-time=1700517240&px-hash=eb626eafb7e5733c96fb0891188848dac10cb84c
      # https://media.ci-en.jp/public/article_cover/creator/00020980/a65e3c05e2082018f4f28e99e7bc69b67ae96bb6f40b4a4b580ca939f435430d/image-1280-c.jpg
      # https://media.ci-en.jp/public/cover/creator/00013341/cc4ec0e58b9ad36c8f36aca9faee334239761b4b2969d379d6629a5e07a52a6c/image-990-c.jpg
      in _, image_type, "creator", creator_id, *rest
        @creator_id = creator_id.to_i.to_s
        @image_type = image_type

      end

    else
      nil
    end
  end

  def site_name
    "Ci-En"
  end

  def image_url?
    host == "media.ci-en.jp"
  end

  def page_url
    if article_id.present?
      "#{profile_url}/article/#{article_id}"
    elsif !image_url?
      profile_url
    end
  end

  # All-ages and R18 pages urls are interchangeable and will redirect to the correct site
  def profile_url
    if creator_id.present?
      "https://ci-en.net/creator/#{creator_id}"
    end
  end

  # Public profiles require a self-introduction article, so every profile url is also a page url
  def profile_url?
    profile_url.present? && page_url == profile_url && !image_url?
  end
end
