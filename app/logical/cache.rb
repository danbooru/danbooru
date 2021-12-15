# frozen_string_literal: true

# A wrapper around `Rails.cache` that adds some extra helper methods. All
# Danbooru code should use this class instead of using `Rails.cache` directly.
#
# In production, the cache is backed by Redis. In development, it's a temporary
# in-memory cache.
#
# @see config/initializers/cache_store.rb
# @see https://guides.rubyonrails.org/caching_with_rails.html#cache-stores
# @see https://api.rubyonrails.org/classes/ActiveSupport/Cache/RedisCacheStore.html
class Cache
  # Get multiple values from the cache at once.
  # @param keys [Array<String>] the list of keys to fetch
  # @param prefix [String] a prefix for each cache key
  # @return [Hash<String, Object>] a map from cache keys to cache values
  def self.get_multi(keys, prefix)
    sanitized_key_to_key_hash = keys.map do |key|
      ["#{prefix}:#{Cache.hash(key)}", key]
    end.to_h

    sanitized_keys = sanitized_key_to_key_hash.keys
    sanitized_key_to_value_hash = Rails.cache.fetch_multi(*sanitized_keys) do |sanitized_key|
      key = sanitized_key_to_key_hash[sanitized_key]
      yield key
    end

    keys_to_values_hash = sanitized_key_to_value_hash.transform_keys(&sanitized_key_to_key_hash)
    keys_to_values_hash
  end

  # Get a value from the cache. If the value isn't in the cache, use the block
  # to generate the value.
  # @param key [String] the key to fetch
  # @param expiry_in_seconds [Integer] the lifetime of the cached value
  # @param options [Hash] options to pass to Rails.cache.fetch
  # @return the cached value
  def self.get(key, expiry_in_seconds = nil, **options, &block)
    Rails.cache.fetch(key, expires_in: expiry_in_seconds, **options, &block)
  end

  # Write a value to the cache.
  # @param key [String] the key to cache
  # @param value [Object] the value to cache
  # @param expiry_in_seconds [Integer] the lifetime of the cached value
  # @return the cached value
  def self.put(key, value, expiry_in_seconds = nil)
    Rails.cache.write(key, value, expires_in: expiry_in_seconds)
    value
  end

  # Remove a value from the cache.
  # @param key [String] the key to remove
  def self.delete(key)
    Rails.cache.delete(key)
    nil
  end

  # Clear the entire cache.
  def self.clear
    Rails.cache.clear
  end

  # Hash a cache key.
  # @param string [String] the cache key to hash
  # @return [String] the hashed key
  def self.hash(string)
    Digest::SHA256.base64digest(string)
  end
end
