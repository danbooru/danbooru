# frozen_string_literal: true

require_relative "lib/media_file/version"

Gem::Specification.new do |spec|
  spec.name = "media_file"
  spec.version = MediaFile::VERSION
  spec.authors = ["evazion", "nonamethanks"]

  spec.summary = "Danbooru's library for reading, validating, and resizing uploaded files"
  spec.homepage = "https://github.com/danbooru/danbooru"
  spec.license = "BSD-2-Clause"
  spec.required_ruby_version = ">= 4.0"

  spec.files = Dir["lib/**/*.rb", "bin/*"]
  spec.bindir = "bin"
  spec.executables = %w[media-ls media-conv]

  spec.add_dependency "activesupport", "~> 8"
  spec.add_dependency "concurrent-ruby", "~> 1"
  spec.add_dependency "ffi", "~> 1"
  spec.add_dependency "ffi-libarchive", "~> 1" # Used by bin/archive.
  spec.add_dependency "logger", "~> 1"
  spec.add_dependency "memoist", "~> 0.16"
  spec.add_dependency "ruby-vips", "~> 2" # Used by bin/image.
  spec.add_dependency "rubyzip", "~> 3" # Used by bin/archive.
  spec.metadata["rubygems_mfa_required"] = "true"
end
