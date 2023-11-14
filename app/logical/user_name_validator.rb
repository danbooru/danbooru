# frozen_string_literal: true

# Define a custom validator for user names.
#
# @example
#   validates :name, user_name: true
#
# @see https://guides.rubyonrails.org/active_record_validations.html#custom-validators
class UserNameValidator < ActiveModel::EachValidator
  MIN_LENGTH = 1
  MAX_LENGTH = 24
  ALLOWED_PUNCTUATION = "_.-" # All other punctuation characters are forbidden

  RESERVED_NAMES = [
    "any", "none", # conflicts with `approver:any` search syntax
    "new", "deactivate", "custom_style", # conflicts with user routes (/users/new, /users/deactivate, /users/custom_style)
    "mod", "administrator", # mod impersonation
    *User::Roles.map(&:to_s) # owner, admin, moderator, anonymous, banned, etc
  ]

  def validate_each(rec, attr, name)
    forbidden_characters = name.delete(ALLOWED_PUNCTUATION).chars.grep(/[[:punct:]]/).uniq
    current_user = rec.is_a?(UserNameChangeRequest) ? rec.user : rec

    if !options[:skip_uniqueness] && User.without(current_user).find_by_name(name).present?
      rec.errors.add(attr, "already taken")
    elsif name.length <= MIN_LENGTH
      rec.errors.add(attr, "must be more than #{MIN_LENGTH} character long")
    elsif name.length > MAX_LENGTH
      rec.errors.add(attr, "must be less than #{MAX_LENGTH + 1} characters long")
    # \p{di} = default ignorable codepoints. Filters out Hangul filler characters (U+115F, U+1160, U+3164, U+FFA0)
    elsif name =~ /[[:space:]\p{di}]/
      rec.errors.add(attr, "can't contain whitespace")
    elsif name =~ /\A[[:punct:]]/
      rec.errors.add(attr, "can't start with '#{name.first}'")
    elsif name =~ /[[:punct:]]\z/
      rec.errors.add(attr, "can't end with '#{name.last}'")
    elsif name =~ /\.(#{Mime::EXTENSION_LOOKUP.keys.join("|")})\z/i
      rec.errors.add(attr, "can't end with a file extension")
    elsif name =~ /__/
      rec.errors.add(attr, "can't contain multiple underscores in a row")
    elsif forbidden_characters.present?
      rec.errors.add(attr, "can't contain #{forbidden_characters.map { |c| "'#{c}'" }.to_sentence}")
    elsif name !~ /\A([a-zA-Z0-9]|\p{Han}|\p{Hangul}|\p{Hiragana}|\p{Katakana}|[#{ALLOWED_PUNCTUATION}])+\z/
      rec.errors.add(attr, "must contain only basic letters or numbers")
    elsif name =~ /\Auser_\d+\z/i
      rec.errors.add(attr, "can't be the same as a deleted user")
    elsif name.downcase.in?(RESERVED_NAMES)
      rec.errors.add(attr, "is a reserved name and can't be used")
    elsif name =~ Regexp.union(Danbooru.config.user_name_blacklist)
      rec.errors.add(attr, "is not allowed")
    end
  end
end
