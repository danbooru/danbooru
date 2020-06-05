require_relative 'boot'
require "rails"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
# require "action_cable/engine"
# require "action_mailbox/engine"
# require "action_text/engine"
require "rails/test_unit/railtie"
# require "sprockets/railtie"

Bundler.require(*Rails.groups)

begin
  require_relative "danbooru_default_config"
  require_relative "danbooru_local_config"
rescue LoadError
end

module Danbooru
  mattr_accessor :config

  # if danbooru_local_config exists then use it as the config, otherwise use danbooru_default_config.
  if defined?(CustomConfiguration)
    self.config = EnvironmentConfiguration.new(CustomConfiguration.new)
  else
    self.config = EnvironmentConfiguration.new(Configuration.new)
  end

  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.active_record.schema_format = :sql
    config.encoding = "utf-8"
    config.filter_parameters += [:password, :password_confirmation, :password_hash, :api_key]
    # config.assets.enabled = true
    # config.assets.version = '1.0'
    config.autoload_paths += %W(#{config.root}/app/presenters #{config.root}/app/logical/concerns #{config.root}/app/logical #{config.root}/app/mailers)
    config.plugins = [:all]
    config.time_zone = 'Eastern Time (US & Canada)'

    raise "Danbooru.config.secret_key_base not configured" if Danbooru.config.secret_key_base.blank?
    config.secret_key_base = Danbooru.config.secret_key_base

    if Danbooru.config.mail_delivery_method.to_sym == :smtp
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = Danbooru.config.mail_settings
    elsif Danbooru.config.mail_delivery_method.to_sym == :sendmail
      config.action_mailer.delivery_method = :sendmail
      config.action_mailer.sendmail_settings = Danbooru.config.mail_settings
    end

    config.log_tags = [->(req) {"PID:#{Process.pid}"}]
    config.action_controller.action_on_unpermitted_parameters = :raise

    if File.exist?("#{config.root}/REVISION")
      config.x.git_hash = File.read("#{config.root}/REVISION").strip
    elsif system("type git > /dev/null && git rev-parse --show-toplevel > /dev/null")
      config.x.git_hash = `git rev-parse HEAD`.strip
    else
      config.x.git_hash = nil
    end

    config.after_initialize do
      Rails.application.routes.default_url_options = {
        host: Danbooru.config.hostname
      }
    end
  end

  I18n.enforce_available_locales = false
end
