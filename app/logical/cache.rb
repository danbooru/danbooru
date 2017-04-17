class Cache
  def self.get_multi(keys, prefix)
    sanitized_key_to_key_hash = keys.map do |key|
      ["#{prefix}:#{Cache.sanitize(key)}", key]
    end.to_h

    sanitized_keys = sanitized_key_to_key_hash.keys
    sanitized_key_to_value_hash = Rails.cache.fetch_multi(*sanitized_keys) do |sanitized_key|
      key = sanitized_key_to_key_hash[sanitized_key]
      yield key
    end

    keys_to_values_hash = sanitized_key_to_value_hash.transform_keys(&sanitized_key_to_key_hash)
    keys_to_values_hash
  end

  def self.get(key, expiry_in_seconds = nil, &block)
    Rails.cache.fetch(key, expires_in: expiry_in_seconds, &block)
  rescue => err
    Rails.logger.debug { "MemCache Error: #{err.message}" }
    nil
  end

  def self.put(key, value, expiry_in_seconds = nil)
    Rails.cache.write(key, value, expires_in: expiry_in_seconds)
    value
  rescue => err
    Rails.logger.debug { "MemCache Error: #{err.message}" }
    nil
  end

  def self.delete(key)
    Rails.cache.delete(key)
    nil
  rescue => err
    Rails.logger.debug { "MemCache Error: #{err.message}" }
    nil
  end

  def self.clear
    Rails.cache.clear
  end

  def self.sanitize(key)
    key.gsub(/\W/) {|x| "%#{x.ord}"}.slice(0, 230)
  end

  def self.hash(string)
    CityHash.hash64(string).to_s(36)
  end
end
