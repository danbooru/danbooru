unless defined?(MEMCACHE)
  MEMCACHE = Dalli::Client.new(Danbooru.config.memcached_servers, :namespace => Danbooru.config.app_name.gsub(/[^A-Za-z0-9]/, "_"))
end
