#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

kv = KeyValue.find_or_create_by_key("ApiCacheGenerator.generate_tag_cache")
kv.update_attribute(:value, "0")
