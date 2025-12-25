# frozen_string_literal: true

# A utility class that represents an email address. A wrapper around Mail::Address
# that adds extra methods for validating email addresses, correcting addresses
# containing typos, and canonicalizing multiple forms of the same address.
#
# @see https://www.rubydoc.info/gems/mail/Mail/Address
# @see app/logical/email_address_type.rb
# @see config/initializers/types.rb
module Danbooru
  class EmailAddress
    class Error < StandardError; end

    # https://www.regular-expressions.info/email.html
    EMAIL_REGEX = /^[a-zA-Z0-9._+-]*[a-zA-Z0-9_+-]@([a-zA-Z0-9][a-zA-Z0-9-]{0,61}\.)+[a-zA-Z]{2,}$/

    # Sites that ignore dots in email addresses, e.g. where `foo.bar@gmail.com` is the same as `foobar@gmail.com`.
    IGNORE_DOTS = %w[gmail.com]

    # Sites that allow plus addressing, e.g. `test+nospam@gmail.com`.
    # @see https://en.wikipedia.org/wiki/Email_address#Subaddressing
    PLUS_ADDRESSING = %w[gmail.com hotmail.com outlook.com live.com]
    MINUS_ADDRESSING = %w[yahoo.com]

    # Sites that have multiple domains mapping to the same logical email address.
    CANONICAL_DOMAINS = {
      "googlemail.com" => "gmail.com",
      "hotmail.com.ar" => "outlook.com",
      "hotmail.com.au" => "outlook.com",
      "hotmail.com.br" => "outlook.com",
      "hotmail.com.hk" => "outlook.com",
      "hotmail.com.tw" => "outlook.com",
      "hotmail.co.jp" => "outlook.com",
      "hotmail.co.nz" => "outlook.com",
      "hotmail.co.th" => "outlook.com",
      "hotmail.co.uk" => "outlook.com",
      "hotmail.com" => "outlook.com",
      "hotmail.be" => "outlook.com",
      "hotmail.ca" => "outlook.com",
      "hotmail.cl" => "outlook.com",
      "hotmail.de" => "outlook.com",
      "hotmail.dk" => "outlook.com",
      "hotmail.es" => "outlook.com",
      "hotmail.fi" => "outlook.com",
      "hotmail.fr" => "outlook.com",
      "hotmail.hu" => "outlook.com",
      "hotmail.it" => "outlook.com",
      "hotmail.my" => "outlook.com",
      "hotmail.nl" => "outlook.com",
      "hotmail.no" => "outlook.com",
      "hotmail.ru" => "outlook.com",
      "hotmail.sg" => "outlook.com",
      "hotmail.se" => "outlook.com",
      "live.com.au" => "outlook.com",
      "live.com.ar" => "outlook.com",
      "live.com.mx" => "outlook.com",
      "live.com.pt" => "outlook.com",
      "live.co.uk" => "outlook.com",
      "live.com" => "outlook.com",
      "live.at" => "outlook.com",
      "live.be" => "outlook.com",
      "live.ca" => "outlook.com",
      "live.cl" => "outlook.com",
      "live.cn" => "outlook.com",
      "live.de" => "outlook.com",
      "live.dk" => "outlook.com",
      "live.fr" => "outlook.com",
      "live.hk" => "outlook.com",
      "live.ie" => "outlook.com",
      "live.it" => "outlook.com",
      "live.jp" => "outlook.com",
      "live.nl" => "outlook.com",
      "live.no" => "outlook.com",
      "live.ru" => "outlook.com",
      "live.se" => "outlook.com",
      "msn.com" => "outlook.com",
      "outlook.com.ar" => "outlook.com",
      "outlook.com.au" => "outlook.com",
      "outlook.com.br" => "outlook.com",
      "outlook.co.id" => "outlook.com",
      "outlook.co.uk" => "outlook.com",
      "outlook.co.jp" => "outlook.com",
      "outlook.co.nz" => "outlook.com",
      "outlook.co.th" => "outlook.com",
      "outlook.at" => "outlook.com",
      "outlook.be" => "outlook.com",
      "outlook.ca" => "outlook.com",
      "outlook.cl" => "outlook.com",
      "outlook.cn" => "outlook.com",
      "outlook.de" => "outlook.com",
      "outlook.dk" => "outlook.com",
      "outlook.es" => "outlook.com",
      "outlook.fr" => "outlook.com",
      "outlook.ie" => "outlook.com",
      "outlook.it" => "outlook.com",
      "outlook.kr" => "outlook.com",
      "outlook.jp" => "outlook.com",
      "outlook.nl" => "outlook.com",
      "outlook.pt" => "outlook.com",
      "outlook.ru" => "outlook.com",
      "outlook.sa" => "outlook.com",
      "outlook.se" => "outlook.com",
      "yahoo.com.au" => "yahoo.com",
      "yahoo.com.ar" => "yahoo.com",
      "yahoo.com.br" => "yahoo.com",
      "yahoo.com.cn" => "yahoo.com",
      "yahoo.com.hk" => "yahoo.com",
      "yahoo.com.mx" => "yahoo.com",
      "yahoo.com.my" => "yahoo.com",
      "yahoo.com.ph" => "yahoo.com",
      "yahoo.com.sg" => "yahoo.com",
      "yahoo.com.tw" => "yahoo.com",
      "yahoo.com.vn" => "yahoo.com",
      "yahoo.co.id" => "yahoo.com",
      "yahoo.co.kr" => "yahoo.com",
      "yahoo.co.jp" => "yahoo.com",
      "yahoo.co.nz" => "yahoo.com",
      "yahoo.co.uk" => "yahoo.com",
      "yahoo.co.th" => "yahoo.com",
      "yahoo.ne.jp" => "yahoo.com",
      "yahoo.ca" => "yahoo.com",
      "yahoo.cn" => "yahoo.com",
      "yahoo.de" => "yahoo.com",
      "yahoo.dk" => "yahoo.com",
      "yahoo.es" => "yahoo.com",
      "yahoo.fr" => "yahoo.com",
      "yahoo.ie" => "yahoo.com",
      "yahoo.in" => "yahoo.com",
      "yahoo.it" => "yahoo.com",
      "yahoo.no" => "yahoo.com",
      "yahoo.se" => "yahoo.com",
      "ymail.com" => "yahoo.com",
      "126.com" => "163.com",
      "aim.com" => "aol.com",
      "gmx.com" => "gmx.net",
      "gmx.at" => "gmx.net",
      "gmx.ch" => "gmx.net",
      "gmx.de" => "gmx.net",
      "gmx.fr" => "gmx.net",
      "gmx.us" => "gmx.net",
      "pm.me" => "protonmail.com",
      "protonmail.ch" => "protonmail.com",
      "proton.me"   => "protonmail.com",
      "tuta.io"     => "tutanota.com",
      "email.com"   => "mail.com",
      "me.com"      => "icloud.com",
      "ya.ru"       => "yandex.ru",
      "yandex.com"  => "yandex.ru",
      "yandex.by"   => "yandex.ru",
      "yandex.ua"   => "yandex.ru",
      "yandex.kz"   => "yandex.ru",
      "inbox.ru"    => "mail.ru",
      "bk.ru"       => "mail.ru",
      "list.ru"     => "mail.ru",
      "internet.ru" => "mail.ru",
      "hanmail.net" => "daum.net",
    }

    # A list of domains known not to be disposable.
    #
    # @see https://www.mailboxvalidator.com/domain
    NONDISPOSABLE_DOMAINS = %w[
      gmail.com
      outlook.com
      yahoo.com
      aol.com
      comcast.net
      att.net
      bellsouth.net
      cox.net
      sbcglobal.net
      verizon.net
      icloud.com
      rocketmail.com
      windowslive.com
      qq.com
      vip.qq.com
      sina.com
      naver.com
      163.com
      daum.net
      mail.goo.ne.jp
      nate.com
      mail.com
      protonmail.com
      gmx.net
      web.de
      freenet.de
      o2.pl
      op.pl
      wp.pl
      interia.pl
      mail.ru
      yandex.ru
      rambler.ru
      abv.bg
      seznam.cz
      libero.it
      laposte.net
      free.fr
      orange.fr
      citromail.hu
      ukr.net
      t-online.de
      inbox.lv
      luukku.com
      lycos.com
      tlen.pl
      infoseek.jp
      excite.co.jp
      mac.com
      wanadoo.fr
      ezweb.ne.jp
      arcor.de
      docomo.ne.jp
      earthlink.net
      charter.net
      hushmail.com
      inbox.com
      juno.com
      shaw.ca
      walla.com
      tutanota.com
      foxmail.com
      vivaldi.net
      fastmail.com
      relay.firefox.com
    ]

    # @return [String] The original email address as a string.
    attr_reader :address

    # @return [Mail::Address] The parsed email address.
    attr_reader :parsed_address

    delegate :local, :domain, to: :parsed_address
    alias_method :name, :local
    alias_method :to_s, :address

    # Parse a string into an email address, or raise an exception if the string is not a syntactically valid address.
    #
    # @param string [String, Danbooru::EmailAddress]
    def initialize(string)
      raise Error, "#{string} is not a valid email address" if !self.class.is_valid?(string)

      @address = string.to_s
      @parsed_address = Mail::Address.new(address)
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
    # nil if the string can't be corrected into a valid email address.
    #
    # @param address [String]
    # @return [Danbooru::EmailAddress]
    def self.correct(address)
      address = address.gsub(/[[:space:]]+/, " ").strip

      address = address.gsub(/[\\\/]$/, '') # @qq.com\ -> @qq.com, @web.de/ -> @web.de
      #address = address.gsub(/,/, ".") # foo,bar@gmail.com -> foo.bar@gmail.com | @gmail,com -> @gmail.com
      address = address.gsub(/^https?:\/\/(www\.)?/i, "") # https://xxx@gmail.com -> xxx@gmail.com
      address = address.gsub(/^mailto:/i, "") # mailto:foo@gmail.com -> foo@gmail.com
      address = address.gsub(/.* <(.*)>$/, '\1') # foo <bar@gmail.com> -> bar@gmail.com
      address = address.gsub(/@\./, "@") # @.gmail.com -> @gmail.com
      address = address.gsub(/\.+@/, "@") # foo..@gmail.com -> foo@gmail.com
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
      address = address.gsub(/@gm.il\.com$/i, "@gmail.com") # @gmsil.com -> @gmail.com
      address = address.gsub(/@gma.l\.com$/i, "@gmail.com") # @gmaul.com -> @gmail.com
      address = address.gsub(/@gma.il\.com$/i, "@gmail.com") # @gmaail.com -> @gmail.com
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

    # @param address [String, Danbooru::EmailAddress] The address to canonicalize.
    # @return [Danbooru::EmailAddress, nil] The email address converted to canonical form, e.g. "Foo.Bar+nospam@googlemail.com" => "foobar@gmail.com".
    def self.canonicalize(address)
      parse(address.to_s)&.canonicalized_address
    end

    # Returns true if the string is a syntactically valid email address.
    #
    # @param address [String] The email address.
    # @return [Boolean] True if the email address is syntactically valid.
    def self.is_valid?(address)
      address.to_s.match?(EMAIL_REGEX)
    end

    concerning :DeliverableMethods do
      # Returns true if the email address can't receive mail. Checks that the domain exists, that it has a valid MX record,
      # that the mail server exists, and that it responds successfully to the RCPT TO command for the given address.
      #
      # @param from_address [String] The from address to use when connecting to the mail server.
      # @param timeout [Integer] The network timeout when connecting to the mail server.
      # @return [Boolean] True if the email address is definitely undeliverable. False if the address is eligible for delivery. Delivery could
      #   still fail if the mailbox doesn't exist and the server lied to the RCPT TO command.
      def undeliverable?(from_address: Danbooru.config.contact_email, timeout: 3)
        mail_server = mx_domain(timeout: timeout)
        return true if mail_server.blank?

        return false if !smtp_enabled?
        smtp = Net::SMTP.new(mail_server)
        smtp.read_timeout = timeout
        smtp.open_timeout = timeout

        from_domain = Danbooru::EmailAddress.new(from_address).domain.to_s
        smtp.start(from_domain) do |conn|
          conn.mailfrom(from_address)

          # Net::SMTPFatalError is raised if RCPT TO returns a 5xx error.
          response = conn.rcptto(address) rescue $!
          return response.is_a?(Net::SMTPFatalError)
        end
      rescue Errno::ECONNREFUSED
        # nobody@yeah.com (MX: 0.0.0.0)
        true
      rescue
        false
      end

      # Perform a DNS MX record lookup of the domain and return the name of the mail server, if it exists.
      #
      # @param timeout [Integer] The network timeout when resolving the domain.
      # @return [String] The DNS name of the mail server.
      def mx_domain(timeout: nil)
        dns = Resolv::DNS.new
        dns.timeouts = timeout
        response = dns.getresource(domain.to_s, Resolv::DNS::Resource::IN::MX)

        response.exchange.to_s
      rescue Resolv::ResolvError
        nil
      end

      # True if we're allowed to make SMTP connections. Most residential ISP and VPS providers block SMTP connections by
      # default, so we only consider SMTP enabled if an email provider has been explicitly configured.
      def smtp_enabled?
        Rails.application.config.action_mailer.smtp_settings.present?
      end
    end

    # Returns true if the email address is not a disposable or throwaway address (it comes from a well-known email provider).
    # Returns false if the address is potentially disposable (it comes from an unknown email provider, or a personal domain).
    def is_nondisposable?
      domain.to_s.in?(NONDISPOSABLE_DOMAINS)
    end

    # @return [Danbooru::EmailAddress] The email address with typos corrected, e.g. "foo@gamil.com" => "foo@gmail.com".
    def corrected_address
      Danbooru::EmailAddress.correct(address)
    end

    # @return [Danbooru::EmailAddress] The email address converted into canonical form, e.g. "Foo.Bar+nospam@googlemail.com" => "foobar@gmail.com".
    def canonicalized_address
      Danbooru::EmailAddress.new("#{canonical_name}@#{canonical_domain}")
    end

    # @return [String] The name with the subaddress and periods removed, e.g. "Foo.Bar+nospam@gmail.com" => "foobar".
    def canonical_name
      name = name_and_subaddress.first
      name = name.delete(".") if canonical_domain.in?(IGNORE_DOTS)
      name.downcase
    end

    # @return [String, nil] The part of the name after the `+` or `-`, e.g. "foo+nospam@gmail.com" => "nospam".
    def subaddress
      name_and_subaddress.second
    end

    # @return [Array<String, String>] The address split into the name and the subaddress, e.g. "foo+nospam@gmail.com" => ["foo", "nospam"]
    def name_and_subaddress
      if canonical_domain.in?(PLUS_ADDRESSING)
        name.split("+")
      elsif canonical_domain.in?(MINUS_ADDRESSING)
        name.split("-")
      else
        [name, nil]
      end
    end

    # @return [String] The primary domain for the site, if the site has multiple domains, e.g. "googlemail.com" => "gmail.com".
    def canonical_domain
      @canonical_domain ||= CANONICAL_DOMAINS.fetch(domain.to_s.downcase, domain.to_s.downcase)
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
