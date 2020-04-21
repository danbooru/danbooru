require 'resolv'

module EmailValidator
  module_function

  IGNORE_DOTS = %w[gmail.com]
  IGNORE_PLUS_ADDRESSING = %w[gmail.com hotmail.com outlook.com live.com]
  IGNORE_MINUS_ADDRESSING = %w[yahoo.com]
  CANONICAL_DOMAINS = {
    "googlemail.com" => "gmail.com",
    "hotmail.co.uk" => "outlook.com",
    "hotmail.co.jp" => "outlook.com",
    "hotmail.co.th" => "outlook.com",
    "hotmail.com" => "outlook.com",
    "hotmail.ca" => "outlook.com",
    "hotmail.de" => "outlook.com",
    "hotmail.es" => "outlook.com",
    "hotmail.fr" => "outlook.com",
    "hotmail.it" => "outlook.com",
    "live.com.au" => "outlook.com",
    "live.com.ar" => "outlook.com",
    "live.com.mx" => "outlook.com",
    "live.co.uk" => "outlook.com",
    "live.com" => "outlook.com",
    "live.ca" => "outlook.com",
    "live.cl" => "outlook.com",
    "live.cn" => "outlook.com",
    "live.de" => "outlook.com",
    "live.fr" => "outlook.com",
    "live.it" => "outlook.com",
    "live.jp" => "outlook.com",
    "live.nl" => "outlook.com",
    "live.se" => "outlook.com",
    "msn.com" => "outlook.com",
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
    "yahoo.co.uk" => "yahoo.com",
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
  }

  def smtp_enabled?
    Rails.env.production?
  end

  def normalize(address)
    return nil unless address.count("@") == 1

    name, domain = address.downcase.split("@")

    domain = CANONICAL_DOMAINS.fetch(domain, domain)
    name = name.delete(".") if domain.in?(IGNORE_DOTS)
    name = name.gsub(/\+.*\z/, "") if domain.in?(IGNORE_PLUS_ADDRESSING)
    name = name.gsub(/-.*\z/, "") if domain.in?(IGNORE_MINUS_ADDRESSING)

    "#{name}@#{domain}"
  end

  def nondisposable?(address)
    return true if Danbooru.config.email_domain_verification_list.blank?
    domain = Mail::Address.new(address).domain
    domain.in?(Danbooru.config.email_domain_verification_list.to_a)
  end

  def undeliverable?(to_address, from_address: Danbooru.config.contact_email, timeout: 3)
    mail_server = mx_domain(to_address, timeout: timeout)
    mail_server.nil? || rcpt_to_failed?(to_address, from_address, mail_server, timeout: timeout)
  rescue
    false
  end

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
