# frozen_string_literal: true

# Validates password strength using zxcvbn, a password strength estimator that
# recognizes dictionary words, keyboard patterns, dates, and other common
# weaknesses that simple length/complexity rules miss.
#
# @example
#   validates :password, zxcvbn_password: true
#   validates :password, zxcvbn_password: { min_score: 3 }
#
# @see https://github.com/envato/zxcvbn-ruby
# @see https://guides.rubyonrails.org/active_record_validations.html#custom-validators
class ZxcvbnPasswordValidator < ActiveModel::EachValidator
  DEFAULT_MIN_SCORE = 2

  def validate_each(rec, attr, password)
    return if password.blank?

    result = Zxcvbn.test(password)
    min_score = options[:min_score] || DEFAULT_MIN_SCORE
    return if result.score >= min_score

    rec.errors.add(attr, :weak_password, warning: result.feedback.warning.presence || "is too weak")
  end
end
