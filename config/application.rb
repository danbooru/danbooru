require_relative 'boot'
require 'rails/all'

if defined?(Bundler)
  Bundler.require(:default, Rails.env)
end
Bundler.require(*Rails.groups)

module Danbooru
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    
    config.active_record.schema_format = :sql
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.autoload_paths += %W(#{config.root}/app/presenters #{config.root}/app/logical #{config.root}/app/mailers)
    config.plugins = [:all]
    config.time_zone = 'Eastern Time (US & Canada)'
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {:enable_starttls_auto => false}
    config.action_mailer.perform_deliveries = true
    config.log_tags = [lambda {|req| "PID:#{Process.pid}"}]
    config.action_controller.action_on_unpermitted_parameters = :raise

    if File.exists?("#{config.root}/REVISION")
      config.x.git_hash = File.read("#{config.root}/REVISION").strip
    elsif system("type git > /dev/null && git rev-parse --show-toplevel > /dev/null")
      config.x.git_hash = %x(git rev-parse --short HEAD).strip
    else
      config.x.git_hash = nil
    end

    config.after_initialize do
      Rails.application.routes.default_url_options = {
        host: Danbooru.config.hostname,
      }
    end
  end

  I18n.enforce_available_locales = false
end
