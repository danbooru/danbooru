require 'memcache'

unless defined?(MEMCACHE)
  MEMCACHE = MemCache.new :c_threshold => 10_000, :compression => true, :debug => false, :namespace => Danbooru.config.app_name.gsub(/[^A-Za-z0-9]/, "_"), :readonly => false, :urlencode => false
  MEMCACHE.servers = Danbooru.config.memcached_servers
end
