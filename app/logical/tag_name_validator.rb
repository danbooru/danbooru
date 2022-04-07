# frozen_string_literal: true

# Define a custom validator for tag names. Tags must be plain ASCII, no spaces,
# no redundant underscores, no conflicts with metatags, and can't begin with
# certain special characters.
#
# @example
#   validates :name, tag_name: true
#
# @see https://guides.rubyonrails.org/active_record_validations.html#custom-validators
class TagNameValidator < ActiveModel::EachValidator
  MAX_TAG_LENGTH = 170

  def validate_each(record, attribute, value)
    value = Tag.normalize_name(value)

    if value.size > MAX_TAG_LENGTH
      record.errors.add(attribute, "'#{value}' cannot be more than #{MAX_TAG_LENGTH} characters long")
    end

    if !value.in?(Tag::PERMITTED_UNBALANCED_TAGS) && !value.has_balanced_parens?
      record.errors.add(attribute, "'#{value}' cannot have unbalanced parentheses")
    end

    case value
    when /\A_*\z/
      record.errors.add(attribute, "cannot be blank")
    when /\*/
      record.errors.add(attribute, "'#{value}' cannot contain asterisks ('*')")
    when /,/
      record.errors.add(attribute, "'#{value}' cannot contain commas (',')")
    when /\A[-~_`%(){}\[\]\/]/
      record.errors.add(attribute, "'#{value}' cannot begin with a '#{value[0]}'")
    when /_\z/
      record.errors.add(attribute, "'#{value}' cannot end with an underscore")
    when /__/
      record.errors.add(attribute, "'#{value}' cannot contain consecutive underscores")
    when /[^[:graph:]]/
      record.errors.add(attribute, "'#{value}' cannot contain non-printable characters")
    when /[^[:ascii:]]/
      record.errors.add(attribute, "'#{value}' must consist of only ASCII characters")
    when /\A(#{PostQueryBuilder::METATAGS.join("|")}):(.+)\z/i
      record.errors.add(attribute, "'#{value}' cannot begin with '#{$1}:'")
    when /\A(#{Tag.categories.regexp}):(.+)\z/i
      record.errors.add(attribute, "'#{value}' cannot begin with '#{$1}:'")
    when "new", "search", "and", "or", "not"
      record.errors.add(attribute, "'#{value}' is a reserved name and cannot be used")
    when /\A(.+)_\(cosplay\)\z/i
      # XXX don't allow aliases here?
      tag_name = TagAlias.to_aliased([$1]).first
      tag = Tag.find_by_name(tag_name)

      if tag.present? && !tag.empty? && !tag.character?
        record.errors.add(attribute, "#{tag_name} must be a character tag")
      end
    end
  end
end
