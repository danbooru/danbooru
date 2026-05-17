# frozen_string_literal: true

require "dtext/version"
require "dtext/ruby"

# Load the C extension from the locally compiled lib/dtext/dtext.so if it exists, or from the installed gem's
# installation directory if it doesn't exist.
begin
  require "dtext/dtext"
rescue LoadError
  require "rbconfig"

  extension_name = "dtext.#{RbConfig::CONFIG.fetch("DLEXT")}"
  extension_paths = Gem.path.flat_map do |gem_path|
    [
      File.join(gem_path, "gems", "dtext_rb-#{DText::VERSION}", "lib", "dtext", extension_name),
      File.join(gem_path, "extensions", Gem::Platform.local.to_s, Gem.extension_api_version, "dtext_rb-#{DText::VERSION}", "dtext", extension_name),
    ]
  end

  extension_path = extension_paths.find { |path| File.exist?(path) }
  require extension_path
end

begin
  require "zeitwerk"

  loader = Zeitwerk::Loader.for_gem
  loader.enable_reloading
  loader.inflector.inflect("dtext" => "DText")
  #loader.logger = Logger.new(STDERR)
  loader.setup
rescue LoadError
end

class DText
  class Error < StandardError; end

  def self.parse(str, inline: false, media_embeds: true, disable_mentions: false, base_url: nil, domain: nil, internal_domains: [], emoji_list: [])
    c_parse(str, base_url, domain, internal_domains, emoji_list, inline, disable_mentions, media_embeds)
  end
end
