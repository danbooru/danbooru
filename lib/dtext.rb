require "dtext/dtext"
require "dtext/version"
require "dtext/ruby"
require "nokogiri"

class DText
  class Error < StandardError; end

  def self.parse(str, inline: false, disable_mentions: false, base_url: nil)
    html = c_parse(str, inline, disable_mentions)
    html = resolve_relative_urls(html, base_url) if base_url
    html
  end

  private

  def self.resolve_relative_urls(html, base_url)
    nodes = Nokogiri::HTML.fragment(html)
    nodes.traverse do |node|
      if node[:href]&.start_with?("/")
        node[:href] = base_url.chomp("/") + node[:href]
      end
    end
    nodes.to_s
  end
end
