# frozen_string_literal: true

require_relative "lib/http"

Gem::Specification.new do |spec|
  spec.name = "danbooru_http"
  spec.version = Danbooru::Http::VERSION
  spec.authors = ["evazion", "nonamethanks"]
  spec.email = ["noizave@gmail.com"]

  spec.summary = "Danbooru HTTP Library."
  spec.homepage = "https://github.com/danbooru/danbooru"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
end
