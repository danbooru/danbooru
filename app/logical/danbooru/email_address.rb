# frozen_string_literal: true

# A utility class that represents an email address. A wrapper around Mail::Address
# that adds extra utility methods for normalizing and validating email addresses.
#
# @see https://www.rubydoc.info/gems/mail/Mail/Address
# @see app/logical/email_address_type.rb
# @see config/initializers/types.rb
module Danbooru
  class EmailAddress
    class Error < StandardError; end

    # https://www.regular-expressions.info/email.html
    EMAIL_REGEX = /\A[a-z0-9._%+-]+@(?:[a-z0-9][a-z0-9-]{0,61}\.)+[a-z]{2,}\z/i

    # @return [String] The original email address as a string.
    attr_reader :address

    # @return [Mail::Address] The parsed email address.
    attr_reader :parsed_address

    delegate :local, to: :parsed_address
    alias_method :name, :local
    alias_method :to_s, :address

    # Parse a string into an email address, or raise an exception if the string is not a syntactically valid address.
    #
    # @param string [String, Danbooru::EmailAddress]
    def initialize(string)
      raise Error, "#{string} is not a valid email address" if !string.match?(EMAIL_REGEX)

      @address = string.to_s
      @parsed_address = Mail::Address.new(parsed_address)
    end

    # Parse a string into an email address, or return nil if the string is not a syntactically valid email address.
    #
    # @param url [String, Danbooru::EmailAddress]
    # @return [Danbooru::EmailAddress]
    def self.parse(address)
      new(address)
    rescue Error
      nil
    end

    # Parse a string into an email address while attempting to fix common typos and mistakes, or return
    # nil if the string can't be normalized into a valid email address.
    #
    # @param address [String]
    # @return [Danbooru::EmailAddress]
    def self.normalize(address)
      address = address.gsub(/[[:space:]]+/, " ").strip

      address = address.gsub(/[\\\/]$/, '') # @qq.com\ -> @qq.com, @web.de/ -> @web.de
      #address = address.gsub(/,/, ".") # foo,bar@gmail.com -> foo.bar@gmail.com | @gmail,com -> @gmail.com
      address = address.gsub(/^https?:\/\/(www\.)?/i, "") # https://xxx@gmail.com -> xxx@gmail.com
      address = address.gsub(/^mailto:/i, "") # mailto:foo@gmail.com -> foo@gmail.com
      address = address.gsub(/.* <(.*)>$/, '\1') # foo <bar@gmail.com> -> bar@gmail.com
      address = address.gsub(/@\./, "@") # @.gmail.com -> @gmail.com
      address = address.gsub(/@com$/i, ".com") # @gmail@com -> @gmail.com
      address = address.gsub(/\.co,$/i, '.com') # @gmail.co, -> @gmail.com
      address = address.gsub(/\.com.$/i, '.com') # @gmail.com, -> @gmail.com
      address = address.gsub(/\.con$/i, '.com') # @gmail.con -> @gmail.com
      address = address.gsub(/\.\.com$/i, '.com') # @gmail..com -> @gmail.com

      # @gmail -> @gmail.com
      address = address.gsub(/@gmai$/i, "@gmail.com")
      address = address.gsub(/@gmail$/i, "@gmail.com")
      address = address.gsub(/@yahoo$/i, "@yahoo.com")
      address = address.gsub(/@hotmai$/i, "@hotmail.com")
      address = address.gsub(/@hotmail$/i, "@hotmail.com")
      address = address.gsub(/@hot[^m]ail$/i, "@hotmail.com")
      address = address.gsub(/@live$/i, "@live.com")

      address = address.gsub(/@.gmail\.com$/i, "@gmail.com") # @-gmail.com -> @gmail.com
      address = address.gsub(/@g.ail\.com$/i, "@gmail.com") # @g,ail.com -> @gmail.com
      address = address.gsub(/@gmail\.co.$/i, "@gmail.com") # @gmail.co, -> @gmail.com
      address = address.gsub(/@gamil\.com$/i, "@gmail.com") # @gamil.com -> @gmail.com
      address = address.gsub(/@gnail\.com$/i, "@gmail.com") # @gnail.com -> @gmail.com
      address = address.gsub(/@gmail\.co$/i, "@gmail.com") # @gmail.co -> @gmail.com
      address = address.gsub(/@gmai.\.com$/i, "@gmail.com") # @gmai;.com -> @gmail.com
      address = address.gsub(/@gmai\.com$/i, "@gmail.com") # @gmai.com -> @gmail.com
      address = address.gsub(/@gmai\.co$/i, "@gmail.com") # @gmai.co -> @gmail.com
      address = address.gsub(/@hotmai\.com$/i, "@hotmail.com") # @hotmai.com -> @hotmail.com
      address = address.gsub(/@hot.ail\.com$/i, "@hotmail.com") # @hot.ail.com -> @hotmail.com
      address = address.gsub(/@hot.mail\.com$/i, "@hotmail.com") # @hot,mail.com -> @hotmail.com
      address = address.gsub(/@hanm.ail\.net$/i, "@hanmail.net") # @hanmiail.net -> @hanmail.net

      address = address.gsub(/@(gmail|yahoo|hotmail|outlook|live).com$/i, '@\1.com') # @gmail,com -> @gmail.com
      address = address.gsub(/@(gmail|yahoo|hotmail|outlook|live)com$/i, '@\1.com') # @gmailcom -> @gmail.com

      address = address.gsub(/@([a-z]+)\.com@\1\.com$/i, '@\1.com') # @gmail.com@gmail.com -> @gmail.com
      address = address.gsub(/@([a-z]+)@\1\.com$/i, '@\1.com') # @gmail@gmail.com -> @gmail.com

      address = address.gsub(/(@.*)$/) { $1.downcase } # @Gmail.com -> @gmail.com

      parse(address)
    end

    # @return [Danbooru::EmailAddress] The email address, normalized to fix typos.
    def normalized_address
      Danbooru::EmailAddress.normalize(address)
    end

    # @return [PublicSuffix::Domain] The domain part of the email address.
    def domain
      @domain ||= PublicSuffix.parse(parsed_address.domain)
    rescue PublicSuffix::DomainNotAllowed
      nil
    end

    def as_json
      to_s
    end

    def inspect
      "#<Danbooru::EmailAddress #{to_s}>"
    end

    def ==(other)
      self.class == other.class && to_s == other.to_s
    end

    def hash
      to_s.hash
    end

    alias_method :eql?, :==
  end
end
