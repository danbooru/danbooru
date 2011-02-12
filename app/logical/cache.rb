class Cache
  def self.incr(key, expiry = 0)
    val = Cache.get(key, expiry)
    Cache.put(key, val.to_i + 1)
    ActiveRecord::Base.logger.debug('MemCache Incr %s' % [key])
  end
  
  def self.decr(key, expiry = 0)
    val = Cache.get(key, expiry)
    if val.to_i > 0
      Cache.put(key, val.to_i - 1)
    end
    ActiveRecord::Base.logger.debug('MemCache Decr %s' % [key])
  end
  
  def self.get_multi(keys, prefix, expiry = 0)
    key_to_sanitized_key_hash = keys.inject({}) do |hash, x|
      hash[x] = "#{prefix}:#{Cache.sanitize(x)}"
      hash
    end
    start_time = Time.now
    sanitized_key_to_value_hash = MEMCACHE.get_multi(key_to_sanitized_key_hash.values)
    elapsed = Time.now - start_time
    {}.tap do |result_hash|
      key_to_sanitized_key_hash.each do |key, sanitized_key|
        if sanitized_key_to_value_hash.has_key?(sanitized_key)
          result_hash[key] = sanitized_key_to_value_hash[sanitized_key]
        else
          result_hash[key] = yield(key)
          Cache.put(sanitized_key, result_hash[key], expiry)
        end
      end
      
      ActiveRecord::Base.logger.debug('MemCache Multi-Get (%0.6f)  %s' % [elapsed, keys.join(",")])
    end
  end
  
  def self.get(key, expiry = 0)
    begin
      start_time = Time.now
      value = MEMCACHE.get key
      elapsed = Time.now - start_time
      ActiveRecord::Base.logger.debug('MemCache Get (%0.6f)  %s' % [elapsed, key])
      if value.nil? and block_given? then
        value = yield
        MEMCACHE.set key, value, expiry
      end
      value
    rescue MemCache::MemCacheError => err
      ActiveRecord::Base.logger.debug "MemCache Error: #{err.message}"
      if block_given? then
        value = yield
        put key, value, expiry
      end
      value
    end
  end
  
  def self.put(key, value, expiry = 0)
    key.gsub!(/\s/, "_")
    key = key[0, 200]
    
    begin
      start_time = Time.now
      MEMCACHE.set key, value, expiry
      elapsed = Time.now - start_time
      ActiveRecord::Base.logger.debug('MemCache Set (%0.6f)  %s' % [elapsed, key])
      value
    rescue MemCache::MemCacheError => err
      ActiveRecord::Base.logger.debug "MemCache Error: #{err.message}"
      nil
    end
  end
  
  def self.delete(key, delay = nil)
    begin
      start_time = Time.now
      MEMCACHE.delete key, delay
      elapsed = Time.now - start_time
      ActiveRecord::Base.logger.debug('MemCache Delete (%0.6f)  %s' % [elapsed, key])
      nil
    rescue MemCache::MemCacheError => err
      ActiveRecord::Base.logger.debug "MemCache Error: #{err.message}"
      nil
    end
  end
  
  def self.sanitize(key)
    key.gsub(/\W/) {|x| "%#{x.ord}"}.slice(0, 240)
  end
end
