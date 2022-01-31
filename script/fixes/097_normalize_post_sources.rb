#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  CurrentUser.scoped(User.system, "127.0.0.1") do
    Post.where("source ~ '[^[:ascii:]]'").find_each do |post|
      next if post.source.unicode_normalize(:nfc) == post.source

      post.update!(source: post.source)
      puts({ id: post.id, old_source: post.source_before_last_save, new_source: post.source })
    end
  end
end
