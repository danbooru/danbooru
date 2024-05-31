# frozen_string_literal: true

class Source::URL::Toyhouse < Source::URL
  attr_reader :image_id, :image_hash, :character_id, :character_name, :gallery_id, :gallery_name, :username

  def self.match?(url)
    url.domain == "toyhou.se"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://f2.toyhou.se/file/f2-toyhou-se/characters/19108771?1670101610
    # https://file.toyhou.se/characters/654769?1480733146
    in *, "characters", character_id if image_url?
      @character_id = character_id

    # https://f2.toyhou.se/file/f2-toyhou-se/thumbnails/58037599_Ov5.png
    # https://f2.toyhou.se/file/f2-toyhou-se/images/58037599_Ov5j4w66lQRw9G4.png
    # https://f2.toyhou.se/file/f2-toyhou-se/watermarks/73741617_fFIUcJscE.png
    # https://file.toyhou.se/images/2362055_rxkHiEqZOFFaOtX.png
    # https://file.toyhou.se/thumbnails/2362055_rxk.png
    in *, ("thumbnails" | "watermarks" | "images"), /^\d+_[a-zA-Z0-9]+\./ if image_url?
      @image_id, _rest = filename.split("_")

    # https://toyhou.se/~images/58037599
    in _, "toyhou.se", "~images", image_id
      @image_id = image_id

    # https://toyhou.se/2712983.cudlil/19136842.reference-sheet/73741617
    in _, "toyhou.se", /^\d+\./ => character, /^\d+\./ => gallery, /^\d+$/ => image_id
      @character_id, _, @character_name = character.partition(".")
      @gallery_id, _, @gallery_name = gallery.partition(".")
      @image_id = image_id

    # https://toyhou.se/2712983.cudlil/19136842.reference-sheet#73741617
    in _, "toyhou.se", /^\d+\./ => character, /^\d+\./ => gallery
      @character_id, _, @character_name = character.partition(".")
      @gallery_id, _, @gallery_name = gallery.partition(".")
      @image_id = fragment if fragment&.match?(/^\d+$/)

    # https://toyhou.se/19108771.june-human-/58037599
    in _, "toyhou.se", /^\d+\./ => character, /^\d+$/ => image_id
      @character_id, _, @character_name = character.partition(".")
      @image_id = image_id

    # https://toyhou.se/19108771.june-human-#58037599
    # https://toyhou.se/19108771.june-human-/gallery
    in _, "toyhou.se", /^\d+\./ => character, *rest
      @character_id, _, @character_name = character.partition(".")
      @image_id = fragment if fragment&.match?(/^\d+$/)

    # https://toyhou.se/427Deer
    # https://toyhou.se/427Deer#55232380
    # https://toyhou.se/427Deer/characters
    # https://toyhou.se/lilcudds/characters/folder:539748
    in _, "toyhou.se", username, *rest unless username.starts_with?("~")
      @username = username
      @image_id = fragment if fragment&.match?(/^\d+$/)

    # https://f2.toyhou.se/file/f2-toyhou-se/users/Missing_teeth?965 (profile picture)
    # https://toyhou.se/~forums/71.art-marketplace/36671.-c-o-m-m-i-s-s-i-o-n-open- (forum post)
    else
      nil
    end
  end

  def image_url?
    host.in?(%w[f2.toyhou.se file.toyhou.se])
  end

  def bad_source?
    !image_url? && image_id.blank?
  end

  def page_url
    if character_id.present? && character_name.present? && gallery_id.present? && gallery_name.present? && image_id.present?
      "https://toyhou.se/#{character_id}.#{character_name}/#{gallery_id}.#{gallery_name}/#{image_id}"
    elsif character_id.present? && character_name.present? && gallery_id.present? && gallery_name.present?
      "https://toyhou.se/#{character_id}.#{character_name}/#{gallery_id}.#{gallery_name}"
    elsif character_id.present? && character_name.present? && image_id.present?
      "https://toyhou.se/#{character_id}.#{character_name}/#{image_id}"
    elsif character_id.present? && character_name.present?
      "https://toyhou.se/#{character_id}.#{character_name}"
    elsif image_id.present?
      "https://toyhou.se/~images/#{image_id}"
    end
  end

  def profile_url
    "https://toyhou.se/#{username}" if username.present?
  end
end
