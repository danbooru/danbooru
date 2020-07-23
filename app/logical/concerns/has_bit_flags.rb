module HasBitFlags
  extend ActiveSupport::Concern

  # NOTE: the ordering of attributes has to be fixed#
  # new attributes should be appended to the end.
  def has_bit_flags(attributes, field: :bit_flags)
    attributes.each.with_index do |attribute, i|
      bit_flag = 1 << i

      define_method(attribute) do
        send(field) & bit_flag > 0
      end

      define_method("#{attribute}?") do
        send(field) & bit_flag > 0
      end

      define_method("#{attribute}=") do |val|
        if val.to_s =~ /[t1y]/
          send("#{field}=", send(field) | bit_flag)
        else
          send("#{field}=", send(field) & ~bit_flag)
        end
      end
    end

    # bit_prefs_match
    define_singleton_method("#{field}_match") do |flag, value|
      value = value ? 1 : 0
      bits = attributes.length
      bit_index = bits - attributes.index(flag.to_s) - 1

      where(sanitize_sql(["get_bit(#{field}::bit(?), ?) = ?", bits, bit_index, value]))
    end
  end
end
