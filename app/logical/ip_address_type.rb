# frozen_string_literal: true

# Ensure ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Inet is loaded in
# the dev environment when eager loading is disabled.
require "active_record/connection_adapters/postgresql_adapter"

# Define a custom IP address type for IP columns in the database. IP columns
# will be serialized and deserialized as a {Danbooru::IpAddress} object.
#
# @see config/initializers/types.rb
# @see https://www.bigbinary.com/blog/rails-5-attributes-api
# @see https://api.rubyonrails.org/classes/ActiveModel/Type/Value.html
class IpAddressType < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Inet
  # Cast a String (or nil) value from the database to a Danbooru::IpAddress object.
  #
  # @param value [String] the IP address from the database
  # @return [Danbooru::IpAddress]
  def cast(value)
    return nil if value.blank?
    super(Danbooru::IpAddress.new(value))
  rescue ArgumentError
    nil
  end

  # Serialize a Danbooru::IpAddress to a String for the database.
  # XXX May be passed a string in some situations?
  #
  # @param value [Danbooru::IpAddress] the IP address object
  # @return [String]
  def serialize(value)
    return value.to_string if value.is_a?(Danbooru::IpAddress)
    super value
  end
end
