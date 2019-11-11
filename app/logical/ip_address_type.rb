class IpAddressType < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Inet
  def cast(value)
    super(IPAddress.parse(value))
  end

  def serialize(value)
    value.to_string
  end
end
