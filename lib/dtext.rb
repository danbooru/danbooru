require "dtext/dtext"
require "dtext/version"
require "dtext/ruby"

class DText
  class Error < StandardError; end

  def self.parse(str, inline: false, disable_mentions: false, base_url: nil, domain: nil)
    c_parse(str, base_url, domain, inline, disable_mentions)
  end
end
