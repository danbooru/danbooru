# frozen_string_literal: true

class Uint128Type < ActiveRecord::Type::Value
  def cast_value(value)
    return if value.nil?
    case value
    in Integer
      value
    in String if value.match?(/\A(?:\h{8}-\h{4}-\h{4}-\h{4}-\h{12}|\h{1,32})\z/)
      value.remove("-").to_i(16)
    end
  end

  def serialize(value)
    return if value.nil?
    value.to_s(16).rjust(32, "0")
  end
end
