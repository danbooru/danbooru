# frozen_string_literal: true

# Define a custom type for storing MD5 hashes as UUID columns in the database. This is more efficient than storing
# hashes as strings, but we have to strip the dashes from the UUIDs returned by the database.
#
# @see config/initializers/types.rb
# @see https://api.rubyonrails.org/classes/ActiveModel/Type/Value.html
class Md5HashType < ActiveRecord::Type::Value
  # Convert a value from the database to a Ruby object. Strips dashes from the UUID.
  def cast_value(value)
    value.to_s.remove("-")
  end

  # Convert a Ruby object to a value for the database. Returns nil if it's not a valid hash so that SQL queries
  # don't fail with a syntax error if the hash is invalid.
  def serialize(value)
    value if value.to_s.match?(/\A[a-zA-Z0-9]{32}\z/)
  end
end
