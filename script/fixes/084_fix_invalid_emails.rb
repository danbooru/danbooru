#!/usr/bin/env ruby

require_relative "base"

def fix(email, regex, replacement)
  email.update!(address: email.address.gsub(regex, replacement))
  puts ({ old: email.address_before_last_save, new: email.address }).to_json
rescue StandardError => e
  puts ({ old: email.address_was, new: email.address, error: e }).to_json
  email.reload.update_attribute(:is_deliverable, false)
end

with_confirmation do
  # `foo@gmail.com `
  EmailAddress.where("address ~ '[[:space:]]'").find_each do |email|
    fix(email, /[[:space:]]/, "")
  end

  # foo@gmail,com foo@rambler,ru
  EmailAddress.where("address ~ '@[a-z]+,[a-z]+$'").find_each do |email|
    fix(email, /@([a-z]+),([a-z]+)$/, '@\1.\2')
  end

  # foo@gmail.com, foo@gmail.com/
  EmailAddress.where("address ~ '\\.com.$'").find_each do |email|
    fix(email, /\.com.$/, ".com")
  end

  # foo@gmail.co,
  EmailAddress.where("address ~ '\\.co[^m]$'").find_each do |email|
    fix(email, /\.co[^m]$/, ".com")
  end

  # fooqq@.com
  EmailAddress.where("address ~ 'qq@\\.com$'").find_each do |email|
    fix(email, /qq@\.com$/, "@qq.com")
  end

  # fooaol@.com
  EmailAddress.where("address ~ 'aol@\\.com$'").find_each do |email|
    fix(email, /aol@\.com$/, "@aol.com")
  end

  # foo@qqcom
  EmailAddress.where("address ~ '@qqcom$'").find_each do |email|
    fix(email, /@qqcom$/, "@qq.com")
  end

  # foo@gmail foo@yahoo foo@yandex
  EmailAddress.where("address ~ '@(gmail|yahoo|yandex|icloud|naver|hotmail|outlook)$'").find_each do |email|
    fix(email, /@(gmail|yahoo|yandex|icloud|naver|hotmail|outlook)$/, '@\1.com')
  end

  # foo@gmail. foo@gmail,
  EmailAddress.where("address ~ '@[a-z]+[.,]$'").find_each do |email|
    fix(email, /@([a-z]+)[.,]$/, '@\1.com')
  end

  # mailto:foo@gmail.com
  EmailAddress.where("address ~ '^mailto:'").find_each do |email|
    fix(email, /^mailto:/, "")
  end

  # foo@gmailcom foo@hotmailcom
  EmailAddress.where("address ~ '@[a-z]+com$'").find_each do |email|
    fix(email, /@([a-z]+)com$/, '@\1.com')
  end

  # foo@gmail.com@gmail.com foo@live.com@hotmail.com
  EmailAddress.where("address ~ '@[a-z]+\\.com@[a-z]+\\.com$'").find_each do |email|
    fix(email, /@([a-z]+)\.com@([a-z]+)\.com$/, '@\2.com')
  end

  # foo@g,ail.com
  EmailAddress.where("address ~ '@g[^m]ail\\.com$'").find_each do |email|
    fix(email, /@g[^m]ail\.com$/, "@gmail.com")
  end

  # foo@gamil.com
  EmailAddress.where("address ~ '@gamil\\.com$'").find_each do |email|
    fix(email, /@gamil\.com$/, "@gmail.com")
  end

  # foo@gmai;.com
  EmailAddress.where("address ~ '@gmai[^l]\\.com$'").find_each do |email|
    fix(email, /@gmai[^l]\.com$/, "@gmail.com")
  end

  # foo@gmail@com
  EmailAddress.where("address ~ '@gmail[^.]com$'").find_each do |email|
    fix(email, /@gmail[^.]com$/, "@gmail.com")
  end

  # Mark all other invalid emails as undeliverable.
  EmailAddress.where(is_deliverable: true).where("address !~ '^[a-zA-Z0-9._%+-]+@([a-zA-Z0-9][a-zA-Z0-9-]{0,61}\\.)+[a-zA-Z]{2,}$'").find_each do |email|
    email.update_attribute(:is_deliverable, false)
    puts ({ address: email.address, is_deliverable: false }).to_json
  end
end
