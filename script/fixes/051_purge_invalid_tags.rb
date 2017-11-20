#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

Tag.transaction do
  empty_gentags = Tag.empty.where(category: Tag.categories.general)
  total = empty_gentags.count

  empty_gentags.find_each.with_index do |tag, i|
    STDERR.puts %{validating "#{tag.name}" (#{i}/#{total})} if i % 1000 == 0

    if tag.invalid?(:create)
      # puts ({ name: tag.name, id: tag.id }).to_json
      tag.delete
    end
  end
end
