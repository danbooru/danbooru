# frozen_string_literal: true

# @see https://github.com/4chan/4chan-API
# @see https://github.com/4chan/4chan-API/blob/master/pages/User_images_and_static_content.md
class Source::URL::FourChan < Source::URL
  attr_reader :board, :thread_id, :post_id, :image_type, :image_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[4cdn.org 4chan.org 4channel.org])
  end

  def site_name
    "4chan"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://boards.4channel.org/vt/thread/37293562#p37294005
    # http://boards.4chan.org/a/res/41938201
    # http://zip.4chan.org/jp/res/3598845.html
    in _, ("4channel.org" | "4chan.org"), board, ("thread" | "res"), /\A([0-9]+)(?:\.html)?\z/
      @board = board
      @thread_id = $1.to_i
      @post_id = fragment.to_s[/^p([0-9]+)$/, 1]&.to_i

    # https://i.4cdn.org/vt/1668729957824814.webm
    # https://i.4cdn.org/vt/1668729957824814s.jpg
    # https://is2.4chan.org/vg/1663135782567622.jpg
    # http://is.4chan.org/vp/1483914199051.jpg
    in ("i" | "is" | "is2"), _, board, /\A([0-9]+)(s?)\./
      @board = board
      @image_id = $1.to_i
      @image_type = ($2 == "s") ? :preview : :original
      @full_image_url = url.to_s if @image_type == :original

    # http://images.4chan.org/vg/src/1378607754334.jpg
    # http://orz.4chan.org/e/src/1202811803217.png
    # http://zip.4chan.org/a/src/1201922408724.jpg
    # http://cgi.4chan.org/r/src/1210870653551.jpg
    # http://cgi.4chan.org/f/src/0931.swf
    # http://img.4chan.org/b/src/1226194386317.jpg
    in _, "4chan.org", board, "src", /\A([0-9]+)(s?)\./
      @board = board
      @image_id = $1.to_i
      @image_type = ($2 == "s") ? :preview : :original
      @full_image_url = url.to_s if @image_type == :original

    else
      nil
    end
  end

  def image_url?
    file_ext.in?(%w[jpg png gif webm swf])
  end

  def page_url
    if thread_id.present?
      url.to_s
    end
  end

  def api_url
    "https://a.4cdn.org/#{board}/thread/#{thread_id}.json" if board.present? && thread_id.present?
  end
end
