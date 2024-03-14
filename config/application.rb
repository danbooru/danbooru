# This file runs after config/boot.rb and before config/environment.rb. It loads
# Rails, loads the gems, loads the Danbooru configuration, and does some basic
# Rails configuration.
#
# @see https://guides.rubyonrails.org/initialization.html

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load the default Danbooru configuration from config/danbooru_default_config.rb
# and the custom config from config/danbooru_local_config.rb.
begin
  require_relative "danbooru_default_config"
  require_relative ENV.fetch("DANBOORU_CONFIG_FILE", "danbooru_local_config")
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
    config.load_defaults 7.1
    config.active_record.schema_format = :sql

    # https://guides.rubyonrails.org/configuring.html#config-active-support-cache-format-version
    config.active_support.cache_format_version = 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.autoload_paths += %W(#{config.root}/app/presenters #{config.root}/app/logical/concerns #{config.root}/app/logical #{config.root}/app/mailers)
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_model.i18n_customize_full_message = true

    # Hide sensitive model attributes and request params in exception messages
    # and logs. These are substring matches, so they match any attribute or
    # request param containing the word 'password' etc.
    #
    # https://guides.rubyonrails.org/configuring.html#config-filter-parameters
    config.filter_parameters += [:password, :api_key, :secret, :ip_addr, :address, :email_verification_key, :signed_id] if Rails.env.production?

    raise "Danbooru.config.secret_key_base not configured" if Danbooru.config.secret_key_base.blank?
    config.secret_key_base = Danbooru.config.secret_key_base

    if Danbooru.config.mail_delivery_method.to_sym == :smtp
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = Danbooru.config.mail_settings
    elsif Danbooru.config.mail_delivery_method.to_sym == :sendmail
      config.action_mailer.delivery_method = :sendmail
      config.action_mailer.sendmail_settings = Danbooru.config.mail_settings
    end

    # https://guides.rubyonrails.org/action_mailer_basics.html#intercepting-and-observing-emails
    # app/logical/email_delivery_logger.rb
    config.action_mailer.interceptors = ["EmailDeliveryLogger"]

    # https://guides.rubyonrails.org/configuring.html#config-action-mailer-delivery-job
    # app/jobs/mail_delivery_job.rb
    config.action_mailer.delivery_job = "MailDeliveryJob"

    logger           = ActiveSupport::Logger.new(STDERR)
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
    config.log_tags  = [->(req) {"PID:#{Process.pid}"}]
    config.log_level = Danbooru.config.log_level

    config.action_controller.action_on_unpermitted_parameters = :raise

    if ENV["DOCKER_IMAGE_REVISION"].present?
      config.x.git_hash = ENV["DOCKER_IMAGE_REVISION"]
    elsif system("type git > /dev/null && git rev-parse --show-toplevel > /dev/null")
      config.x.git_hash = `git rev-parse HEAD`.strip
    else
      config.x.git_hash = nil
    end

    # In development mode, allow the site to be embedded in an <iframe> so that it can be viewed inside things like VS Code or Github Codespaces.
    config.action_dispatch.default_headers.delete("X-Frame-Options") if Rails.env.development?

    # Disable the origin check to fix `HTTP Origin header didn't match request.base_url` errors when running behind a reverse
    # proxy. This is necessary because some reverse proxies (such as Github Codespaces) set the Origin header incorrectly.
    if ENV["DANBOORU_REVERSE_PROXY"] == "true"
      config.action_controller.forgery_protection_origin_check = false
    end

    config.after_initialize do
      Rails.application.routes.default_url_options = {
        host: Danbooru::URL.parse!(Danbooru.config.canonical_url).host,
        port: Danbooru::URL.parse!(Danbooru.config.canonical_url).port
      }
    end
  end

  I18n.enforce_available_locales = false
end
