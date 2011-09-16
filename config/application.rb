require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the default gems, the ones in the
# current environment and also include :assets gems if in development
# or test environments.
Bundler.require *Rails.groups(:assets) if defined?(Bundler)

module Danbooru
  class Application < Rails::Application
    config.active_record.schema_format = :sql
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.assets.enabled = true
    config.autoload_paths += %W(#{config.root}/app/presenters #{config.root}/app/logical #{config.root}/app/mailers)
    config.plugins = [:all]
    config.time_zone = 'Eastern Time (US & Canada)'
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {:enable_starttls_auto => false}
    config.action_mailer.perform_deliveries = true
  end
end
