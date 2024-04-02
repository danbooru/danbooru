# frozen_string_literal: true

# A custom validator for ensuring a string isn't blank. Like the `presence` validator, but checks for certain invisible
# Unicode characters such as zero-width spaces too.
#
# @example
#   validates :body, visible_string: true
#
# @see https://invisible-characters.com/
# @see https://guides.rubyonrails.org/active_record_validations.html#presence
# @see https://guides.rubyonrails.org/active_record_validations.html#custom-validators
class VisibleStringValidator < ActiveModel::EachValidator
  def validate_each(record, attr, string)
    return if options[:allow_empty] && string.to_s.empty?

    if string.nil? || string.invisible?
      record.errors.add(attr, "can't be blank")
    end
  end
end
