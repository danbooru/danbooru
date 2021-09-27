if Danbooru.config.new_relic_license_key.present?
  require "new_relic/control"

  # https://github.com/newrelic/newrelic-ruby-agent/blob/1ef4082fe97fd19aeccb3f392a44ef3becae66d3/lib/newrelic_rpm.rb#L40
  # https://github.com/newrelic/newrelic-ruby-agent/blob/1ef4082fe97fd19aeccb3f392a44ef3becae66d3/lib/new_relic/agent.rb#L349
  NewRelic::Control.instance.init_plugin(
    app_name: Danbooru.config.canonical_app_name,
    license_key: Danbooru.config.new_relic_license_key,
    log_level: Danbooru.config.debug_mode ? "debug" : "error",
    #log: Rails.logger,
    "rake.tasks": ["maintenance:.*"],
    "browser_monitoring.auto_instrument": false,
    config: Rails.application.config,
  )
end
