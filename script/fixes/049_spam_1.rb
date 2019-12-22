#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

MIN_USER_ID = 528958
MIN_DATE = "2017-09-01"
NAME_REGEXP = /^[a-z0-9]+\d{3,}$/
BAD_TITLES = ["My collection", "hi", "My private videos", "My video", "hey", "My webcam", "My dirty fantasies", "My new video", "My hot photos", "My hot webcam", "All your desires", "My hot videos", "my profile", "record from my webcam", "my hot webcam"]

spammers = Set.new(Dmail.where("dmails.from_id >= ? and dmails.created_at >= ? and is_spam = ?", MIN_USER_ID, MIN_DATE, true).joins("join users on users.id = dmails.from_id").where("users.name ~ '^[a-z0-9]+[0-9]{3,}$'").pluck("users.id").map(&:to_i).uniq)
new_spammers = Set.new

User.without_timeout do
  Dmail.where("created_at >= ? and is_spam = ?", MIN_DATE, false).find_each do |dmail|
    from_name = dmail.from_name
    if dmail.from_id >= MIN_USER_ID && from_name =~ NAME_REGEXP
      dmail.update_column(:is_spam, true)
      dmail.spam!

      puts "marked #{dmail.id}"

      if !spammers.include?(dmail.from_id)
        new_spammers.add(dmail.from_id)
      end
    end
  end
end

new_new_spammers = Set.new(Dmail.where("from_id >= ? and title in (?) and from_id not in (?)", MIN_USER_ID, BAD_TITLES, (spammers + new_spammers).to_a).pluck(:from_id))

combined_spammers = spammers + new_spammers + new_new_spammers
combined_spammers.each do |uid|
  unless Ban.where(user_id: uid).exists?
    Ban.create!(duration: 10000, reason: "Spam (automated ref f6147ace)", user_id: uid)
    puts "banned #{uid}"
    sleep 1
  end
end
