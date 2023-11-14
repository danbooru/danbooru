#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  emails = EmailAddress.find_each do |email|
    normalized_address = Danbooru::EmailAddress.new(email.address).canonicalized_address.to_s

    if email.normalized_address != normalized_address
      dupe_emails = EmailAddress.where(normalized_address: normalized_address).joins(:user).to_a

      if dupe_emails.present?
        dupe_emails += [email]
        dupe_emails.sort_by! { |dupe_email| [-dupe_email.user.last_logged_in_at.to_i, -dupe_email.user.id] }
        dupe_emails => [keep, *dupes]

        puts "#{"#{keep.address} (#{keep.user.name}##{keep.user.id})".ljust(60, " ")} DELETE #{dupes.map { |dupe| "#{dupe.address} (#{dupe.user.name}##{dupe.user.id})" }.join(" ")}"
        dupes.each(&:destroy) if ENV.fetch("FIX", "false").truthy?
      else
        puts "#{email.normalized_address.ljust(60, " ")} #{normalized_address}"
        email.update!(normalized_address: normalized_address) if ENV.fetch("FIX", false).to_s.truthy?
      end
    end
  end
end
