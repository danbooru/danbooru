#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  User.where(blacklisted_tags: "spoilers\nguro\nscat\nfurry -rating:s").update_all(blacklisted_tags: User::DEFAULT_BLACKLIST)
  User.where(blacklisted_tags: "spoilers\r\nguro\r\nscat\r\nfurry -rating:s").update_all(blacklisted_tags: User::DEFAULT_BLACKLIST)
  User.where(blacklisted_tags: "spoilers\r\nguro\r\nscat\r\nfurry -rating:s\r\n").update_all(blacklisted_tags: User::DEFAULT_BLACKLIST)

  User.where(blacklisted_tags: "spoilers\nguro\nscat").update_all(blacklisted_tags: "guro\nscat")
  User.where(blacklisted_tags: "spoilers\r\nguro\r\nscat").update_all(blacklisted_tags: "guro\nscat")
  User.where(blacklisted_tags: "spoilers\r\nguro\r\nscat\r\n").update_all(blacklisted_tags: "guro\nscat")

  User.where(blacklisted_tags: "spoilers\nscat\nfurry -rating:s").update_all(blacklisted_tags: "scat\nfurry -rating:s")
  User.where(blacklisted_tags: "spoilers\r\nscat\r\nfurry -rating:s").update_all(blacklisted_tags: "scat\nfurry -rating:s")

  User.where(blacklisted_tags: "spoilers\nguro\nscat\nfurry -rating:s\nyaoi").update_all(blacklisted_tags: "guro\nscat\nfurry -rating:s\nyaoi")
end
