#!/usr/bin/env ruby

require_relative "base"

# delete fake emails
with_confirmation do
  fake_emails = %w[
    a@a.com
    a@b.com
    a@aa.com
    a@outlook.com
    a@yahoo.com
    a@gmail.com
    a@naver.com
    1@1.com
    1@yahoo.com
    222@222.com
    aa@bb.com
    aa@gmail.com
    aaa@aa.com
    aaa@gmail.com
    aaa@yahoo.com
    aaa@outlook.com
    aaaa@outlook.com
    aaaaa@yahoo.com
    aaaaa@outlook.com
    aaaaaa@gmail.com
    abc@gmail.com
    abc@outlook.com
    abc@yahoo.com
    ass@ass.com
    asd@yahoo.com
    asdf@gmail.com
    asdf@yahoo.com
    abcd@yahoo.com
    lol@outlook.com
    bob@gmail.com
    dan@gmail.com
    john@yahoo.com
    danbooru@outlook.com
    123456789@qq.com
    asd@asd.asd
    asdf@asdf.com
    no@no.no
    test@example.com
  ]

  emails = EmailAddress.where(normalized_address: fake_emails)

  emails.each do |email|
    puts "DELETE #{email.address} (#{email.user.name}##{email.user.id})"
    email.destroy if ENV.fetch("DELETE", "false").truthy?
  end
end

# delete dupe emails belonging to banned users
with_confirmation do
  emails = EmailAddress.where(user: User.banned).where(normalized_address: EmailAddress.group(:normalized_address).having("COUNT(*) > 1").select(:normalized_address))

  emails.each do |email|
    puts "DELETE #{email.address} (#{email.user.name}##{email.user.id})"
    email.destroy if ENV.fetch("DELETE", "false").truthy?
  end
end

# delete dupe emails, keeping the email belonging to the account that visited the site most recently.
with_confirmation do
  emails = EmailAddress.group(:normalized_address).having("COUNT(*) > 1").select(:normalized_address, "array_agg(id) AS ids").order(Arel.sql("COUNT(*) DESC, normalized_address"))

  emails.each do |email|
    dupe_emails = EmailAddress.where(id: email.ids).joins(:user).to_a

    dupe_emails.sort_by! { |dupe_email| [-dupe_email.user.last_logged_in_at.to_i, -dupe_email.user.id] }
    dupe_emails => [keep, *dupes]

    puts "#{"#{keep.address} (#{keep.user.name}##{keep.user.id})".ljust(60, " ")} DELETE #{dupes.map { |dupe| "#{dupe.address} (#{dupe.user.name}##{dupe.user.id})" }.join(" ")}"
    dupes.each(&:destroy) if ENV.fetch("DELETE", "false").truthy?
  end

  emails = EmailAddress.group(:address).having("COUNT(*) > 1").select(:address, "array_agg(id) AS ids").order(Arel.sql("COUNT(*) DESC, address"))

  emails.each do |email|
    dupe_emails = EmailAddress.where(id: email.ids).joins(:user).to_a

    dupe_emails.sort_by! { |dupe_email| [-dupe_email.user.last_logged_in_at.to_i, -dupe_email.user.id] }
    dupe_emails => [keep, *dupes]

    puts "#{"#{keep.address} (#{keep.user.name}##{keep.user.id})".ljust(60, " ")} DELETE #{dupes.map { |dupe| "#{dupe.address} (#{dupe.user.name}##{dupe.user.id})" }.join(" ")}"
    dupes.each(&:destroy) if ENV.fetch("DELETE", "false").truthy?
  end
end
