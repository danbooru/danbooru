# frozen_string_literal: true

# Define a custom validator for user names.
#
# @example
#   validates :name, user_name: true
#
# @see https://guides.rubyonrails.org/active_record_validations.html#custom-validators
class UserNameValidator < ActiveModel::EachValidator
  def validate_each(rec, attr, value)
    name = value

    rec.errors.add(attr, "already exists") if User.find_by_name(name).present?
    rec.errors.add(attr, "must be more than 1 character long") if name.length <= 1
    rec.errors.add(attr, "must be less than 25 characters long") if name.length >= 25
    rec.errors.add(attr, "cannot have whitespace or colons") if name =~ /[[:space:]]|:/
    rec.errors.add(attr, "cannot begin or end with an underscore") if name =~ /\A_|_\z/
    rec.errors.add(attr, "is not allowed") if name =~ Regexp.union(Danbooru.config.user_name_blacklist)
  end
end
