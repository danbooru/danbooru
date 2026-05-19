# frozen_string_literal: true

class Source::URL::AppleMusic < Source::URL
  site "Apple Music", url: "https://music.apple.com", domains: %w[apple.com mzstatic.com]
  attr_reader :album_id, :album_name, :artist_name, :artist_id, :country_code, :full_image_url

  def self.match?(url)
    url.host.in?(%w[music.apple.com itunes.apple.com]) || url.domain == "mzstatic.com"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://music.apple.com/jp/album/mágico-catástrofe-digital-edition/1503302894
    # https://music.apple.com/jp/album/track-name/1503302894?i=1503302895
    # https://itunes.apple.com/us/album/disasterpiece/id1870255337
    in "music" | "itunes", "apple.com", country_code, "album", album_name, album_id
      @country_code = country_code
      @album_name = album_name
      @album_id = album_id.delete_prefix("id")

    # https://music.apple.com/us/artist/mori-calliope/1536368549
    # https://itunes.apple.com/us/artist/mori-calliope/id1536368549
    # https://music.apple.com/us/artist/guchiry/1438071892
    # https://music.apple.com/jp/artist/ぐちり/1438071892
    in "music" | "itunes", "apple.com", country_code, "artist", artist_name, artist_id
      @country_code = country_code
      @artist_name = artist_name
      @artist_id = artist_id.delete_prefix("id")

    # https://music.apple.com/album/mágico-catástrofe-digital-edition/1503302894
    # https://itunes.apple.com/album/mágico-catástrofe-digital-edition/id1503302894
    in "music" | "itunes", "apple.com", "album", album_name, album_id
      @album_name = album_name
      @album_id = album_id.delete_prefix("id")

    # https://a1.mzstatic.com/us/r1000/0/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg
    in /^a\d+/, "mzstatic.com", *path
      @full_image_url = "https://#{subdomain}.mzstatic.com/#{path.join("/")}"

    # https://is1-ssl.mzstatic.com/image/thumb/Features221/v4/cd/3d/11/cd3d1170-d972-2fda-0e5f-d2222f85b8d3/mzl.gxpkxsyd.jpg/190x190cc.webp (artist profile picture)
    # https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/9e/22/c2/9e22c2fb-ef9c-b79b-7417-8bc714b85e51/4580547326338.jpg/296x296bb.webp (album cover)
    # https://is1-ssl.mzstatic.com/image/thumb/Music113/v4/.../10000x10000.png
    in /^is(\d+)-ssl/, "mzstatic.com", "image", "thumb", *segments
      dir = filename.match?(/\A\d+x\d+/) ? segments[..-2] : segments
      @full_image_url = "https://a#{subdomain[/\d+/]}.mzstatic.com/us/r1000/0/#{dir.join("/")}"

    # https://music.apple.com/us/playlist/a-list-pop/pl.5ee8333dbe944d9f9151e97d92d1ead9
    # https://music.apple.com/us/song/orpheus/1870255338
    # https://music.apple.com/profile/Fll350L
    # https://apps.apple.com/us/app/hive-social/id1480835284
    # https://apps.apple.com/jp/developer/koubou-kamifuusen/id388176753
    # https://podcasts.apple.com/us/podcast/what-should-we-draw/id1087260817?mt=2
    # http://itunes.apple.com/jp/app/id718222634
    else
      nil

    end
  end

  def image_url?
    domain == "mzstatic.com"
  end

  def page_url
    if album_id.present?
      ["https://music.apple.com", country_code, "album", album_name, album_id].compact.join("/")
    end
  end

  def profile_url
    if artist_id.present?
      ["https://music.apple.com", country_code, "artist", artist_name, artist_id].compact.join("/")
    end
  end
end
