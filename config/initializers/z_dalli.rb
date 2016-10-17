unless defined?(MEMCACHE)
  MEMCACHE = Dalli::Client.new(Danbooru.config.memcached_servers, :namespace => Danbooru.config.app_name.gsub(/[^A-Za-z0-9]/, "_"))
end

begin
  MEMCACHE.get("x")
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
  MEMCACHE = MemcacheMock.new
end

if Rails.env.production?
  Rails.application.configure do
    config.cache_store = :dalli_store, Danbooru.config.memcached_servers
  end
end
