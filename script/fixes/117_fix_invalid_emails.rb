#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  emails = EmailAddress.where_not_regex(:address, '^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9][a-zA-Z0-9-]{0,61}\.)+[a-zA-Z]{2,}$') # invalid emails

  emails.find_each do |email|
    old_address = email.address
    address = email.address

    address = address.gsub(/\r|\n/, " ")
    address = address.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")

    # foo,bar@gmail.com -> foo.bar@gmail.com | @gmail,com -> @gmail.com
    address = address.gsub(/,/, ".")

    address = address.gsub(/[\\\/]$/, '') # @qq.com\ -> @qq.com, @web.de/ -> @web.de
    address = address.gsub(/^https?:\/\/(www\.)?/i, "") # https://xxx@gmail.com -> xxx@gmail.com
    address = address.gsub(/^mailto:/i, "") # mailto:foo@gmail.com -> foo@gmail.com
    address = address.gsub(/.* <(.*)>$/, '\1') # foo <bar@gmail.com> -> bar@gmail.com

    # "@gmail" followed by anything that isn't a common domain
    address = address.gsub(/@gmail(?![a-z0-9]{2,})(?!.(com|net|org|info|ru|fr|it|nl|hu|de|fi|jp|se|ca|cn|cx|cz|dk|tw|su|es|no|ch|br|pl|co\.[a-z]{2}|plala\.or\.jp)).*/i, "@gmail.com")
    address = address.gsub(/@yahoo(?![a-z0-9]{2,})(?!.(com|net|org|info|ru|fr|it|nl|hu|de|fi|jp|se|ca|cn|cx|cz|dk|tw|su|es|no|ch|br|pl|co\.[a-z]{2}|plala\.or\.jp)).*/i, "@yahoo.com")
    address = address.gsub(/@hotmail(?![a-z0-9]{2,})(?!.(com|net|org|info|ru|fr|it|nl|hu|de|fi|jp|se|ca|cn|cx|cz|dk|tw|su|es|no|ch|br|pl|co\.[a-z]{2}|plala\.or\.jp)).*/i, "@hotmail.com")
    address = address.gsub(/@yandex(?![a-z0-9]{2,})(?!.(com|net|org|info|ru|fr|it|nl|hu|de|fi|jp|se|ca|cn|cx|cz|dk|tw|su|es|no|ch|br|pl|co\.[a-z]{2}|plala\.or\.jp)).*/i, "@yandex.ru")

    address = address.gsub(/@\./, "@") # @.gmail.com -> @gmail.com
    address = address.gsub(/@com$/i, ".com") # @gmail@com -> @gmail.com

    address = address.gsub(/\.co,$/i, '.com') # @gmail.co, -> @gmail.com
    address = address.gsub(/\.com.$/i, '.com') # @gmail.com, -> @gmail.com
    address = address.gsub(/\.con$/i, '.com') # @gmail.con -> @gmail.com

    # "@gmail com" -> @gmail.com | @gmail,com -> @gmail.com | @gmail..com -> @gmail.com
    address = address.gsub(/(?:[ ,]|\.\.)(com|net|org|info|ru|fr|it|nl|hu|de|fi|jp|se|ca|cn|cx|cz|dk|tw|su|es|no|ch|br|pl|co)$/i, '.\1')

    # @gmail -> @gmail.com
    address = address.gsub(/@gmai$/i, "@gmail.com")
    address = address.gsub(/@gmail$/i, "@gmail.com")
    address = address.gsub(/@yahoo$/i, "@yahoo.com")
    address = address.gsub(/@hotmai$/i, "@hotmail.com")
    address = address.gsub(/@hotmail$/i, "@hotmail.com")
    address = address.gsub(/@hot[^m]ail$/i, "@hotmail.com")
    address = address.gsub(/@interia$/i, "@interia.pl")
    address = address.gsub(/@live$/i, "@live.com")
    address = address.gsub(/@mailinator$/i, "@mailinator.com")
    address = address.gsub(/@naver$/i, "@naver.com")
    address = address.gsub(/@verizon$/i, "@verizon.net")

    # @gmailcom -> @gmail.com
    address = address.gsub(/@(gmail|yahoo|hotmail|aol|163)com$/i, '@\1.com')

    address = address.gsub(/@gamil\.com$/i, "@gmail.com") # @gamil.com -> @gmail.com
    address = address.gsub(/@gmai\.com$/i, "@gmail.com") # @gmai.com -> @gmail.com
    address = address.gsub(/@gmai\.co$/i, "@gmail.com") # @gmai.co -> @gmail.com
    address = address.gsub(/@hotmai\.com$/i, "@hotmail.com") # @hotmai.com -> @hotmail.com
    address = address.gsub(/@hot.ail\.com$/i, "@hotmail.com") # @hot.ail.com -> @hotmail.com
    address = address.gsub(/@hot.mail\.com$/i, "@hotmail.com") # @hot,mail.com -> @hotmail.com

    address = address.gsub(/@hotmail.com$/i, "@hotmail.com") # @hotmail,com -> @hotmail.com
    address = address.gsub(/@yahoo.com$/i, "@yahoo.com")
    address = address.gsub(/@mail.ru$/i, "@mail.ru")

    address = address.gsub(/@([a-z]+)\.com@\1\.com$/i, '@\1.com') # @gmail.com@gmail.com -> @gmail.com
    address = address.gsub(/@([a-z]+)@\1\.com$/i, '@\1.com') # @gmail@gmail.com -> @gmail.com
    #address = address.gsub(/@gmail@com$/, "@gmail.com")
    #address = address.gsub(/@aol@aol\.com$/, "@aol.com")
    address = address.gsub(/@tuta@io$/i, "@tuta.io")

    # cyrillic to latin
    cyrillic = { "а": "a", "А": "A", "С": "C", "е": "e", "Е": "E", "К": "K", "М": "M", "о": "o", "О": "O", "Т": "T" }.stringify_keys
    address = address.gsub(/[^[:ascii:]]/) { cyrillic.fetch(_1, _1) }
    #address = I18n.transliterate(address)

    address = address.downcase.gsub(/^(.*)\1$/i, '\1') if address.downcase.match?(/^(.*)\1$/i) # Foo@gmail.comfoo@gmail.com -> foo@gmail.com
    address = address.downcase.gsub(/^(.*)@\1@[a-zA-Z]+\.com$/i, '\1') if address.downcase.match?(/^(.*)@\1@[a-zA-Z]+\.com$/i) # foo@foo@gmail.com -> foo@gmail.com

    normalized_address = EmailValidator.normalize(address)
    dupe_emails = EmailAddress.where(normalized_address: normalized_address).excluding(email)
    if dupe_emails.present?
      puts "#{old_address.ljust(40, " ")} DELETE (#{dupe_emails.map { "#{_1.user.name}##{_1.user.id}" }.join(", ")}, #{email.user.name}##{email.user.id})"
      email.destroy if ENV.fetch("FIX", "false").truthy?
    elsif address.match?(/^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9][a-zA-Z0-9-]{0,61}\.)+[a-zA-Z]{2,}$/)
      puts "#{old_address.ljust(40, " ").gsub(/\r|\n/, "")} #{address}"
      email.user.update!(email_address_attributes: { address: address }) if ENV.fetch("FIX", "false").truthy?
    else
      puts "#{old_address.ljust(40, " ")} DELETE"
      email.destroy if ENV.fetch("FIX", "false").truthy?
    end
  end

  emails = EmailAddress.where_not_regex(:normalized_address, '^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9][a-zA-Z0-9-]{0,61}\.)+[a-zA-Z]{2,}$')
  emails.find_each do |email|
    puts "#{email.address.ljust(40, " ")} DELETE"
    email.destroy if ENV.fetch("FIX", "false").truthy?
  end
end
