# frozen_string_literal: true

# Define a custom email address type that allows models to declare attributes of type Danbooru::EmailAddress.
#
# @see app/logical/danbooru/email_address.rb
# @see config/initializers/types.rb
# @see https://www.bigbinary.com/blog/rails-5-attributes-api
# @see https://api.rubyonrails.org/classes/ActiveModel/Type/Value.html
class EmailAddressType < ActiveRecord::Type::Value
  # Cast a String (or nil) value from the database to a Danbooru::EmailAddress object.
  #
  # @param value [String] the email address from the database
  # @return [Danbooru::EmailAddress]
  def cast(value)
    return nil if value.blank?
    super(Danbooru::EmailAddress.new(value))
  rescue Danbooru::EmailAddress::Error
    nil
  end

  # Serialize a Danbooru::EmailAddress to a String for the database.
  #
  # @param value [Danbooru::EmailAddress] the email address object
  # @return [String]
  def serialize(value)
    return value.to_s if value.is_a?(Danbooru::EmailAddress)
    super value
  end
end
