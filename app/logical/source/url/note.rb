# frozen_string_literal: true

# @see Source::Extractor::Note
class Source::URL::Note < Source::URL
  RESERVED_USERNAMES = %w[hashtag intent login magazine signup terms topic users]

  attr_reader :username, :post_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[note.com note.mu st-note.com]) || url.host.in?(%w[d291vdycu0ht11.cloudfront.net d2l930y2yx77uc.cloudfront.net note-cakes-web-dev.s3.amazonaws.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://assets.st-note.com/img/1623726537463-B8LOZ1JZUS.png?width=2000&height=2000&fit=bounds&format=jpg&quality=85 (sample)
    # https://assets.st-note.com/img/1623726537463-B8LOZ1JZUS.png (full resolution, but not the original file; potentially recompressed or transcoded to .webp)
    # https://d2l930y2yx77uc.cloudfront.net/img/1623726537463-B8LOZ1JZUS.png (original file)
    # https://note-cakes-web-dev.s3.amazonaws.com/img/1623726537463-B8LOZ1JZUS.png (original file)
    in _, _, "img", file if image_url?
      @full_image_url = "https://d2l930y2yx77uc.cloudfront.net/img/#{file}"

    # https://assets.st-note.com/production/uploads/images/14533920/profile_812af2baf1a6eb05c62182d43b0cbdbe.png?width=60 (profile picture)
    # https://assets.st-note.com/production/uploads/images/14533920/812af2baf1a6eb05c62182d43b0cbdbe.png (full resolution, but not original file)
    # https://assets.st-note.com/production/uploads/images/17105324/square_middle_c647f6629bcfe2638e23924d96a7aae4.jpeg?fit=bounds&format=jpeg&quality=45&width=112 (thumbnail)
    # https://assets.st-note.com/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg (full resolution, but not original file)
    # https://d2l930y2yx77uc.cloudfront.net/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg (original file)
    # https://note-cakes-web-dev.s3.amazonaws.com/production/uploads/images/17105324/c647f6629bcfe2638e23924d96a7aae4.jpeg (original file)
    in _, _, "production", "uploads", "images", image_id, _ if image_url?
      @full_image_url = "https://d2l930y2yx77uc.cloudfront.net/production/uploads/images/#{image_id}/#{filename[/\h+$/]}.#{file_ext}"

    # https://note.com/koma_labo/n/n32fb90fac512
    # https://note.mu/koma_labo/n/n32fb90fac512
    in _, ("note.com" | "note.mu"), username, "n", post_id
      @username = username
      @post_id = post_id

    # https://note.com/koma_labo
    # https://note.com/schizo_emu/m/m4d6814cea4e3
    # https://note.mu/schizo_emu/m/m4d6814cea4e3
    in _, ("note.com" | "note.mu"), username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://d291vdycu0ht11.cloudfront.net/nuxt/production/img/ebc825f.png
    # https://biz.note.com/n/n45e0b603c87e
    # https://note.finetoday.com/n/n419c467ac34e
    # https://spodge.sports-f.co.jp/n/n7413cfd77176
    # https://ur-toshikikou-gov.note.jp/n/nc13367bbd73c
    else
      nil
    end
  end

  def page_url
    "https://note.com/#{username}/n/#{post_id}" if username.present? && post_id.present?
  end

  def profile_url
    "https://note.com/#{username}" if username.present?
  end
end
