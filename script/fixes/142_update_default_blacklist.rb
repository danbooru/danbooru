#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  User.where(blacklisted_tags: "guro\nscat\nfurry -rating:g").update_all(blacklisted_tags: User::DEFAULT_BLACKLIST)
end
