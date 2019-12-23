Rails.application.configure do
  if Rails.env.test? || Danbooru.config.redis_url.blank?
    cache_config = [:memory_store, { size: 32.megabytes }]
  else
    cache_config = [
      :redis_cache_store,
      {
        url: Danbooru.config.redis_url,
        namespace: nil,
        connect_timeout: 30, # default: 20 seconds
        write_timeout: 0.5, # default: 1 second
        read_timeout: 0.5, # default: 1 second
        reconnect_attempts: 0, # default: 0
        error_handler: lambda { |method:, returning:, exception:|
          DanbooruLogger.log(exception, method: method, returning: returning)
        }
      }
    ]
  end

  cache_store = ActiveSupport::Cache.lookup_store(cache_config)

  config.cache_store = cache_store
  config.action_controller.cache_store = cache_store
  Rails.cache = cache_store
end
