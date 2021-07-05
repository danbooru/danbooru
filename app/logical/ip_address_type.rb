# Ensure ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Inet is loaded in
# the dev environment when eager loading is disabled.
require "active_record/connection_adapters/postgresql_adapter"

# Define a custom IP address type for IP columns in the database. IP columns
# will be serialized and deserialized as a {Danbooru::IpAddress} object.
#
# @see config/initializers/types.rb
# @see https://www.bigbinary.com/blog/rails-5-attributes-api
class IpAddressType < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Inet
  # @param value [String] the IP address from the database
  def cast(value)
    return nil if value.blank?
    super(Danbooru::IpAddress.new(value))
  end

  # @param [Danbooru::IpAddress] the IP address object
  def serialize(value)
    value&.to_string
  end
end
