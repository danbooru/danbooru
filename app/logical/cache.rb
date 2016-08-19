class Cache
  def self.incr(key)
    MEMCACHE.incr(key)
    ActiveRecord::Base.logger.debug('MemCache Incr %s' % [key])
  end

  def self.decr(key)
    MEMCACHE.decr(key)
    ActiveRecord::Base.logger.debug('MemCache Decr %s' % [key])
  end

  def self.get_multi(keys, prefix, expiry_in_seconds = nil)
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
          Cache.put(sanitized_key, result_hash[key], expiry_in_seconds)
        end
      end

      ActiveRecord::Base.logger.debug('MemCache Multi-Get (%0.6f)  %s' % [elapsed, keys.join(",")])
    end
  end

  def self.get(key, expiry_in_seconds = nil)
    start_time = Time.now
    value = MEMCACHE.get key
    elapsed = Time.now - start_time
    if expiry_in_seconds
      expiry = expiry_in_seconds
    else
      expiry = 0
    end
    ActiveRecord::Base.logger.debug('MemCache Get (%0.6f)  %s -> %s' % [elapsed, key, value])
    if value.nil? and block_given? then
      value = yield
      MEMCACHE.set key, value, expiry
    end
    value
  rescue => err
    ActiveRecord::Base.logger.debug "MemCache Error: #{err.message}"
    nil
  end

  def self.put(key, value, expiry_in_seconds = nil)
    start_time = Time.now
    if expiry_in_seconds
      expiry = expiry_in_seconds
    else
      expiry = 0
    end      
    MEMCACHE.set key, value, expiry
    elapsed = Time.now - start_time
    ActiveRecord::Base.logger.debug('MemCache Set (%0.6f)  %s -> %s' % [elapsed, key, value])
    value
  rescue => err
    ActiveRecord::Base.logger.debug "MemCache Error: #{err.message}"
    nil
  end

  def self.delete(key, delay = nil)
    start_time = Time.now
    MEMCACHE.delete key
    elapsed = Time.now - start_time
    ActiveRecord::Base.logger.debug('MemCache Delete (%0.6f)  %s' % [elapsed, key])
    nil
  rescue => err
    ActiveRecord::Base.logger.debug "MemCache Error: #{err.message}"
    nil
  end

  def self.sanitize(key)
    key.gsub(/\W/) {|x| "%#{x.ord}"}.slice(0, 230)
  end

  def self.hash(string)
    CityHash.hash64(string).to_s(36)
  end
end
