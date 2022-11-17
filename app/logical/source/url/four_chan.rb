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
    in _, ("4channel.org" | "4chan.org"), board, "thread", /\A[0-9]+\z/ => thread_id
      @board = board
      @thread_id = thread_id.to_i
      @post_id = fragment.to_s[/^p([0-9]+)$/, 1]&.to_i

    # https://i.4cdn.org/vt/1668729957824814.webm
    # https://i.4cdn.org/vt/1668729957824814s.jpg
    in "i", "4cdn.org", board, /\A([0-9]+)(s?)\./
      @board = board
      @image_id = $1.to_i
      @image_type = $2 == "s" ? :preview : :original
      @full_image_url = url.to_s if @image_type == :original

    else
      nil
    end
  end

  def image_url?
    host == "i.4cdn.org"
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
