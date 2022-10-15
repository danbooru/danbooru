#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  EmailAddress.find_each do |email|
    old_address = email.address.to_s
    fixed_address = Danbooru::EmailAddress.normalize(old_address).to_s
    normalized_address = EmailValidator.normalize(fixed_address)

    next if old_address == fixed_address

    dupe_emails = EmailAddress.where(normalized_address: normalized_address).excluding(email).joins(:user).to_a
    if dupe_emails.present?
      dupe_emails += [email]
      dupe_emails.sort_by! { |dupe_email| [-dupe_email.user.last_logged_in_at.to_i, -dupe_email.user.id] }
      dupe_emails => [keep, *dupes]

      puts "#{"#{keep.address} (#{keep.user.name}##{keep.user.id})".ljust(60, " ")} DELETE #{dupes.map { |dupe| "#{dupe.address} (#{dupe.user.name}##{dupe.user.id})" }.join(" ")}"
      dupes.each(&:destroy) if ENV.fetch("FIX", "false").truthy?
    else
      puts "#{old_address.ljust(60, " ").gsub(/\r|\n/, "")} #{fixed_address}"
      email.user.update!(email_address_attributes: { address: fixed_address }) if ENV.fetch("FIX", "false").truthy?
    end
  end
end
