#!/usr/bin/env ruby

require_relative "base"

fix = ENV.fetch("FIX", "false").truthy?

ApiKey.where.not(permitted_ip_addresses: []).find_each do |api_key|
  api_key.normalize_attribute(:permitted_ip_addresses)
  next unless api_key.changed?

  puts({
    id: api_key.id,
    user_id: api_key.user_id,
    permitted_ip_addresses_was: api_key.permitted_ip_addresses_was,
    permitted_ip_addresses: api_key.permitted_ip_addresses,
  }.to_json)

  api_key.save! if fix
end
