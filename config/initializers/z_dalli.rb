Rails.application.configure do
  begin
    if Rails.env.test?
      config.cache_store = :memory_store, { size: 32.megabytes }
      Rails.cache = ActiveSupport::Cache.lookup_store(Rails.application.config.cache_store)
    else
      config.cache_store = :dalli_store, Danbooru.config.memcached_servers, { namespace: Danbooru.config.safe_app_name }
      Rails.cache = ActiveSupport::Cache.lookup_store(Rails.application.config.cache_store)

      Rails.cache.dalli.alive!
    end
  rescue Dalli::RingError => e
    puts "-" * 40
    puts "WARNING! MEMCACHE SERVER NOT FOUND! You will experience performance degradation."
    puts e.to_s
    puts "-- BEGIN STACKTRACE --"
    e.backtrace.each do |line|
      puts line
    end
    puts "-- END STACKTRACE --"
    puts "-" * 40

    config.cache_store = :memory_store, { size: 32.megabytes }
    Rails.cache = ActiveSupport::Cache.lookup_store(Rails.application.config.cache_store)
  end
end
