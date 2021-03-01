# See also config/initializers/types.rb

require "active_record/connection_adapters/postgresql_adapter"

class IpAddressType < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Inet
  def cast(value)
    return nil if value.blank?
    super(Danbooru::IpAddress.new(value))
  end

  def serialize(value)
    value&.to_string
  end
end
