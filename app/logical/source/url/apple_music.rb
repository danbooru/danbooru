# frozen_string_literal: true

class Source::URL::AppleMusic < Source::URL
  site "Apple Music", url: "https://music.apple.com"
  attr_reader :album_id, :album_name, :country_code, :full_image_url

  def self.match?(url)
    url.host == "music.apple.com" || url.domain == "mzstatic.com"
  end

  def parse
    case [host, *path_segments]

    # https://music.apple.com/jp/album/mágico-catástrofe-digital-edition/1503302894
    # https://music.apple.com/jp/album/track-name/1503302894?i=1503302895
    # https://itunes.apple.com/us/album/title/id12345
    in "music.apple.com", country_code, "album", album_name, album_id
      @country_code = country_code
      @album_name = album_name
      @album_id = album_id.delete_prefix("id")

    # https://music.apple.com/album/mágico-catástrofe-digital-edition/1503302894
    in "music.apple.com", "album", album_name, album_id
      @album_name = album_name
      @album_id = album_id.delete_prefix("id")

    # https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg/296x296bb.webp
    # https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/.../10000x10000.png
    in host, "image", "thumb", *rest if host.end_with?("mzstatic.com")
      if rest.last.to_s.match?(/\A\d+x\d+.*\.\w+\z/i)
        *prefix, _filename = rest
        @full_image_url = "https://#{host}/image/thumb/#{prefix.join("/")}/10000x10000.png"
      else
        @full_image_url = to_s
      end

    else
      nil
    end
  end

  def image_url?
    domain == "mzstatic.com"
  end

  def page_url
    if album_id
      country = country_code ? "#{country_code}/" : ""
      slug = album_name ? "#{album_name}/" : ""
      return "https://music.apple.com/#{country}album/#{slug}#{album_id}"
    end
    nil
  end
end
