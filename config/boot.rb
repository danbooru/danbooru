# This is the first file that runs during Rails boot. The next files to run are
# config/application.rb, then config/environment.rb.
#
# @see https://guides.rubyonrails.org/initialization.html
# @see https://github.com/Shopify/bootsnap

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Set up the load path for gems listed in the Gemfile. Does not actually load the gems; that happens in
# config/application.rb.
require "bundler/setup"

# Speed up boot time by caching expensive operations.
require "bootsnap/setup"