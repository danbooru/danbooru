class ByteStringType < ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Bytea
  def deserialize(value)
    super value.unpack("H*").first
  end
end
