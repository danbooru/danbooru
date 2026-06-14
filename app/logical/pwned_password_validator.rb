# frozen_string_literal: true

# Validates that a password has not appeared in known data breaches using the
# HaveIBeenPwned PwnedPasswords API.
#
# The API uses k-anonymity: only the first 5 characters of the SHA1 hash are
# sent, and the API returns all matching suffixes. The full hash never leaves
# the server.
#
# @example
#   validates :password, pwned_password: true
#
# @see https://haveibeenpwned.com/API/v3#PwnedPasswords
# @see https://guides.rubyonrails.org/active_record_validations.html#custom-validators
class PwnedPasswordValidator < ActiveModel::EachValidator
  API_URL = "https://api.pwnedpasswords.com/range/"

  def validate_each(rec, attr, password)
    return if password.blank?

    count = pwned_count(password)
    rec.errors.add(attr, :pwned_password, count: count) if count > 0
  rescue StandardError
    # If the API is unreachable, allow the password rather than blocking signups.
  end

  private

  def pwned_count(password)
    sha1 = Digest::SHA1.hexdigest(password).upcase
    prefix = sha1[0..4]
    suffix = sha1[5..]

    response = Danbooru::Http.external.timeout(5).cache(1.hour).get("#{API_URL}#{prefix}")
    return 0 unless response.status == 200

    response.to_s.each_line do |line|
      hash_suffix, count = line.strip.split(":")
      return count.to_i if hash_suffix == suffix
    end

    0
  end
end
