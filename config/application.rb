require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Danbooru
  class Application < Rails::Application
    config.active_record.schema_format = :sql
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.assets.enabled = true
    config.autoload_paths += %W(#{config.root}/app/presenters #{config.root}/app/logical #{config.root}/app/mailers)
    config.plugins = [:all]
    config.time_zone = 'Eastern Time (US & Canada)'
    # config.action_view.javascript_expansions[:defaults] = [
    #   "src/lib/jquery-1.6.0.min.js",
    #   "src/lib/jquery-ui-1.8.9.custom.min.js",
    #   "src/lib/jquery.timeout.js",
    #   "src/lib/rails.js",
    #   "src/app/common.js",
    #   "src/app/cookie.js",
    #   "src/app/utility.js",
    #   "src/app/posts.js",
    #   "src/app/comments.js",
    #   "src/app/uploads.js",
    #   "src/app/users.js",
    #   "src/app/favorites.js",
    #   "src/app/post_flags.js",
    #   "src/app/post_appeals.js",
    #   "src/app/post_moderation.js",
    #   "src/app/pools.js",
    #   "src/app/wiki_pages.js",
    #   "src/app/forum_posts.js",
    #   "src/app/notes.js"
    # ]
  end
end
