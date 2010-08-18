require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Danbooru
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/app/presenters #{config.root}/app/logical)
    config.plugins = [:all]
    config.time_zone = 'Eastern Time (US & Canada)'
    config.encoding = "utf-8"    
    config.active_record.schema_format = :sql
    config.filter_parameters << :password
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  end
end
