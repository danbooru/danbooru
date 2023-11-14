#!/usr/bin/env ruby

require_relative "base"

def delete(user)
  return if !user.name_invalid?

  if ENV.fetch("WARN", "false").truthy? && user.can_receive_email?
    Dmail.create_automated(to: user, title: "Action required: Change your username or your Danbooru account will be deleted", body: <<~EOS)
      Your current Danbooru username is invalid. Your Danbooru account will be deleted in one week unless you change your username. Use the link below to change your username:

      * "Change username":/user_name_change_requests/new
    EOS

    puts "[WARN] id=#{user.id} user='#{user.name}' email='#{user.email_address.address}'"
  elsif ENV.fetch("DELETE", "false").truthy?
    puts "[DELETE] id=#{user.id} user='#{user.name}'"
    UserDeletion.new(user: user, deleter: User.owner).delete!
  end
end

with_confirmation do
  condition = ENV.fetch("COND", "TRUE")
  users = User.where(Arel.sql(condition))

  users.where("length(name) = 1").find_each do |user|
    delete(user)
  end

  users.where("length(name) >= 25").find_each do |user|
    delete(user)
  end

  users.where_regex(:name, "[[:space:]]").find_each do |user|
    delete(user)
  end

  users.where_regex(:name, "^[[:punct:]]").find_each do |user|
    delete(user)
  end

  users.where_regex(:name, "[[:punct:]]$").find_each do |user|
    delete(user)
  end

  users.where_regex(:name, "\.(html|json|xml|atom|rss|txt|js|css|csv|png|jpg|jpeg|gif|png|mp4|webm|zip|pdf|exe|sitemap)$").find_each do |user|
    delete(user)
  end

  users.where_regex(:name, "[][`~!@#$%^&*()+={}|\\:;'\"<>,?/]").find_each do |user|
    delete(user)
  end

  users.where_not_regex(:name, "[[:ascii:]]").find_each do |user|
    delete(user)
  end
end
