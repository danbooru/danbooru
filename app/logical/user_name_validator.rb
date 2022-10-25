# frozen_string_literal: true

# Define a custom validator for user names.
#
# @example
#   validates :name, user_name: true
#
# @see https://guides.rubyonrails.org/active_record_validations.html#custom-validators
class UserNameValidator < ActiveModel::EachValidator
  ALLOWED_PUNCTUATION = "_.-" # All other punctuation characters are forbidden

  def validate_each(rec, attr, name)
    forbidden_characters = name.delete(ALLOWED_PUNCTUATION).chars.grep(/[[:punct:]]/).uniq

    if rec.new_record? && User.find_by_name(name).present?
      rec.errors.add(attr, "already exists")
    elsif name.length <= 1
      rec.errors.add(attr, "must be more than 1 character long")
    elsif name.length >= 25
      rec.errors.add(attr, "must be less than 25 characters long")
    elsif name =~ /[[:space:]]/
      rec.errors.add(attr, "can't contain whitespace")
    elsif name =~ /\A[[:punct:]]/
      rec.errors.add(attr, "can't start with '#{name.first}'")
    elsif name =~ /[[:punct:]]\z/
      rec.errors.add(attr, "can't end with '#{name.last}'")
    elsif name =~ /\.(html|json|xml|atom|rss|txt|js|css|csv|png|jpg|jpeg|gif|png|avif|webp|mp4|webm|zip|pdf|exe|sitemap)\z/i
      rec.errors.add(attr, "can't end with a file extension")
    elsif name =~ /__/
      rec.errors.add(attr, "can't contain multiple underscores in a row")
    elsif forbidden_characters.present?
      rec.errors.add(attr, "can't contain #{forbidden_characters.map { |c| "'#{c}'" }.to_sentence}")
    elsif name !~ /\A([a-zA-Z0-9]|\p{Han}|\p{Hangul}|\p{Hiragana}|\p{Katakana}|[#{ALLOWED_PUNCTUATION}])+\z/
      rec.errors.add(attr, "must contain only basic letters or numbers")
    elsif name =~ /\Auser_\d+\z/i
      rec.errors.add(attr, "can't be the same as a deleted user")
    elsif name =~ Regexp.union(Danbooru.config.user_name_blacklist)
      rec.errors.add(attr, "is not allowed")
    end
  end
end
