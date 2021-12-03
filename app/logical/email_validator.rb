require 'resolv'

# Validates that an email address is well-formed, is deliverable, and is not a
# disposable or throwaway email address. Also normalizes equivalent addresses to
# a single canonical form, so that users can't use different forms of the same
# address to register multiple accounts.
module EmailValidator
  module_function

  # https://www.regular-expressions.info/email.html
  EMAIL_REGEX = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/

  # Sites that ignore dots in email addresses, e.g. where `te.st@gmail.com` is
  # the same as `test@gmail.com`.
  IGNORE_DOTS = %w[gmail.com]

  # Sites that allow plus addressing, e.g. `test+nospam@gmail.com`.
  # @see https://en.wikipedia.org/wiki/Email_address#Subaddressing
  IGNORE_PLUS_ADDRESSING = %w[gmail.com hotmail.com outlook.com live.com]
  IGNORE_MINUS_ADDRESSING = %w[yahoo.com]

  # Sites that have multiple domains mapping to the same logical email address.
  CANONICAL_DOMAINS = {
    "googlemail.com" => "gmail.com",
    "hotmail.com.ar" => "outlook.com",
    "hotmail.com.br" => "outlook.com",
    "hotmail.com.hk" => "outlook.com",
    "hotmail.com.tw" => "outlook.com",
    "hotmail.co.uk" => "outlook.com",
    "hotmail.co.jp" => "outlook.com",
    "hotmail.co.th" => "outlook.com",
    "hotmail.com" => "outlook.com",
    "hotmail.be" => "outlook.com",
    "hotmail.ca" => "outlook.com",
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
    "hotmail.se" => "outlook.com",
    "live.com.au" => "outlook.com",
    "live.com.ar" => "outlook.com",
    "live.com.mx" => "outlook.com",
    "live.com.pt" => "outlook.com",
    "live.co.uk" => "outlook.com",
    "live.com" => "outlook.com",
    "live.at" => "outlook.com",
    "live.ca" => "outlook.com",
    "live.cl" => "outlook.com",
    "live.cn" => "outlook.com",
    "live.de" => "outlook.com",
    "live.dk" => "outlook.com",
    "live.fr" => "outlook.com",
    "live.it" => "outlook.com",
    "live.jp" => "outlook.com",
    "live.nl" => "outlook.com",
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
    "yahoo.com.ph" => "yahoo.com",
    "yahoo.com.sg" => "yahoo.com",
    "yahoo.com.tw" => "yahoo.com",
    "yahoo.com.vn" => "yahoo.com",
    "yahoo.co.id" => "yahoo.com",
    "yahoo.co.kr" => "yahoo.com",
    "yahoo.co.jp" => "yahoo.com",
    "yahoo.co.nz" => "yahoo.com",
    "yahoo.co.uk" => "yahoo.com",
    "yahoo.ne.jp" => "yahoo.com",
    "yahoo.ca" => "yahoo.com",
    "yahoo.cn" => "yahoo.com",
    "yahoo.de" => "yahoo.com",
    "yahoo.es" => "yahoo.com",
    "yahoo.fr" => "yahoo.com",
    "yahoo.it" => "yahoo.com",
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

  # A list of domains known not to be disposable. A user's email must be on
  # this list to unrestrict their account. If a user is Restricted and their
  # email is not in this list, then it's assumed to be disposable and can't be
  # used to unrestrict their account even if they verify their email address.
  #
  # https://www.mailboxvalidator.com/domain
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

  # Returns true if it's okay to connect to port 25. Disabled outside of
  # production because many home ISPs blackhole port 25.
  def smtp_enabled?
    Rails.env.production?
  end

  # Normalize an email address by stripping out plus addressing and dots, if
  # applicable, and rewriting the domain to a canonical domain.
  # @param address [String] the email address to normalize
  # @return [String] the normalized address
  def normalize(address)
    return nil unless address.count("@") == 1

    name, domain = address.downcase.split("@")

    domain = CANONICAL_DOMAINS.fetch(domain, domain)
    name = name.delete(".") if domain.in?(IGNORE_DOTS)
    name = name.gsub(/\+.*\z/, "") if domain.in?(IGNORE_PLUS_ADDRESSING)
    name = name.gsub(/-.*\z/, "") if domain.in?(IGNORE_MINUS_ADDRESSING)

    "#{name}@#{domain}"
  end

  # Returns true if the email address is correctly formatted.
  # @param [String] the email address
  # @return [Boolean]
  def is_valid?(address)
    address.match?(EMAIL_REGEX)
  end

  # Returns true if the email is a throwaway or disposable email address.
  # @param [String] the email address
  # @return [Boolean]
  def is_restricted?(address)
    domain = Mail::Address.new(address).domain
    !domain.in?(NONDISPOSABLE_DOMAINS)
  rescue Mail::Field::IncompleteParseError
    true
  end

  # Returns true if the email can't be delivered. Checks if the domain has an MX
  # record and responds to the RCPT TO command.
  # @param to_address [String] the email address to check
  # @param from_address [String] the email address to check from
  # @return [Boolean]
  def undeliverable?(to_address, from_address: Danbooru.config.contact_email, timeout: 3)
    mail_server = mx_domain(to_address, timeout: timeout)
    mail_server.nil? || rcpt_to_failed?(to_address, from_address, mail_server, timeout: timeout)
  rescue
    false
  end

  # Returns true if the email can't be delivered. Sends a RCPT TO command over
  # port 25 to check if the mailbox exists.
  # @param to_address [String] the email address to check
  # @param from_address [String] the email address to check from
  # @param mail_server [String] the DNS name of the SMTP server
  # @param timeout [Integer] the network timeout
  # @return [Boolean]
  def rcpt_to_failed?(to_address, from_address, mail_server, timeout: nil)
    return false unless smtp_enabled?

    from_domain = Mail::Address.new(from_address).domain

    smtp = Net::SMTP.new(mail_server)
    smtp.read_timeout = timeout
    smtp.open_timeout = timeout

    smtp.start(from_domain) do |conn|
      conn.mailfrom(from_address)

      # Net::SMTPFatalError is raised if RCPT TO returns a 5xx error.
      response = conn.rcptto(to_address) rescue $!
      return response.is_a?(Net::SMTPFatalError)
    end
  end

  # Does a DNS MX record lookup of the domain in the email address and returns the
  # name of the mail server, if it exists.
  # @param to_address [String] the email address to check
  # @param timeout [Integer] the network timeout
  # @return [String] the DNS name of the mail server
  def mx_domain(to_address, timeout: nil)
    domain = Mail::Address.new(to_address).domain

    dns = Resolv::DNS.new
    dns.timeouts = timeout
    response = dns.getresource(domain, Resolv::DNS::Resource::IN::MX)

    response.exchange.to_s
  rescue Resolv::ResolvError
    nil
  end
end
